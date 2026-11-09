# ESP@F18

ESP@F18 device configs for various devices around my house. Each top-level
folder is one physical device plus multiple configurations. Builds run via
the official ESPHome Docker image, driven by a `justfile` - no local ESPHome
install needed. Using this its easy to update all devices at once. 

## Prerequisites

- Docker
- [`just`](https://github.com/casey/just)

## Secrets

Place the `secrets.yaml-rename` file in every folder you want to build.
For myself i created one `secrets.yaml` file and symlinked it to each folder.

## Usage (`just`)

```sh
just --list              # show all recipes
just check <yaml>        # validate a config, no build
just build <yaml>        # compile only, no flash
just flash <yaml> [port] # build + flash via USB (default port: /dev/ttyUSB0)
just update <yaml>       # OTA-update a single device
just update-active       # OTA-update everything listed in devices.status
```

Pin the ESPHome version per call: `ESPHOME_VERSION=2024.6.0 just build <yaml>`.

### `devices.status`

Plain text list of device configs considered "active" (deployed, kept up to
date). `just update-active` loops over exactly these paths. Anything **not**
listed there is implicitly "testing" - it only gets touched explicitly via
`just update <yaml>` or `just flash <yaml>`.

## Projects

| Folder | Purpose |
|---|---|
| [`audio_esp`](audio_esp/README.md) | ESP32-S3 doorbell, audio player, streaming target |
| [`birb`](birb/README.md) | ESP32-C3 servo toy display room climate, based on [birb the birdi](https://www.printables.com/model/450447-birb-the-birdie-shaped-air-quality-sensor) |
| [`bluetooth_proxy`](bluetooth_proxy/README.md) | ESP32 BLE proxy on ATOM Lite |
| [`doorcam`](doorcam/README.md) | ESP32-CAM door camera + OLED on a TTGO Camera Module |
| [`m5stack-atom-lite-ir`](m5stack-atom-lite-ir/README.md) | ESP32 IR remote for soundbar |
| [`room_climate`](room_climate/README.md) | room climate using SHT4x boards, ESP Super Mini and one ESP32 |
| [`temp_senser`](temp_senser/README.md) | ESP8266 underfloor heating + oil heater sensors using multiple DS18B20 sensors |

"active"/"testing" reflects `devices.status` at the time of writing - that
file is the source of truth, this table is just an overview.
