import datetime
from typing import Any, Dict, List, Optional
from sqlalchemy import Column, Integer, Float, String, DateTime, JSON, Index, func
from sqlalchemy.orm import Mapped, mapped_column
from .base import Base

class SensorReading(Base):
    __tablename__ = "sensor_readings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True, autoincrement=True)
    soil_moisture: Mapped[float] = mapped_column(Float, nullable=False)
    temperature: Mapped[float] = mapped_column(Float, nullable=False)
    humidity: Mapped[float] = mapped_column(Float, nullable=False)
    light_intensity: Mapped[float] = mapped_column(Float, nullable=False)
    source: Mapped[str] = mapped_column(String(50), nullable=False, default="esp32")
    timestamp: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

class DiseasePrediction(Base):
    __tablename__ = "disease_predictions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True, autoincrement=True)
    crop: Mapped[str] = mapped_column(String(50), nullable=False, default="tomato")
    predicted_disease: Mapped[str] = mapped_column(String(100), nullable=False)
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    class_probabilities: Mapped[Dict[str, Any]] = mapped_column(JSON, nullable=False)
    image_filename: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    timestamp: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

class IrrigationLog(Base):
    __tablename__ = "irrigation_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True, autoincrement=True)
    crop: Mapped[str] = mapped_column(String(50), nullable=False)
    growth_stage: Mapped[str] = mapped_column(String(50), nullable=False)
    soil_moisture: Mapped[float] = mapped_column(Float, nullable=False)
    water_required_mm: Mapped[float] = mapped_column(Float, nullable=False)
    water_required_liters_per_m2: Mapped[float] = mapped_column(Float, nullable=False)
    pump_duration_seconds: Mapped[float] = mapped_column(Float, nullable=False)
    calculation_method: Mapped[str] = mapped_column(String(100), nullable=False)
    timestamp: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

class CropConfig(Base):
    __tablename__ = "crop_configs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True, autoincrement=True)
    crop_name: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    growth_stage: Mapped[str] = mapped_column(String(50), nullable=False)
    kc_value: Mapped[float] = mapped_column(Float, nullable=False)
    root_depth_m: Mapped[float] = mapped_column(Float, nullable=False)
    soil_depletion_fraction: Mapped[float] = mapped_column(Float, nullable=False)
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

