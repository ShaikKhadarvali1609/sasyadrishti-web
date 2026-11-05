"""
SasyaDrishti — ESP32 Telemetry Simulator
=========================================
Generates realistic agricultural sensor readings and streams them to the FastAPI backend.
Use when physical ESP32 hardware is disconnected or for automated integration testing.

Usage:
    python scripts/simulate_esp32.py [--url http://127.0.0.1:8000] [--interval 5] [--count 10]
"""

import sys
import time
import math
import random
import argparse
import httpx

def run_simulation(backend_url: str, interval: float, max_count: int):
    endpoint = f"{backend_url.rstrip('/')}/api/v1/sensors/data"
    print(f"=== SasyaDrishti ESP32 Sensor Simulator ===")
    print(f"Target Endpoint : {endpoint}")
    print(f"Sampling Interval: {interval} seconds")
    print(f"Total Iterations : {'Continuous' if max_count == 0 else max_count}")
    print("Press Ctrl+C to stop.\n")

    # Initial agronomic conditions
    base_moisture = 48.0
    iteration = 0

    try:
        while True:
            iteration += 1
            # Diurnal temperature cycle simulation (22°C night to 31°C afternoon)
            hour_sim = (iteration * 0.5) % 24
            temp = 25.0 + 5.0 * math.sin(math.radians((hour_sim - 9) * 15)) + random.uniform(-0.5, 0.5)
            # Relative humidity inversely correlated with temperature (45% to 80%)
            hum = 65.0 - 15.0 * math.sin(math.radians((hour_sim - 9) * 15)) + random.uniform(-1.0, 1.0)
            hum = max(20.0, min(95.0, hum))
            
            # Solar radiation simulation (0 Lux at night, up to 45,000 Lux at noon)
            solar_factor = max(0.0, math.sin(math.radians((hour_sim - 6) * 15)))
            light = round(solar_factor * 40000.0 + random.uniform(50, 300), 1)

            # Soil moisture slowly depletes unless replenishment occurs
            base_moisture = max(25.0, base_moisture - random.uniform(0.1, 0.3))
            
            payload = {
                "soil_moisture": round(base_moisture, 1),
                "temperature": round(temp, 1),
                "humidity": round(hum, 1),
                "light_intensity": light,
                "source": "simulator",
            }

            try:
                with httpx.Client(timeout=4.0) as client:
                    resp = client.post(endpoint, json=payload)
                    if resp.status_code == 201:
                        data = resp.json()
                        print(f"[{data.get('timestamp', time.strftime('%X'))}] Sent: "
                              f"Moisture={payload['soil_moisture']}% | "
                              f"Temp={payload['temperature']}°C | "
                              f"Hum={payload['humidity']}% | "
                              f"Light={payload['light_intensity']} Lux -> DB ID: {data.get('id')}")
                    else:
                        print(f"[Error {resp.status_code}] Backend rejected data: {resp.text}")
            except httpx.ConnectError:
                print(f"[Offline] Cannot connect to {endpoint}. Is FastAPI server running?")
            except Exception as e:
                print(f"[Warning] Transmission error: {e}")

            if max_count > 0 and iteration >= max_count:
                print(f"\nCompleted {max_count} simulation iterations.")
                break

            time.sleep(interval)

    except KeyboardInterrupt:
        print("\nSimulator stopped by user.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SasyaDrishti ESP32 Sensor Simulator")
    parser.add_argument("--url", default="http://127.0.0.1:8000", help="FastAPI backend URL")
    parser.add_argument("--interval", type=float, default=5.0, help="Seconds between readings")
    parser.add_argument("--count", type=int, default=0, help="Number of readings to send (0 = infinite)")
    args = parser.parse_args()

    run_simulation(args.url, args.interval, args.count)

