import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, ConfigDict

# Sensor Schemas
class SensorDataCreate(BaseModel):
    soil_moisture: float = Field(..., ge=0.0, le=100.0, description="Soil moisture percentage (0-100%)")
    temperature: float = Field(..., ge=-20.0, le=70.0, description="Temperature in Celsius")
    humidity: float = Field(..., ge=0.0, le=100.0, description="Relative humidity percentage (0-100%)")
    light_intensity: float = Field(..., ge=0.0, description="Ambient light intensity in Lux")
    source: str = Field(default="esp32", description="Data source: esp32 or simulator")

class SensorReadingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    soil_moisture: float
    temperature: float
    humidity: float
    light_intensity: float
    source: str
    timestamp: datetime.datetime

# Disease Prediction Schemas
class DiseasePredictRequest(BaseModel):
    crop: str = Field(..., description="Crop name, e.g., 'tomato'")
    image_base64: str = Field(..., description="Base64-encoded image data")

class DiseasePredictResponse(BaseModel):
    status: str
    prediction: Optional[str] = None
    confidence: Optional[float] = None
    probabilities: Optional[List[float]] = None
    class_names: Optional[List[str]] = None
    message: Optional[str] = None
    advisory: Optional[Dict[str, Any]] = None

class DiseaseAdvisoryResponse(BaseModel):
    disease_id: str
    crop: str
    common_name: str
    scientific_name: str
    pathogen_type: str
    severity: str
    severity_level: str
    explanation: str
    symptoms: List[str]
    causes: List[str]
    spread_mechanism: str
    favorable_conditions: List[str]
    immediate_actions: List[str]
    treatment_options: Dict[str, Any]
    fertilizer_guidance: Dict[str, str]
    prevention: List[str]
    when_to_seek_assistance: str
    sources: List[str]
    reviewed_at: str

class DiseasePredictionHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    crop: str
    predicted_disease: str
    confidence: float
    class_probabilities: Dict[str, Any]
    image_filename: Optional[str] = None
    timestamp: datetime.datetime

# Weather Schemas
class WeatherResponse(BaseModel):
    status: str
    source: str
    latitude: float
    longitude: float
    temperature: Optional[float] = None
    relative_humidity: Optional[float] = None
    precipitation_mm: Optional[float] = 0.0
    wind_speed_kmh: Optional[float] = None
    surface_pressure_hpa: Optional[float] = None
    solar_radiation_w_m2: Optional[float] = 0.0
    daily_et0_mm: Optional[float] = None
    daily_temp_max: Optional[float] = None
    daily_temp_min: Optional[float] = None
    daily_precip_sum_mm: Optional[float] = None
    timestamp: Optional[str] = None
    message: Optional[str] = None

# Irrigation Schemas
class IrrigationCalculateRequest(BaseModel):
    crop: str = Field(default="tomato", description="Crop name")
    growth_stage: str = Field(default="flowering", description="initial, flowering, mid-season, or late-season")
    soil_moisture: Optional[float] = Field(default=None, description="Optional sensor soil moisture override")
    field_area_m2: float = Field(default=10.0, ge=0.1, le=10000.0, description="Field area in square meters")
    latitude: float = Field(default=12.9716, description="Latitude for local weather")
    longitude: float = Field(default=77.5946, description="Longitude for local weather")

class IrrigationCalculateResponse(BaseModel):
    crop: str
    growth_stage: str
    kc_value: float
    et0_mm: float
    etc_mm: float
    precipitation_mm: float
    effective_precipitation_mm: float
    soil_moisture_percent: float
    soil_deficit_mm: float
    water_required_mm: float
    water_required_liters_per_m2: float
    field_area_m2: float
    total_water_liters: float
    pump_flow_rate_lps: float
    pump_duration_seconds: float
    safety_capped: bool
    calculation_method: str

class IrrigationLogResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    crop: str
    growth_stage: str
    soil_moisture: float
    water_required_mm: float
    water_required_liters_per_m2: float
    pump_duration_seconds: float
    calculation_method: str
    timestamp: datetime.datetime

# Pump Control Schemas
class PumpControlRequest(BaseModel):
    action: str = Field(..., description="Action: START or STOP")
    duration_seconds: float = Field(default=30.0, ge=1.0, le=180.0, description="Duration before auto-shutoff")

class PumpControlResponse(BaseModel):
    status: str
    pump_state: str  # ON, OFF
    duration_seconds: float
    message: str

# Research Metrics Schema
class ResearchMetricsResponse(BaseModel):
    architecture: str
    parameter_count: int
    model_size_mb: float
    num_classes: int
    class_names: List[str]
    input_resolution: str
    training_dataset: str
    validation_accuracy_percent: float
    mean_inference_latency_ms: float
    f1_score_macro: float
    confusion_matrix: Dict[str, Dict[str, int]]
