import os
import sys
import logging
from typing import Generator
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from .base import Base
from . import models  # Ensure all models are registered with Base.metadata

logger = logging.getLogger("sasyadrishti.db")

_DB_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_DEFAULT_DB_PATH = os.path.join(_DB_DIR, "sasyadrishti.db")

environment = os.getenv("ENVIRONMENT", "development").lower().strip()
raw_db_url = os.getenv("DATABASE_URL")

# Strict Production Validation: Prevent accidental ephemeral SQLite in production
if environment == "production":
    if not raw_db_url or raw_db_url.strip() == "" or raw_db_url.startswith("sqlite"):
        error_msg = (
            "CRITICAL CONFIGURATION ERROR: ENVIRONMENT is set to 'production', but DATABASE_URL "
            "is missing or configured to SQLite. A persistent hosted PostgreSQL database "
            "(e.g., Supabase) is required for production to prevent data loss."
        )
        logger.critical(error_msg)
        raise RuntimeError(error_msg)

if not raw_db_url:
    raw_db_url = f"sqlite:///{_DEFAULT_DB_PATH}"

# Normalize PostgreSQL URL if provided (Supabase postgres:// or postgresql:// -> postgresql+psycopg2://)
if raw_db_url.startswith("postgres://"):
    DATABASE_URL = raw_db_url.replace("postgres://", "postgresql+psycopg2://", 1)
elif raw_db_url.startswith("postgresql://") and not raw_db_url.startswith("postgresql+"):
    DATABASE_URL = raw_db_url.replace("postgresql://", "postgresql+psycopg2://", 1)
else:
    DATABASE_URL = raw_db_url

is_sqlite = DATABASE_URL.startswith("sqlite")

engine_kwargs = {
    "echo": False,
}

if is_sqlite:
    engine_kwargs["connect_args"] = {"check_same_thread": False}
else:
    # Production PostgreSQL (Supabase / AWS RDS / Pooler) configuration
    # Compatible with direct connection (port 5432) or transaction/session pooler (port 5432 / 6543)
    engine_kwargs["pool_pre_ping"] = True
    engine_kwargs["pool_recycle"] = 300
    engine_kwargs["pool_size"] = 10
    engine_kwargs["max_overflow"] = 20
    engine_kwargs["connect_args"] = {
        "sslmode": "require",
        "connect_timeout": 10,
    }

engine = create_engine(DATABASE_URL, **engine_kwargs)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_db_health() -> bool:
    """Verify live database connectivity without raising unhandled exceptions or leaking credentials."""
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception as e:
        # Sanitize log output to prevent credential or URL leakage
        err_msg = str(e).split("\n")[0]
        if "@" in err_msg:
            # Strip connection credentials from error message
            err_msg = "Connection failed to database host (credentials masked)."
        logger.error(f"Database health check failed: {err_msg}")
        return False

def init_db() -> None:
    """Initialize database tables for SQLite (dev) or defer to Alembic (prod)."""
    if environment == "production":
        logger.info("Production environment active: database schema migrations are managed via Alembic.")
        return

    try:
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables initialized successfully (SQLite).")
    except Exception as e:
        err_msg = str(e).split("\n")[0]
        if "@" in err_msg:
            err_msg = "Failed to connect to database host (credentials masked)."
        logger.error(f"Failed to initialize database tables: {err_msg}")

def get_db() -> Generator[Session, None, None]:
    """Dependency injection for database sessions with safe cleanup."""
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()
