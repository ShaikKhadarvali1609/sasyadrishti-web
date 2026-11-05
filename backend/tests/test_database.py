import os
from sqlalchemy import select, desc
from sqlalchemy.orm import Session
from app.db.base import Base
from app.db.models import SensorReading, DiseasePrediction, IrrigationLog, CropConfig
from app.db.session import init_db, get_db

def test_database_initialization(db_session: Session):
    """Verify all database tables exist and are accessible."""
    table_names = Base.metadata.tables.keys()
    assert "sensor_readings" in table_names
    assert "disease_predictions" in table_names
    assert "irrigation_logs" in table_names
    assert "crop_configs" in table_names

def test_sensor_reading_persistence(db_session: Session):
    """Verify persisting and querying a SensorReading."""
    reading = SensorReading(
        soil_moisture=42.5,
        temperature=26.3,
        humidity=65.0,
        light_intensity=12000.0,
        source="simulator",
    )
    db_session.add(reading)
    db_session.flush()

    assert reading.id is not None
    assert reading.soil_moisture == 42.5
    assert reading.source == "simulator"
    assert reading.timestamp is not None

    # Query back
    stmt = select(SensorReading).where(SensorReading.id == reading.id)
    retrieved = db_session.scalars(stmt).first()
    assert retrieved is not None
    assert retrieved.temperature == 26.3

def test_disease_prediction_persistence(db_session: Session):
    """Verify persisting and querying a DiseasePrediction."""
    pred = DiseasePrediction(
        crop="tomato",
        predicted_disease="Tomato_Early_Blight",
        confidence=0.912,
        class_probabilities={
            "Tomato_Early_Blight": 0.912,
            "Tomato_Healthy": 0.088,
        },
        image_filename="sample_leaf.jpg",
    )
    db_session.add(pred)
    db_session.flush()

    assert pred.id is not None
    stmt = select(DiseasePrediction).where(DiseasePrediction.id == pred.id)
    retrieved = db_session.scalars(stmt).first()
    assert retrieved is not None
    assert retrieved.predicted_disease == "Tomato_Early_Blight"
    assert retrieved.class_probabilities["Tomato_Early_Blight"] == 0.912

def test_irrigation_log_persistence(db_session: Session):
    """Verify persisting and querying an IrrigationLog."""
    log = IrrigationLog(
        crop="tomato",
        growth_stage="flowering",
        soil_moisture=35.0,
        water_required_mm=4.5,
        water_required_liters_per_m2=4.5,
        pump_duration_seconds=90.0,
        calculation_method="FAO-56 Penman-Monteith",
    )
    db_session.add(log)
    db_session.flush()

    assert log.id is not None
    stmt = select(IrrigationLog).where(IrrigationLog.id == log.id)
    retrieved = db_session.scalars(stmt).first()
    assert retrieved is not None
    assert retrieved.water_required_mm == 4.5
    assert retrieved.pump_duration_seconds == 90.0

def test_crop_config_persistence(db_session: Session):
    """Verify persisting and querying CropConfig."""
    cfg = CropConfig(
        crop_name="tomato",
        growth_stage="mid-season",
        kc_value=1.15,
        root_depth_m=0.7,
        soil_depletion_fraction=0.4,
    )
    db_session.add(cfg)
    db_session.flush()

    assert cfg.id is not None
    stmt = select(CropConfig).where(CropConfig.crop_name == "tomato")
    retrieved = db_session.scalars(stmt).first()
    assert retrieved is not None
    assert retrieved.kc_value == 1.15

def test_history_retrieval_and_ordering(db_session: Session):
    """Verify ordering and limit constraints on historical records."""
    for i in range(5):
        reading = SensorReading(
            soil_moisture=40.0 + i,
            temperature=25.0 + i,
            humidity=60.0,
            light_intensity=1000.0,
            source="test",
        )
        db_session.add(reading)
    db_session.flush()

    stmt = select(SensorReading).order_by(desc(SensorReading.timestamp), desc(SensorReading.id)).limit(3)
    results = db_session.scalars(stmt).all()
    assert len(results) == 3
    # Most recently added has highest id
    assert results[0].id > results[1].id > results[2].id

from unittest.mock import patch

def test_session_cleanup():
    """Verify database session dependency cleanup invokes close()."""
    gen = get_db()
    session = next(gen)
    assert session is not None
    with patch.object(session, "close", wraps=session.close) as mock_close:
        try:
            next(gen)
        except StopIteration:
            pass
        mock_close.assert_called_once()
