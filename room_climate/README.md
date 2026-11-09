# Room Climate Sensors (ESPHome)

Temperature/humidity sensors for Home Assistant: ESP32 + Sensirion SHT4x via I²C.

## Devices

| Config | Board | USB port | SDA | SCL |
|---|---|---|---|---|
| `room-climate.yaml` | ESP32-C3 Super Mini (native USB) | `/dev/ttyACM0` | GPIO4 | GPIO3 |
| `room-climate-1.yaml` | ESP32 DevKit V1, 30-pin (CP2102) | `/dev/ttyUSB0` | D21 | D22 |

## Sensor

- SHT4x breakout (SHT40/41), I²C address `0x44`, ±0.2 °C / ±1.8 % RH, ESPHome platform `sht4x`.
- Connectors are STEMMA QT/Qwiic (1.0 mm) – **not** Grove (2.0 mm). Use the 2.54 mm pin header with Dupont wires.
- Pin order differs between manufacturers – check the silkscreen labels.

## Wiring

| SHT4x | C3 Super Mini | DevKit V1 (right side, antenna up) |
|---|---|---|
| VIN | 3V3 | 3V3 (bottom pin) |
| GND | GND | GND (2nd from bottom) |
| SDA | GPIO4 | D21 (5th from top) |
| SCL | GPIO3 | D22 (2nd from top) |

Always 3.3 V – never 5V/VIN of the ESP. Avoid strapping pins (C3: GPIO2/8/9).

## Config structure

| Block | Purpose |
|---|---|
| `esphome` | `name` (hostname, unique per device) and `friendly_name` (HA display name) |
| `esp32` | board + `esp-idf` framework (C3: `esp32-c3-devkitm-1`, variant `esp32c3`; DevKit: `esp32dev`) |
| `logger` | C3: `hardware_uart: USB_SERIAL_JTAG` (logs via USB-C). DevKit: default (UART0 via CP2102) |
| `api` | encrypted HA connection |
| `ota` | password-protected OTA updates |
| `wifi` | no static IP, no `use_address` – address comes from a DHCP reservation. C3 only: `output_power: 8.5dB` (fix for weak WiFi) |
| `i2c` | SDA/SCL pins, `scan: true` logs found devices |
| `sensor` | `sht4x` (Temperature, Humidity, 60 s) + `wifi_signal` |

## Lessons learned

- **USB:** use a data cable (many are charge-only) and connect directly to the PC – a hub prevented detection.
- **C3 boot loop / port keeps reconnecting:** hold BOOT, press RST, release BOOT (download mode), then flash. Press RST afterwards.
- **C3 USB logs:** the native USB port re-enumerates on every reset, so log sessions drop. Prefer logs via WiFi; connecting via the API also prints the full config dump (I²C scan, sensor status).
- **`hardware_uart: UART0`** only makes sense on boards with a separate USB-serial chip – on the C3 Super Mini logs would go to the TX/RX pins.
- **Home Assistant shows an old device name:** HA identifies ESPHome devices by MAC. Delete the old entry under Settings → Devices & Services → ESPHome (also check the *Ignored* filter), then re-add.

## Measurement accuracy

- After handling or moving, the sensor needs 10–20 min to settle (thermal mass of board and wires, not a sensor warm-up).
- RH depends on temperature: +1 °C ≈ −3 % RH. Avoid heating the sensor rather than correcting it.
- Keep the sensor away from the ESP's heat: separate chambers with a partition wall, sensor below the ESP, vents in the sensor chamber, 3–5 cm thin wires. Starting point: [MakerWorld 2449935](https://makerworld.com/models/2449935) (ESP32-C3 Super Mini + SHT31, two chambers).
- Ceiling mount: air there is typically 1–2 °C warmer than at living height.
- Remaining constant offset can be corrected with `filters: - offset: -0.5` (temperature only).
- Optional: deep sleep (e.g. 30 s awake / 5 min asleep) nearly eliminates self-heating, but makes OTA/logs harder (use an HA `input_boolean` with `deep_sleep.prevent`).
- The red power LED on the C3 cannot be switched off in software (tape over or desolder); its heat is negligible.
