/*
 * SasyaDrishti — ESP32 Smart Agriculture IoT Node Firmware
 * ========================================================
 * Target Board: ESP32 DevKit V1 (38-pin / 30-pin)
 * 
 * Hardware Wiring:
 * ----------------
 * 1. Capacitive Soil Moisture Sensor v1.2:
 *    - VCC  -> 3.3V (ESP32)
 *    - GND  -> GND  (ESP32)
 *    - AOUT -> GPIO 34 (ADC1_CH6 - analog only pin)
 * 
 * 2. DHT22 (AM2302) Temperature & Humidity Sensor:
 *    - Pin 1 (VCC)  -> 3.3V
 *    - Pin 2 (DATA) -> GPIO 4 (with 10k pull-up resistor to 3.3V)
 *    - Pin 4 (GND)  -> GND
 * 
 * 3. 5V Relay Module (Submersible Pump Control):
 *    - VCC -> 5V (VIN / External 5V Power Supply)
 *    - GND -> GND (Common ground with ESP32)
 *    - IN  -> GPIO 23
 *    * NOTE: Submersible pump must be powered from a dedicated 5V/12V DC power supply,
 *      NEVER directly from ESP32 3.3V pin to avoid brownout resets and inductive back-EMF!
 * 
 * 4. Status Indicator LED:
 *    - Built-in LED -> GPIO 2
 * 
 * Safety Features:
 * ----------------
 * - Hardware Watchdog Timer: Auto pump shutoff after MAX_PUMP_RUN_SECONDS (60s max)
 * - Wi-Fi disconnection failsafe: Pump immediately disabled if connection lost
 * - Analog sensor smoothing: 10-sample moving average on ADC
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

// ================= USER CONFIGURATION =================
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// IP address of the machine running the FastAPI backend (e.g., http://192.168.1.100:8000)
const char* BACKEND_URL   = "http://192.168.1.100:8000/api/v1/sensors/data";
const char* PUMP_STATUS_URL = "http://192.168.1.100:8000/api/v1/pump/status";

// ================= PIN DEFINITIONS ====================
#define SOIL_PIN        34   // Analog Input (ADC1)
#define DHT_PIN         4    // Digital Data Pin
#define RELAY_PIN       23   // Relay Control
#define LED_PIN         2    // Onboard Status LED

#define DHT_TYPE        DHT22

// ================= SAFETY LIMITS ======================
const unsigned long TELEMETRY_INTERVAL_MS = 10000;   // 10 seconds between posts
const unsigned long MAX_PUMP_RUN_SECONDS  = 60;      // Hard limit per watering cycle
const bool RELAY_ACTIVE_LOW               = true;    // True for most optocoupler relay boards

// ================= CALIBRATION VALUES =================
// Capacitive Soil Moisture Sensor calibration (12-bit ADC: 0 - 4095)
// Dry air reading ~ 3200, Submerged in water ~ 1400 (measure your specific probe)
const int SOIL_DRY_ADC = 3200;
const int SOIL_WET_ADC = 1400;

DHT dht(DHT_PIN, DHT_TYPE);
unsigned long lastTelemetryTime = 0;
unsigned long pumpStartTime = 0;
bool isPumpRunning = false;

void setPump(bool state) {
  if (state) {
    if (RELAY_ACTIVE_LOW) digitalWrite(RELAY_PIN, LOW);
    else digitalWrite(RELAY_PIN, HIGH);
    isPumpRunning = true;
    pumpStartTime = millis();
    digitalWrite(LED_PIN, HIGH);
    Serial.println("[PUMP] Activated ON");
  } else {
    if (RELAY_ACTIVE_LOW) digitalWrite(RELAY_PIN, HIGH);
    else digitalWrite(RELAY_PIN, LOW);
    isPumpRunning = false;
    pumpStartTime = 0;
    digitalWrite(LED_PIN, LOW);
    Serial.println("[PUMP] Deactivated OFF");
  }
}

float readSoilMoisturePercent() {
  long sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += analogRead(SOIL_PIN);
    delay(10);
  }
  float adcAvg = sum / 10.0;
  // Map raw ADC to 0% (dry) - 100% (saturated water)
  float percent = (float)(SOIL_DRY_ADC - adcAvg) / (float)(SOIL_DRY_ADC - SOIL_WET_ADC) * 100.0;
  return constrain(percent, 0.0, 100.0);
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n=== SasyaDrishti ESP32 IoT Node Initializing ===");

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  setPump(false); // Default SAFE OFF state

  dht.begin();
  analogReadResolution(12); // 12-bit ADC (0 - 4095)

  Serial.print("Connecting to Wi-Fi: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 20) {
    delay(500);
    Serial.print(".");
    retries++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[Wi-Fi] Connected successfully!");
    Serial.print("[Wi-Fi] IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[Wi-Fi] Warning: Connection failed. Operating in offline failsafe mode.");
  }
}

void loop() {
  unsigned long now = millis();

  // 1. HARDWARE SAFETY WATCHDOG
  if (isPumpRunning && (now - pumpStartTime >= MAX_PUMP_RUN_SECONDS * 1000)) {
    Serial.println("[SAFETY WATCHDOG] Max run duration reached. Shutting down pump!");
    setPump(false);
  }

  // 2. PERIODIC TELEMETRY DISPATCH
  if (now - lastTelemetryTime >= TELEMETRY_INTERVAL_MS) {
    lastTelemetryTime = now;

    float soilMoisture = readSoilMoisturePercent();
    float temperature = dht.readTemperature();
    float humidity = dht.readHumidity();

    if (isnan(temperature) || isnan(humidity)) {
      Serial.println("[DHT22] Warning: Failed to read from sensor!");
      temperature = 25.0; // Failsafe default
      humidity = 60.0;
    }

    float lightIntensity = 12000.0; // Ambient estimate or optional BH1750 I2C sensor

    Serial.printf("[SENSOR READINGS] Moisture: %.1f%% | Temp: %.1f C | Hum: %.1f%%\n",
                  soilMoisture, temperature, humidity);

    // Send HTTP POST to backend if Wi-Fi is active
    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      http.begin(BACKEND_URL);
      http.addHeader("Content-Type", "application/json");

      String payload = "{\"soil_moisture\":" + String(soilMoisture, 1) +
                       ",\"temperature\":" + String(temperature, 1) +
                       ",\"humidity\":" + String(humidity, 1) +
                       ",\"light_intensity\":" + String(lightIntensity, 1) +
                       ",\"source\":\"esp32\"}";

      int httpCode = http.POST(payload);
      if (httpCode > 0) {
        Serial.printf("[HTTP] POST telemetry succeeded: %d\n", httpCode);
      } else {
        Serial.printf("[HTTP] POST telemetry failed: %s\n", http.errorToString(httpCode).c_str());
      }
      http.end();

      // Check pump status from server
      HTTPClient httpStatus;
      httpStatus.begin(PUMP_STATUS_URL);
      int statusCode = httpStatus.GET();
      if (statusCode == 200) {
        String resp = httpStatus.getString();
        if (resp.indexOf("\"pump_state\":\"ON\"") != -1 && !isPumpRunning) {
          setPump(true);
        } else if (resp.indexOf("\"pump_state\":\"OFF\"") != -1 && isPumpRunning) {
          setPump(false);
        }
      }
      httpStatus.end();

    } else {
      // Disconnected: enforce safety shutoff
      if (isPumpRunning) {
        setPump(false);
      }
      Serial.println("[Wi-Fi] Disconnected, attempting reconnect...");
      WiFi.reconnect();
    }
  }

  delay(50);
}

