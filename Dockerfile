# app/Dockerfile
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI app code
COPY app/ .

# Expose the port that FastAPI runs on
EXPOSE 8000

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy the static files for the UI
COPY app/static /app/static

# Set the entrypoint to the Bash script
ENTRYPOINT ["/entrypoint.sh"]
