import os
import tempfile
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker

from app.db.base import Base
from app.db.models import SensorReading, DiseasePrediction

def test_sqlite_persistence_across_backend_restart():
    """
    Verify records written to the SQLite database file persist across
    engine shutdown and restart.
    """
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as tmp:
        db_path = tmp.name

    db_url = f"sqlite:///{db_path}"
    
    try:
        # Phase 1: Initialize DB and write records
        engine1 = create_engine(db_url, connect_args={"check_same_thread": False})
        Base.metadata.create_all(bind=engine1)
        Session1 = sessionmaker(bind=engine1)
        
        with Session1() as session:
            sensor = SensorReading(
                soil_moisture=38.4,
                temperature=24.1,
                humidity=72.0,
                light_intensity=8900.0,
                source="esp32",
            )
            prediction = DiseasePrediction(
                crop="tomato",
                predicted_disease="Tomato_Healthy",
                confidence=0.985,
                class_probabilities={"Tomato_Healthy": 0.985},
            )
            session.add_all([sensor, prediction])
            session.commit()
            
            saved_sensor_id = sensor.id
            saved_pred_id = prediction.id

        # Simulate complete server shutdown
        engine1.dispose()

        # Phase 2: Start new engine connection (backend restart)
        engine2 = create_engine(db_url, connect_args={"check_same_thread": False})
        Session2 = sessionmaker(bind=engine2)
        
        with Session2() as session:
            # Query back sensor
            stmt1 = select(SensorReading).where(SensorReading.id == saved_sensor_id)
            reopened_sensor = session.scalars(stmt1).first()
            assert reopened_sensor is not None
            assert reopened_sensor.soil_moisture == 38.4
            assert reopened_sensor.source == "esp32"

            # Query back prediction
            stmt2 = select(DiseasePrediction).where(DiseasePrediction.id == saved_pred_id)
            reopened_pred = session.scalars(stmt2).first()
            assert reopened_pred is not None
            assert reopened_pred.predicted_disease == "Tomato_Healthy"
            assert reopened_pred.confidence == 0.985

        engine2.dispose()

    finally:
        if os.path.exists(db_path):
            try:
                os.remove(db_path)
            except OSError:
                pass

