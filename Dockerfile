FROM python:3.8-slim

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

ENV PORT=5000

EXPOSE 5000 

CMD ["python", "flask-server/app.py"]

