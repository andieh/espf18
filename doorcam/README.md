# doorcam

Door camera with a small OLED status display and PIR motion sensor. Movement turns on the display, camera image and stream can be integrated into Home Assistant. I also added a 3D printed enclosure, but its not ready yet and is not used so far. 

- **Board:** TTGO Camera Module
- **Framework:** arduino (the camera/display setup here predates the
  esp-idf-based configs used elsewhere in this repo)
- **Components:** `esp32_camera`, `ssd1306_i2c`, `font`, `binary_sensor` (PIR
  + physical button)

Notes:
- PSRAM in quad mode, 40MHz.
- Two I2C buses: `bus_a` (display) and `bus_b` (camera external clock).
- There's a second, commented-out `esp32_camera_web_server` block and a
  disabled motion-aware display lambda - left in as reference, not active.
