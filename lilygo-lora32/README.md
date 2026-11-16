# Sensus iPERL Water Meter via wM-Bus in Home Assistant

ESPHome configuration that receives a **Sensus iPERL** water meter over Wireless M-Bus (868 MHz) with a **LilyGO T3 LoRa32 V1.6.1**, decrypts it directly on the ESP32, and delivers the meter reading to Home Assistant.

Status: **working**. Meter reading, decryption, and the Home Assistant integration are running. Still open is a correct display of radio signal strength (see [Known Issues](#known-issues)). The AES key must be requested from the utility beforehand.

---

## Contents

- [Hardware](#hardware)
- [Software](#software)
- [Setup](#setup)
- [Home Assistant Entities](#home-assistant-entities)
- [Display](#display)

---

## Hardware

| Part | Details |
|---|---|
| Board | LilyGO T3 LoRa32 **V1.6.1** (ESP32, SX1276, 0.96" OLED SSD1306) |
| Radio module | SX1276, **868 MHz variant** (the 433 MHz variant does not work) |
| Antenna | 868 MHz antenna on the board connector |
| Meter | Sensus iPERL with wM-Bus radio, AES-128 encrypted |

### Pinout (T3 V1.6.1)

---

## Software

| Software | Version |
|---|---|
| ESPHome | 2026.10.2 |
| Framework | esp-idf |
| wM-Bus component | [SzczepanLeon/esphome-components](https://github.com/SzczepanLeon/esphome-components) `@main`, reports as `v5.1.7-1.19.0-fe1b1e0` |
| Home Assistant | 2026.11 |

The component consists of `wmbus_common` (wmbusmeters drivers), `wmbus_radio` (the radio chip), and `wmbus_meter` (meter and sensors). The older `version_4` branch with the single `wmbus` component only supports the CC1101 and can't be used here.

Decryption happens **on the ESP32**. Home Assistant receives the finished values over the native ESPHome API - no MQTT needed.

---

## Setup

The meter ID and the AES key are never hardcoded in the yaml - both only ever live in `secrets.yaml` (see the repo root's `secrets.yaml.rename` for the template):

```yaml
iperl_key: "..."        # 32 hex characters from the utility (AES-128 key)
iperl_meter_id: 0x...    # meter ID, see the nameplate/radio telegram
iperl_frame_id: "..."    # same ID, manufacturer prefix + byte-reversed
```

**Deriving `iperl_frame_id`:** Sensus devices transmit with the manufacturer
prefix `ae4c` in the telegram, followed by the meter ID's 4 bytes in
**reverse order**. Take `iperl_meter_id` as 4 hex bytes and reverse their
order, then prepend `ae4c`. Example: meter ID `0x12345678` (bytes `12 34 56
78`) reversed is `78 56 34 12`, so `iperl_frame_id` is `"ae4c78563412"`.

This value is only used to tally "telegrams from our meter" vs. all
received telegrams (the `Telegramme vom Zähler`/`Nicht entschlüsselt`
sensors and the display) via a simple substring search on the raw frame.
**If it's missing or wrong, those counters stay at 0 and telegrams won't be
counted correctly** - the actual meter reading still decodes fine via
`wmbus_meter`, since that uses `iperl_meter_id` and `iperl_key` directly and
doesn't depend on `iperl_frame_id` at all.

---

## Home Assistant Entities

| Entity | Meaning |
|---|---|
| **Stand** (Reading) | Meter reading in m³ (`device_class: water`, `total_increasing`), suitable for the Energy dashboard |
| Max. Durchfluss (Max. Flow) | Flow rate from the meter in m³/h. Marked as an instantaneous value in the telegram; with one telegram per hour this is just a single sample |
| Funksignal (Signal) | Signal strength per the component - **currently unusable**, see Known Issues |
| Telegramme gesamt (Total Telegrams) | All wM-Bus telegrams received since boot (including other devices) |
| Telegramme vom Zähler (Telegrams From Meter) | Of those, from our own meter |
| Nicht entschlüsselt (Not Decoded) | Meter telegrams without a decoded value (hints at a wrong key) |
| Display | Switch for the OLED (only with the display package) |

The "telegram" counters reset to 0 after every restart. The meter reading itself is not lost - it arrives complete again with every telegram.

### Evaluating consumption

- **Energy dashboard:** Settings → Dashboards → Energy → Water consumption → "Stand". This gives hourly, daily, and monthly bars.
- **Utility meter helper** with a daily or monthly cycle, e.g. for "water today".
- **No derivative sensor:** with one telegram per hour, a computed rate would jump sharply. If the reading stays the same, Home Assistant doesn't recompute and may show a stale consumption value for hours.

---

## Display

The display package `wasserzaehler-display.yaml` shows:

```
58.859 m3
Zaehler 10  ok 10
vor 8s  -64 dBm
Alle 230  vor 3s
OK
```

| Line | Content |
|---|---|
| 1 | Last decoded meter reading |
| 2 | Meter telegrams / of those decoded |
| 3 | Age and RSSI of the last meter telegram (RSSI currently unusable) |
| 4 | All telegrams and age of the last one |
| 5 | Status: `warte auf Funk` (waiting for radio), `Funk OK, warte` (radio OK, waiting), `OK`, `FEHLER Entschl.` (decode error) |

**Turning on and off:**

- At runtime: the "Display" switch in Home Assistant, or the BOOT button on the board. The state persists across a restart.
- At compile time: comment out the `display: !include wasserzaehler-display.yaml` line in `wasserzaehler.yaml`.

**Interference:** transmitting to the display over I²C interferes with radio reception. At 50 kHz I²C and a 500 ms update interval, interference bursts of about 217 ms and down to −85 dBm occurred - i.e. nearly half the time. That's why I²C runs at **400 kHz** and the display only updates **every 5 s**. When the display is off, nothing is transmitted at all. An SSD1306 keeps showing its last image without being driven.
