FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
# Add retry mechanism for pip install
RUN pip install --retries 5 --timeout 30 -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "main.py"]