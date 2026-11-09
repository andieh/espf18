# bluetooth_proxy

Bluetooth LE proxy for Home Assistant (extends BLE range/coverage).

- **Board:** M5Stack ATOM Lite, ESP32, 4MB flash
- **Framework:** esp-idf
- **Components:** `bluetooth_proxy`

Only project that configures a real Wi-Fi fallback AP
(`wifi.ap`), used if it can't join the main network.
