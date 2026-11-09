# audio-esp – ESPHome audio output for Home Assistant

ESP32-S3 board with two onboard MAX98357A amplifiers, exposed as a `media_player` in Home Assistant (door chime, notification sounds, TTS).

## Hardware

- **Board:** YelloByte YB-ESP32-S3-AMP (ESP32-S3, 2 MB PSRAM in **QUAD** mode, 2× MAX98357A onboard)
- **I2S pins (hard-wired):** BCLK = GPIO5, LRCLK = GPIO6, DIN = GPIO7
- **Speaker:** 4–8 Ω on the screw terminals (max. ~3.2 W at 4 Ω). Do **not** bridge the two amplifiers (they are not synchronized, risk of damage). For more volume, use an external amplifier (e.g. TPA3116D2).
- **Planned speaker:** Gira flush-mount speaker (8 Ω, 32 mm mounting depth). Verify compatibility before buying.

## USB ports

The board has two USB interfaces:

| Port | Chip | Purpose |
|---|---|---|
| `/dev/ttyACM1` | CH343 (`1a86:55d3`) | **Flashing** and logs (survives resets) |
| `/dev/ttyACM0` | native ESP32-S3 (`303a:1001`) | JTAG, drops on reset |

Device numbers may change. Check with `udevadm info -a -n /dev/ttyACMx | grep idVendor`.

## Config

Current config: `audio-esp.yaml`. Key points:

- `psram: mode: quad` (octal prevents booting).
- `logger: hardware_uart: UART0` routes logs through the CH343 port.
- `minimum_chip_revision` and `sram1_as_iram` exist only for the classic ESP32, not the S3.
- `media_player` (platform `speaker`): `buffer_size` goes directly on the `media_player`, **not** inside `announcement_pipeline`. Format `WAV`.
- `rtttl` plus the "Testton abspielen" button for a quick hardware test without the audio decoder.

## Home Assistant

- **TTS:** Install the **Piper** add-on (Settings → Add-ons → Add-on Store) and start it. It is discovered automatically via Wyoming (manual: host `localhost`, port `10200`). German voice, e.g. `de_DE-thorsten-medium`.
- **Announcement:**
  ```yaml
  action: tts.speak
  target:
    entity_id: tts.piper
  data:
    media_player_entity_id: media_player.tuergong
    message: "Es hat geklingelt"
    language: de
  ```
  After the hostname change the entity may have a different name (`media_player.audio_esp_…`); check Developer Tools → States.
- Home Assistant and the ESPHome firmware should be on similar versions to avoid connection problems.
