# Dockerfile for cloud deployment of the backend
FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY backend-requirements.txt .
RUN pip install --no-cache-dir -r backend-requirements.txt

# Copy application files
COPY app/cloud_server.py app/
COPY data/ data/

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "app/cloud_server.py"]
