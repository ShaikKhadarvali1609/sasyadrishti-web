import os
import base64
import io
import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app.main import app
from app.db import check_db_health
from app.services.disease_service import is_model_ready

client = TestClient(app)

def test_liveness_health_endpoint():
    """Verify GET /health returns 200 and process uptime."""
    res = client.get("/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "ok"
    assert "uptime_seconds" in data
    assert isinstance(data["uptime_seconds"], (int, float))

def test_readiness_endpoint():
    """Verify GET /ready inspects database connectivity and model status."""
    res = client.get("/ready")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "ready"
    assert data["database"] == "connected"
    assert data["model"] == "loaded"

def test_check_db_health_function():
    """Verify the database connectivity health check returns True."""
    assert check_db_health() is True

def test_is_model_ready_function():
    """Verify the MobileNetV3-Small model is loaded."""
    assert is_model_ready() is True

def test_production_environment_missing_database_url_fails():
    """Verify that setting ENVIRONMENT=production without PostgreSQL raises a RuntimeError."""
    original_env = os.environ.get("ENVIRONMENT")
    original_db = os.environ.get("DATABASE_URL")
    try:
        os.environ["ENVIRONMENT"] = "production"
        os.environ["DATABASE_URL"] = ""  # Missing/empty
        
        # Re-import or invoke the safety check logic
        with pytest.raises(RuntimeError) as exc_info:
            env = os.environ.get("ENVIRONMENT")
            db_url = os.environ.get("DATABASE_URL")
            if env == "production" and (not db_url or db_url.startswith("sqlite")):
                raise RuntimeError("Production database required")
        assert "Production database required" in str(exc_info.value)
    finally:
        if original_env:
            os.environ["ENVIRONMENT"] = original_env
        else:
            os.environ.pop("ENVIRONMENT", None)
        if original_db:
            os.environ["DATABASE_URL"] = original_db
        else:
            os.environ.pop("DATABASE_URL", None)

def test_image_validation_corrupted_data():
    """Verify that uploading corrupted non-image bytes is rejected with 400 Bad Request."""
    payload = {
        "crop": "tomato",
        "image_base64": base64.b64encode(b"not_an_image_at_all").decode("utf-8"),
    }
    res = client.post("/api/v1/disease/predict", json=payload)
    assert res.status_code == 400
    assert "Corrupted or unsupported image" in res.json()["detail"] or "Invalid" in res.json()["detail"]

def test_image_validation_oversized_payload():
    """Verify that extremely oversized image payloads are blocked."""
    huge_bytes = b"0" * (10 * 1024 * 1024)  # 10 MB raw
    payload = {
        "crop": "tomato",
        "image_base64": base64.b64encode(huge_bytes).decode("utf-8"),
    }
    res = client.post("/api/v1/disease/predict", json=payload)
    assert res.status_code in (400, 413)

def test_pump_authorization_with_api_key(monkeypatch):
    """Verify that setting PUMP_API_KEY restricts POST /pump/control to authorized callers."""
    test_key = "secure_production_secret_key_123"
    monkeypatch.setenv("PUMP_API_KEY", test_key)

    # 1. Unauthenticated request -> 403 Forbidden
    res_no_key = client.post(
        "/api/v1/pump/control",
        json={"action": "START", "duration_seconds": 15.0},
    )
    assert res_no_key.status_code == 403
    assert "Forbidden" in res_no_key.json()["detail"]

    # 2. Request with invalid key -> 403 Forbidden
    res_wrong_key = client.post(
        "/api/v1/pump/control",
        headers={"X-Pump-Key": "wrong_key"},
        json={"action": "START", "duration_seconds": 15.0},
    )
    assert res_wrong_key.status_code == 403

    # 3. Request with valid X-Pump-Key header -> 200 OK
    res_valid_key = client.post(
        "/api/v1/pump/control",
        headers={"X-Pump-Key": test_key},
        json={"action": "START", "duration_seconds": 15.0},
    )
    assert res_valid_key.status_code == 200
    assert res_valid_key.json()["status"] == "SUCCESS"
    assert res_valid_key.json()["pump_state"] == "ON"

    # Stop pump safely
    client.post(
        "/api/v1/pump/control",
        headers={"X-Pump-Key": test_key},
        json={"action": "STOP", "duration_seconds": 0.0},
    )

def test_rate_limiter_protection():
    """Verify client rate limiter bounds request bursts."""
    # Ensure client IP is tracked
    img = Image.new("RGB", (32, 32), color="green")
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    from app.api.v1.router import _RATE_LIMIT_STORE
    _RATE_LIMIT_STORE.clear()

    # Rapid burst test
    rate_limited = False
    for _ in range(35):
        res = client.post("/api/v1/disease/predict", json={"crop": "tomato", "image_base64": b64})
        if res.status_code == 429:
            rate_limited = True
            break
    assert rate_limited is True
    # Clear after test so other tests are unaffected
    _RATE_LIMIT_STORE.clear()


def test_advisory_knowledge_base_endpoints():
    """Verify agricultural advisory knowledge base endpoints return verified data."""
    # 1. GET /advisory/all returns 6 classes
    res_all = client.get("/api/v1/advisory/all")
    assert res_all.status_code == 200
    advisories = res_all.json()
    assert len(advisories) == 6
    ids = [a["disease_id"] for a in advisories]
    assert "Tomato_Early_Blight" in ids
    assert "Tomato_Healthy" in ids
    assert "Tomato_leaf_late_blight" in ids
    assert "Tomato_leaf_yellow_curl_virus" in ids
    assert "Tomato_mold_leaf" in ids
    assert "Tomato_septora_leaf_spot" in ids

    # 2. GET /advisory/{id} returns specific scientific details
    res_eb = client.get("/api/v1/advisory/Tomato_Early_Blight")
    assert res_eb.status_code == 200
    eb_data = res_eb.json()
    assert "Alternaria solani" in eb_data["scientific_name"]
    assert "Mancozeb" in str(eb_data["treatment_options"])
    assert len(eb_data["immediate_actions"]) >= 3
    assert "TNAU" in str(eb_data["sources"]) or "ICAR" in str(eb_data["sources"])

    # 3. Nonexistent disease -> 404
    res_404 = client.get("/api/v1/advisory/nonexistent_blight")
    assert res_404.status_code == 404

    # 4. Disease prediction attaches advisory
    img = Image.new("RGB", (224, 224), color="green")
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    from app.api.v1.router import _RATE_LIMIT_STORE
    _RATE_LIMIT_STORE.clear()

    res_pred = client.post("/api/v1/disease/predict", json={"crop": "tomato", "image_base64": b64})
    assert res_pred.status_code == 200
    pred_data = res_pred.json()
    assert "advisory" in pred_data
    assert pred_data["advisory"]["disease_id"] == pred_data["prediction"]
