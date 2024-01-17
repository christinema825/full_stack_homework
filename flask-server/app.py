from flask import Flask, jsonify, send_file, request
from flask_cors import CORS
from db_connector import get_db, init_app
from zipfile import ZipFile
import io
import os
import logging
import csv


logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)
app.config.from_mapping(
    DB_HOST='db_service',
    DB_USER='root',
    DB_PASSWORD='mysecretpassword',
    DB_DATABASE='machina_labs'
)
app.config['ENV'] = 'development'
app.config['DEBUG'] = True
init_app(app)
CORS(app)


# Define a route
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

    cursor.close()

    # Organize data into a nested dictionary representing a file tree
    data = {}
    for customer in customers:
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
                cad_files = [x for x in files if x['uuid']
                             == rev['geometry_file_uuid']]
                data[customer_uuid]['parts'][part_uuid]['revisions'][rev_uuid] = {
                    'name': rev['name'],
                    'trials': [],
                    'geometry_files': cad_files
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
    return jsonify(data)


@app.route('/preview', methods=['GET'])
def preview():
    filename = request.args.get('filename')
    current_directory = os.path.dirname(os.path.abspath(__file__))
    zip_file_path = os.path.join(current_directory, 'files.zip')

    with ZipFile(zip_file_path, 'r') as zip_file:
        csv_rows = []
        try:
            with zip_file.open('files/' + filename, 'r') as infile:
                reader = csv.reader(io.TextIOWrapper(infile, 'utf-8'))
                for row in list(reader)[:50]:
                    csv_rows.append(row)

            return jsonify(csv_rows)
        except Exception as e:
            print(e)
            return 'File not found in the zip archive.', 404


@app.route('/download', methods=['GET'])
def download():
    filename = request.args.get('filename')
    current_directory = os.path.dirname(os.path.abspath(__file__))
    zip_file_path = os.path.join(current_directory, 'files.zip')

    with ZipFile(zip_file_path, 'r') as zip_file:
        try:
            file_data = zip_file.read("files/" + filename)

            return send_file(
                io.BytesIO(file_data),
                mimetype='application/octet-stream',
                as_attachment=True,
                download_name=filename
            )
        except Exception as e:
            print(e)
            return 'File not found in the zip archive.', 404


if __name__ == "__main__":
    app.run(host='0.0.0.0')
