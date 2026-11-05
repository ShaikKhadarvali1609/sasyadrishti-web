# ==============================================================================
# SasyaDrishti — Google Cloud Run Automated Deployment Script
# Target Region: asia-southeast1 (Singapore - Matches Supabase ap-southeast-1)
# Cost Profile: Free Tier Eligible (Scale-to-zero, max 1 instance, 1 GiB RAM)
# ==============================================================================

# 1. Configuration Variables
$PROJECT_ID = "sasyadrishti-cloud"
$REGION = "asia-southeast1"
$SERVICE_NAME = "sasyadrishti-backend"
$DB_SECRET_NAME = "sasyadrishti-db-url"
$PUMP_SECRET_NAME = "sasyadrishti-pump-api-key"

Write-Host ">>> Configuring Google Cloud Project: $PROJECT_ID in $REGION..."
gcloud config set project $PROJECT_ID

# 2. Enable Required APIs (Free tier eligible)
Write-Host ">>> Enabling Google Cloud Service APIs..."
gcloud services enable run.googleapis.com `
                       cloudbuild.googleapis.com `
                       artifactregistry.googleapis.com `
                       secretmanager.googleapis.com

# 3. Grant Cloud Run Service Account access to Secret Manager
$PROJECT_NUM = $(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
$SERVICE_ACCOUNT = "$PROJECT_NUM-compute@developer.gserviceaccount.com"

Write-Host ">>> Granting Secret Accessor permissions to $SERVICE_ACCOUNT..."
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SERVICE_ACCOUNT" `
    --role="roles/secretmanager.secretAccessor"

# 4. Deploy to Google Cloud Run directly from source (using Cloud Build)
Write-Host ">>> Building and Deploying SasyaDrishti to Cloud Run..."
gcloud run deploy $SERVICE_NAME `
    --source . `
    --region $REGION `
    --platform managed `
    --allow-unauthenticated `
    --min-instances 0 `
    --max-instances 1 `
    --memory 1Gi `
    --cpu 1 `
    --timeout 60 `
    --set-env-vars="ENVIRONMENT=production,ALLOWED_ORIGINS=*" `
    --set-secrets="DATABASE_URL=$DB_SECRET_NAME:latest,PUMP_API_KEY=$PUMP_SECRET_NAME:latest"

Write-Host ">>> Deployment complete! Obtaining public HTTPS Service URL..."
$SERVICE_URL = $(gcloud run services describe $SERVICE_NAME --region $REGION --format="value(status.url)")
Write-Host ">>> Public HTTPS Backend URL: $SERVICE_URL"

