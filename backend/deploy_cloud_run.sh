#!/usr/bin/env bash
# ==============================================================================
# SasyaDrishti — Production Google Cloud Run Automated Deployment (Singapore)
# Project ID: sasyadrishti-cloud | Region: asia-southeast1
# ==============================================================================
set -euo pipefail

PROJECT_ID="sasyadrishti-cloud"
REGION="asia-southeast1"
SERVICE_NAME="sasyadrishti-backend"
MIGRATION_JOB_NAME="sasyadrishti-migration-job"
SA_NAME="sasyadrishti-cr-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
DB_SECRET_NAME="sasyadrishti-db-url"
PUMP_SECRET_NAME="sasyadrishti-pump-api-key"
REPO_NAME="sasyadrishti-repo"
IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:latest"

echo ">>> Setting Google Cloud Project to ${PROJECT_ID}..."
gcloud config set project "${PROJECT_ID}"

# 1. Enable Required Cloud APIs
echo ">>> Enabling Cloud Run, Cloud Build, Artifact Registry, and Secret Manager APIs..."
gcloud services enable run.googleapis.com \
                       cloudbuild.googleapis.com \
                       artifactregistry.googleapis.com \
                       secretmanager.googleapis.com

# 2. Create Artifact Registry Repository if not present
echo ">>> Verifying Artifact Registry Repository..."
if ! gcloud artifacts repositories describe "${REPO_NAME}" --location="${REGION}" >/dev/null 2>&1; then
    gcloud artifacts repositories create "${REPO_NAME}" \
        --repository-format=docker \
        --location="${REGION}" \
        --description="SasyaDrishti Container Registry"
fi

# 3. Create Dedicated Runtime Service Account (Least Privilege)
echo ">>> Configuring Dedicated Cloud Run Runtime Service Account..."
if ! gcloud iam service-accounts describe "${SA_EMAIL}" >/dev/null 2>&1; then
    gcloud iam service-accounts create "${SA_NAME}" \
        --description="Dedicated runtime service account for SasyaDrishti Cloud Run" \
        --display-name="SasyaDrishti Cloud Run SA"
fi

# 4. Build Production Container Image using Cloud Build
echo ">>> Submitting build to Google Cloud Build (CPU-Only PyTorch + Model Checkpoint)..."
gcloud builds submit --tag "${IMAGE_TAG}" .

# 5. Execute Database Migrations via Controlled Cloud Run Job (Single-Runner, Zero Race Conditions)
echo ">>> Deploying and executing one-off database migration via Cloud Run Job..."
if ! gcloud run jobs describe "${MIGRATION_JOB_NAME}" --region="${REGION}" >/dev/null 2>&1; then
    gcloud run jobs create "${MIGRATION_JOB_NAME}" \
        --image="${IMAGE_TAG}" \
        --region="${REGION}" \
        --service-account="${SA_EMAIL}" \
        --set-env-vars="ENVIRONMENT=production" \
        --set-secrets="DATABASE_URL=${DB_SECRET_NAME}:latest" \
        --command="alembic" \
        --args="upgrade,head" \
        --max-retries=0 \
        --task-timeout=120s
else
    gcloud run jobs update "${MIGRATION_JOB_NAME}" \
        --image="${IMAGE_TAG}" \
        --region="${REGION}" \
        --service-account="${SA_EMAIL}" \
        --set-env-vars="ENVIRONMENT=production" \
        --set-secrets="DATABASE_URL=${DB_SECRET_NAME}:latest" \
        --command="alembic" \
        --args="upgrade,head"
fi

echo ">>> Running Database Migration Job on Supabase PostgreSQL..."
gcloud run jobs execute "${MIGRATION_JOB_NAME}" --region="${REGION}" --wait

# 6. Deploy Web Service to Cloud Run
echo ">>> Deploying ${SERVICE_NAME} to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
    --image="${IMAGE_TAG}" \
    --region="${REGION}" \
    --platform managed \
    --service-account="${SA_EMAIL}" \
    --allow-unauthenticated \
    --min-instances 0 \
    --max-instances 1 \
    --concurrency 20 \
    --memory 1Gi \
    --cpu 1 \
    --timeout 60 \
    --set-env-vars="ENVIRONMENT=production,CONFIDENCE_THRESHOLD=0.60" \
    --set-secrets="DATABASE_URL=${DB_SECRET_NAME}:latest,PUMP_API_KEY=${PUMP_SECRET_NAME}:latest"

SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --format="value(status.url)")
echo "=========================================================================="
echo ">>> DEPLOYMENT SUCCESSFUL!"
echo ">>> Live Cloud Run HTTPS Service URL: ${SERVICE_URL}"
echo "=========================================================================="
