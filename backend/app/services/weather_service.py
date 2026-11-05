import time
from typing import Dict, Any, Optional
import httpx

# In-memory weather cache to prevent rate-limiting: {cache_key: (timestamp, data)}
_WEATHER_CACHE: Dict[str, tuple[float, Dict[str, Any]]] = {}
_CACHE_TTL_SECONDS = 900  # 15 minutes

def get_live_weather(latitude: float = 12.9716, longitude: float = 77.5946) -> Dict[str, Any]:
    """
    Fetch live meteorological data from Open-Meteo free API.
    Returns temperature, humidity, precipitation, wind speed, solar radiation,
    and reference evapotranspiration (ET0).
    Honest network error handling: never fabricates values if unreachable.
    """
    cache_key = f"{latitude:.3f}_{longitude:.3f}"
    now = time.time()
    
    # Return valid cached data if within TTL
    if cache_key in _WEATHER_CACHE:
        cached_time, cached_data = _WEATHER_CACHE[cache_key]
        if now - cached_time < _CACHE_TTL_SECONDS:
            return cached_data

    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": "temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,surface_pressure,shortwave_radiation_instant",
        "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,et0_fao_evapotranspiration",
        "timezone": "auto",
        "forecast_days": 1,
    }

    try:
        with httpx.Client(timeout=6.0) as client:
            resp = client.get(url, params=params)
            if resp.status_code != 200:
                return {
                    "status": "UNAVAILABLE",
                    "source": "Open-Meteo",
                    "message": f"Weather API returned status code {resp.status_code}",
                    "latitude": latitude,
                    "longitude": longitude,
                }
            
            data = resp.json()
            current = data.get("current", {})
            daily = data.get("daily", {})

            # Extract daily FAO-56 Penman-Monteith ET0 if available
            daily_et0 = None
            if daily.get("et0_fao_evapotranspiration"):
                daily_et0 = float(daily["et0_fao_evapotranspiration"][0])

            result = {
                "status": "SUCCESS",
                "source": "Open-Meteo Live API",
                "latitude": latitude,
                "longitude": longitude,
                "temperature": current.get("temperature_2m"),
                "relative_humidity": current.get("relative_humidity_2m"),
                "precipitation_mm": current.get("precipitation", 0.0),
                "wind_speed_kmh": current.get("wind_speed_10m"),
                "surface_pressure_hpa": current.get("surface_pressure"),
                "solar_radiation_w_m2": current.get("shortwave_radiation_instant", 0.0),
                "daily_et0_mm": daily_et0,
                "daily_temp_max": daily.get("temperature_2m_max", [None])[0],
                "daily_temp_min": daily.get("temperature_2m_min", [None])[0],
                "daily_precip_sum_mm": daily.get("precipitation_sum", [None])[0],
                "timestamp": current.get("time"),
            }
            
            _WEATHER_CACHE[cache_key] = (now, result)
            return result

    except httpx.TimeoutException:
        return {
            "status": "UNAVAILABLE",
            "source": "Open-Meteo",
            "message": "Connection timed out while fetching weather data. Using offline defaults.",
            "latitude": latitude,
            "longitude": longitude,
        }
    except Exception as e:
        return {
            "status": "UNAVAILABLE",
            "source": "Open-Meteo",
            "message": f"Weather service unreachable: {str(e)}",
            "latitude": latitude,
            "longitude": longitude,
        }

