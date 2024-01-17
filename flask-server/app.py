from flask import Flask, jsonify
from db_connector import get_db, init_app

# # from models import Customer

# app = Flask(__name__)
# app.config.from_mapping(
#     DB_HOST='localhost',
#     DB_USER='root',
#     DB_PASSWORD='mysecretpassword',
#     DB_DATABASE='machina_labs'
# )
# init_app(app)

# #Define a route
# @app.route('/file_tree', methods=['GET'])
# def file_tree():
#     query = """
#             SELECT 
#             *
#             FROM 
#                 customer 
#             LEFT JOIN 
#                 part ON customer.uuid = part.customer_uuid
#             LEFT JOIN
#                 part_revision ON part_revision.part_uuid = part.uuid
#             LEFT JOIN
#                 trial ON trial.part_revision_uuid = part_revision.uuid
#             LEFT JOIN
#                 process_run ON process_run.trial_uuid = trial.uuid
#             LEFT JOIN 
#                 process_run_file_artifact ON process_run_file_artifact.process_run_uuid = process_run.uuid  
#             LEFT JOIN
#                 file ON process_run_file_artifact.file_artifact_uuid = file.uuid     
#             """            

#     db = get_db()
#     cursor = db.cursor()
#     cursor.execute(query)
#     results = cursor.fetchall()
#     cursor.close()
#     # for result in results:
#         # print(result)
#     data = [results]
#     print(data)
#     data_list = [dict(zip(range(1, len(row)+1), row)) for row in data]
    
#     # Send JSON as part of the response
#     return jsonify(data_list)
#     # return "hello world"

# if __name__ == "__main__":
#     print("hello___________")
#     app.run(debug=True)


#                 # customer.name, customer.uuid, part.name, file.uuid, file.type, file.location,
#                 # part_revision.uuid, part_revision.name, part_revision.geometry_file_uuid,
#                 # trial.uuid, trial.success,
#                 # process_run.uuid, process_run.type,
#                 # process_run_file_artifact.uuid, process_run_file_artifact.file_artifact_uuid 



app = Flask(__name__)
app.config.from_mapping(
    DB_HOST='localhost',
    DB_USER='root',
    DB_PASSWORD='mysecretpassword',
    DB_DATABASE='machina_labs'
)
init_app(app)

#Define a route
@app.route('/file_tree', methods=['GET'])
def file_tree():

# Create a cursor
    db = get_db()
    cursor = db.cursor(dictionary=True)

    # Fetch data from the database
    cursor.execute("SELECT * FROM customer")
    customers = cursor.fetchall()

    cursor.execute("SELECT * FROM part")
    parts = cursor.fetchall()

    cursor.execute("SELECT * FROM part_revision")
    part_revisions = cursor.fetchall()

    cursor.execute("SELECT * FROM trial")
    trials = cursor.fetchall()

    cursor.execute("SELECT * FROM process_run")
    process_runs = cursor.fetchall()

    cursor.execute("SELECT * FROM file")
    files = cursor.fetchall()

    cursor.execute("SELECT * FROM process_run_file_artifact")
    file_artifacts = cursor.fetchall()

    # Close the cursor and connection
    cursor.close()

    # Organize data into a nested dictionary representing a file tree
    data = {}

    for customer in customers:
        print(customer)
        customer_uuid = customer['uuid']
        data[customer_uuid] = {
            'name': customer['name'],
            'parts': {}
        }

        # Fetch parts for each customer
        customer_parts = []

        for part in parts:
            if part['customer_uuid'] == customer_uuid:
                customer_parts.append(part)


        for part in customer_parts:
            part_uuid = part['uuid']
            data[customer_uuid]['parts'][part_uuid] = {
                'name': part['name'],
                'revisions': {}
            }

            # Fetch part revisions for each part
            part_revs = []

            for rev in part_revisions:
                if rev['part_uuid'] == part_uuid:
                    part_revs.append(rev)

            for rev in part_revs:
                rev_uuid = rev['uuid']
                data[customer_uuid]['parts'][part_uuid]['revisions'][rev_uuid] = {
                    'name': rev['name'],
                    'trials': []
                }

                # Fetch trials for each part revision
                rev_trials = []
                for trial in trials: 
                    if trial['part_revision_uuid'] == rev_uuid:
                        rev_trials.append(trial)

                for trial in rev_trials:
                    trial_uuid = trial['uuid']
                    data[customer_uuid]['parts'][part_uuid]['revisions'][rev_uuid]['trials'].append({
                        'success': trial['success'],
                        'process_runs': []
                    })

                    # Fetch process runs for each trial
                    trial_runs = []
                    for pr in process_runs:
                        if pr['trial_uuid'] == trial_uuid:
                            trial_runs.append(pr)

                    for pr in trial_runs:
                        pr_uuid = pr['uuid']
                        data[customer_uuid]['parts'][part_uuid]['revisions'][rev_uuid]['trials'][-1]['process_runs'].append({
                            'type': pr['type'],
                            'file_artifacts': []
                        })

                        # Fetch file artifacts for each process run
                        pr_file_artifacts = []
                        for fa in file_artifacts: 
                            if fa['process_run_uuid'] == pr_uuid:
                                pr_file_artifacts.append(fa)

                        for fa in pr_file_artifacts:
                            # Fetch data from the 'file' table based on 'file_artifact_uuid'
                            file_data = None
                            for file_row in files:
                                if file_row['uuid'] == fa['file_artifact_uuid']:
                                    file_data = file_row
                                    break

                            if file_data:
                                data[customer_uuid]['parts'][part_uuid]['revisions'][rev_uuid]['trials'][-1]['process_runs'][-1]['file_artifacts'].append({
                                    'type': file_data['type'],  
                                    'location': file_data['location']
                                })

    # Convert data to JSON
    print(jsonify(data))
    return jsonify(data)

if __name__ == "__main__":
    print("hello___________")
    app.run(debug=True)
    
