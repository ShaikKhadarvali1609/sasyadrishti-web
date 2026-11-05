import os
import time
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

# Configure structured logging with UTC timestamps
logging.basicConfig(
    level=logging.INFO if os.getenv("ENVIRONMENT") == "production" else logging.DEBUG,
    format='{"time":"%(asctime)sZ", "level":"%(levelname)s", "logger":"%(name)s", "message":"%(message)s"}',
    datefmt="%Y-%m-%dT%H:%M:%S",
)
logger = logging.getLogger("sasyadrishti.main")

_START_TIME = time.time()

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing SasyaDrishti Backend...")
    # Initialize database tables on startup
    from .db import init_db
    init_db()
    
    from .services.disease_service import is_model_ready
    if is_model_ready():
        logger.info("MobileNetV3-Small AI model loaded successfully.")
    else:
        logger.warning("MobileNetV3-Small AI model failed to load or checkpoint missing.")
        
    yield
    logger.info("SasyaDrishti Backend shutting down gracefully.")

app = FastAPI(
    title="SasyaDrishti Backend",
    version="1.0.0",
    description="SasyaDrishti Smart Agriculture AI Decision Support System Backend",
    lifespan=lifespan,
)

# Request payload limit middleware (Max 15 MB raw body to protect against memory exhaustion)
MAX_REQUEST_BYTES = 15 * 1024 * 1024

@app.middleware("http")
async def limit_request_size(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > MAX_REQUEST_BYTES:
        return JSONResponse(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            content={"detail": "Request payload exceeds maximum allowed size (15 MB)."},
        )
    return await call_next(request)

# Include API routers
from .api.v1.router import router as api_v1_router

# CORS configuration
is_production = os.getenv("ENVIRONMENT") == "production"
allowed_origins_env = os.getenv("ALLOWED_ORIGINS")
allow_origin_regex = os.getenv(
    "ALLOW_ORIGIN_REGEX",
    r"^https://([a-zA-Z0-9_-]+\.)?hf\.space$" if is_production else None,
)

if allowed_origins_env:
    allowed_origins = [o.strip() for o in allowed_origins_env.split(",") if o.strip()]
elif not is_production:
    # Development-only local testing origins
    allowed_origins = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]
else:
    allowed_origins = []

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=allow_origin_regex,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

app.include_router(api_v1_router, prefix="/api/v1")

# Liveness Probe: Verifies the process is running and accepting HTTP connections
@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "uptime_seconds": round(time.time() - _START_TIME, 1),
    }

# Readiness Probe: Verifies that database connectivity and AI models are active
@app.get("/ready")
def readiness_check():
    from .db import check_db_health
    from .services.disease_service import is_model_ready

    db_healthy = check_db_health()
    model_healthy = is_model_ready()

    all_ready = db_healthy and model_healthy
    resp_body = {
        "status": "ready" if all_ready else "not_ready",
        "database": "connected" if db_healthy else "disconnected",
        "model": "loaded" if model_healthy else "not_loaded",
        "environment": os.getenv("ENVIRONMENT", "development"),
    }

    if not all_ready:
        return JSONResponse(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, content=resp_body)
    return resp_body
