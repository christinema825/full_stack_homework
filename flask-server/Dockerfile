FROM python:3.8-slim

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

ENV FLASK_APP=app.py

EXPOSE 5000 

CMD ["flask", "run", "-h", "0.0.0.0", "-p", "5000"]

