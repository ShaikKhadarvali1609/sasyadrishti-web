import base64
import io
import pytest
from PIL import Image
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas import (
    SensorDataCreate,
    DiseasePredictRequest,
    IrrigationCalculateRequest,
    PumpControlRequest,
)
from app.api.v1.router import (
    record_sensor_data,
    get_latest_sensor_reading,
    get_sensor_history,
    disease_predict,
    get_disease_history,
    get_weather,
    calculate_irrigation_recommendation,
    get_irrigation_history,
    control_pump,
    get_pump_status,
    get_research_metrics,
)

def _create_test_image_b64() -> str:
    img = Image.new("RGB", (224, 224), color="green")
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")

def test_sensor_data_ingestion_and_retrieval(db_session: Session):
    """Test POST /sensors/data and GET /sensors/latest and /sensors/history."""
    with pytest.raises(HTTPException) as exc_info:
        get_latest_sensor_reading(db=db_session)
    assert exc_info.value.status_code == 404

    payload = SensorDataCreate(
        soil_moisture=45.2,
        temperature=27.8,
        humidity=68.0,
        light_intensity=15400.0,
        source="esp32",
    )
    saved = record_sensor_data(data=payload, db=db_session)
    assert saved.id is not None
    assert saved.soil_moisture == 45.2
    assert saved.source == "esp32"
    assert saved.timestamp is not None

    latest = get_latest_sensor_reading(db=db_session)
    assert latest.id == saved.id
    assert latest.soil_moisture == 45.2

    history = get_sensor_history(limit=10, db=db_session)
    assert len(history) >= 1
    assert history[0].id == saved.id

def test_disease_predict_and_persistence(db_session: Session):
    """Test POST /disease/predict and GET /disease/history."""
    b64_image = _create_test_image_b64()
    req = DiseasePredictRequest(
        crop="tomato",
        image_base64=b64_image,
    )
    
    res = disease_predict(req=req, db=db_session)
    
    assert res["status"] in ["SUCCESS", "UNCERTAIN"]
    assert "prediction" in res
    assert "confidence" in res
    assert "probabilities" in res
    assert "class_names" in res
    assert len(res["class_names"]) == 6
    assert len(res["probabilities"]) == 6

    history = get_disease_history(limit=5, db=db_session)
    assert len(history) >= 1
    latest_record = history[0]
    assert latest_record.crop == "tomato"
    assert latest_record.predicted_disease == res["prediction"]
    assert abs(latest_record.confidence - res["confidence"]) < 1e-4
    assert isinstance(latest_record.class_probabilities, dict)

def test_disease_predict_validation_errors(db_session: Session):
    """Test error handling on unsupported crop and corrupt image."""
    b64_image = _create_test_image_b64()

    with pytest.raises(HTTPException) as exc_crop:
        disease_predict(req=DiseasePredictRequest(crop="rice", image_base64=b64_image), db=db_session)
    assert exc_crop.value.status_code == 400

    with pytest.raises(HTTPException) as exc_img:
        disease_predict(req=DiseasePredictRequest(crop="tomato", image_base64="invalid_b64"), db=db_session)
    assert exc_img.value.status_code == 400

def test_weather_endpoint():
    """Test GET /weather/current returns valid schema and coordinates."""
    weather = get_weather(latitude=12.9716, longitude=77.5946)
    assert "status" in weather
    assert "source" in weather
    assert weather["latitude"] == 12.9716
    assert weather["longitude"] == 77.5946

def test_irrigation_recommendation_and_persistence(db_session: Session):
    """Test POST /irrigation/calculate with FAO-56 calculations and DB persistence."""
    req = IrrigationCalculateRequest(
        crop="tomato",
        growth_stage="flowering",
        soil_moisture=38.0,
        field_area_m2=15.0,
        latitude=12.9716,
        longitude=77.5946,
    )
    res = calculate_irrigation_recommendation(req=req, db=db_session)
    assert res["crop"] == "tomato"
    assert res["kc_value"] == 1.15
    assert res["water_required_mm"] > 0.0
    assert res["total_water_liters"] > 0.0
    assert res["pump_duration_seconds"] > 0.0

    # Verify persisted in IrrigationLog
    history = get_irrigation_history(limit=5, db=db_session)
    assert len(history) >= 1
    latest = history[0]
    assert latest.crop == "tomato"
    assert latest.soil_moisture == 38.0
    assert latest.water_required_mm == res["water_required_mm"]

def test_safe_pump_control():
    """Test manual pump start, status query, and manual stop."""
    # Start pump for 15s
    start_req = PumpControlRequest(action="START", duration_seconds=15.0)
    start_res = control_pump(req=start_req)
    assert start_res["status"] == "SUCCESS"
    assert start_res["pump_state"] == "ON"
    assert start_res["duration_seconds"] == 15.0

    # Status check
    status_res = get_pump_status()
    assert status_res["pump_state"] == "ON"
    assert status_res["duration_seconds"] > 0.0

    # Stop pump
    stop_req = PumpControlRequest(action="STOP")
    stop_res = control_pump(req=stop_req)
    assert stop_res["pump_state"] == "OFF"

    # Status after stop
    final_status = get_pump_status()
    assert final_status["pump_state"] == "OFF"

def test_research_metrics_endpoint():
    """Test GET /research/metrics returns authentic model evaluation data."""
    metrics = get_research_metrics()
    assert metrics["architecture"] == "MobileNetV3-Small"
    assert metrics["parameter_count"] > 900000
    assert metrics["num_classes"] == 6
    assert metrics["validation_accuracy_percent"] == 88.33
    assert metrics["f1_score_macro"] == 0.8842
    assert "confusion_matrix" in metrics
    assert len(metrics["class_names"]) == 6
