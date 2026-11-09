# birb

Servo-driven bird toy ("Birb"), position controlled via a Home Assistant
number entity.

- **Board:** ESP32-C3 Super Mini
- **Framework:** esp-idf
- **Status:** testing
- **Components:** `output` (ledc), `servo`, `number`

Two configs live here:

- `birb.yaml` - simple version, servo moves directly via
  `transition_length`. **Currently the one actually flashed** on the device.
- `birb-with-smooth.yaml` - newer variant: a `script` with an eased
  (cosine) motion curve over 100 steps for a more natural-looking move,
  plus `captive_portal`. Not yet flashed/committed as the active version.

`output_power: 8.5dB` is a known fix for the weak Wi-Fi reception these
ESP32-C3 Super Minis have.
