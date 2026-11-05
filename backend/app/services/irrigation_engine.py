import math
from typing import Dict, Any, Optional

# FAO-56 Crop Coefficients (Kc) for Tomato
TOMATO_KC = {
    "initial": 0.60,       # Germination to early vegetative (~30 days)
    "flowering": 1.15,     # Mid-season / flowering / fruit set (~45 days)
    "mid-season": 1.15,    # Active fruit development (~45 days)
    "late-season": 0.80,   # Ripening and harvest (~30 days)
}

# Standard pump flow rate: 240 Liters/hour = 0.0667 Liters/second
DEFAULT_PUMP_FLOW_RATE_LPS = 0.0667  
MAX_SAFE_PUMP_SECONDS = 180.0  # Hardware watchdog limit per irrigation cycle

def calculate_hargreaves_et0(t_mean: float, t_max: float, t_min: float, ra_mm_day: float = 15.0) -> float:
    """
    Hargreaves-Samani equation for reference evapotranspiration ET0 (mm/day).
    Used as an agronomic fallback when solar radiation and wind speed are absent.
    Formula: ET0 = 0.0023 * Ra * (Tmean + 17.8) * sqrt(max(0, Tmax - Tmin))
    """
    temp_range = max(0.1, t_max - t_min)
    et0 = 0.0023 * ra_mm_day * (t_mean + 17.8) * math.sqrt(temp_range)
    return max(0.5, round(et0, 2))

def calculate_irrigation(
    crop: str = "tomato",
    growth_stage: str = "flowering",
    soil_moisture: float = 45.0,
    temperature: float = 26.0,
    relative_humidity: float = 60.0,
    precipitation_mm: float = 0.0,
    daily_et0_mm: Optional[float] = None,
    daily_temp_max: Optional[float] = None,
    daily_temp_min: Optional[float] = None,
    field_area_m2: float = 10.0,
    flow_rate_lps: float = DEFAULT_PUMP_FLOW_RATE_LPS,
) -> Dict[str, Any]:
    """
    Comprehensive FAO-56 Crop Evapotranspiration and Water Requirement Engine.
    
    Units:
    - ET0, ETc, Precipitation, Net Water: mm (1 mm = 1 Liter / m^2)
    - Total Volume: Liters
    - Pump Duration: Seconds
    """
    stage_key = growth_stage.lower().strip()
    kc = TOMATO_KC.get(stage_key, 1.0)

    # 1. Reference Evapotranspiration ET0
    if daily_et0_mm is not None and daily_et0_mm > 0.0:
        et0 = daily_et0_mm
        method_used = "FAO-56 Penman-Monteith (Open-Meteo)"
    elif daily_temp_max is not None and daily_temp_min is not None:
        t_mean = (daily_temp_max + daily_temp_min) / 2.0
        et0 = calculate_hargreaves_et0(t_mean, daily_temp_max, daily_temp_min)
        method_used = "Hargreaves-Samani (Temperature Range)"
    else:
        # Approximate using ambient temperature and relative humidity
        t_max = temperature + 4.0
        t_min = max(10.0, temperature - 6.0)
        et0 = calculate_hargreaves_et0(temperature, t_max, t_min)
        method_used = "Hargreaves-Samani (Estimated Diurnal Range)"

    # 2. Crop Evapotranspiration ETc = ET0 * Kc
    etc = round(et0 * kc, 2)

    # 3. Effective Rainfall Peff
    # Standard FAO formula: rainfall < 5mm is lost to surface interception
    if precipitation_mm > 5.0:
        p_eff = round(max(0.0, precipitation_mm * 0.8 - 2.0), 2)
    else:
        p_eff = 0.0

    # 4. Soil Moisture Deficit
    # Target optimal moisture for tomato: 65% relative moisture
    # Deficit factor: ~0.35 mm of water replenishment per 1% moisture deficit below 60%
    if soil_moisture < 60.0:
        deficit_mm = round((60.0 - soil_moisture) * 0.35, 2)
    else:
        deficit_mm = 0.0

    # 5. Net Irrigation Requirement (mm)
    # Water Required = max(0, ETc - Peff + Deficit)
    net_water_mm = round(max(0.0, etc - p_eff + deficit_mm), 2)

    # 6. Water Volume in Liters (1 mm over 1 m^2 = 1 Liter)
    liters_per_m2 = net_water_mm
    total_liters = round(liters_per_m2 * field_area_m2, 2)

    # 7. Pump Duration Calculation with Safety Watchdog
    if total_liters > 0.0 and flow_rate_lps > 0.0:
        raw_duration_sec = total_liters / flow_rate_lps
        pump_duration_seconds = round(min(MAX_SAFE_PUMP_SECONDS, raw_duration_sec), 1)
        safety_capped = raw_duration_sec > MAX_SAFE_PUMP_SECONDS
    else:
        pump_duration_seconds = 0.0
        safety_capped = False

    return {
        "crop": crop,
        "growth_stage": growth_stage,
        "kc_value": kc,
        "et0_mm": et0,
        "etc_mm": etc,
        "precipitation_mm": precipitation_mm,
        "effective_precipitation_mm": p_eff,
        "soil_moisture_percent": soil_moisture,
        "soil_deficit_mm": deficit_mm,
        "water_required_mm": net_water_mm,
        "water_required_liters_per_m2": liters_per_m2,
        "field_area_m2": field_area_m2,
        "total_water_liters": total_liters,
        "pump_flow_rate_lps": flow_rate_lps,
        "pump_duration_seconds": pump_duration_seconds,
        "safety_capped": safety_capped,
        "calculation_method": method_used,
    }

