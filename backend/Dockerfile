# SasyaDrishti Backend — Production Dockerfile (Google Cloud Run / Container Platforms)
FROM python:3.11-slim

# Install system dependencies (build-essential, curl, libpq-dev for PostgreSQL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (Runs as UID 1000 for least-privilege security)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR $HOME/app

# Install lightweight PyTorch CPU wheel first for fast build and minimal image size (~350MB vs 2.5GB)
RUN pip install --no-cache-dir --user torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Copy requirements and install remaining pinned dependencies (PyTorch is not reinstalled)
COPY --chown=user:user requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Copy application source, migrations, and trained AI model checkpoint
COPY --chown=user:user app/ ./app/
COPY --chown=user:user models/ ./models/
COPY --chown=user:user alembic.ini .
COPY --chown=user:user alembic/ ./alembic/

# Expose default Cloud Run container port
EXPOSE 8080

# Start FastAPI production application with dynamic PORT binding and PID 1 signal forwarding
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
