# ESPHome workflow via Docker, no local install needed.
# Switch ESPHome version: ESPHOME_VERSION=2024.6.0 just <recipe>

image := "ghcr.io/esphome/esphome"
version := env_var_or_default("ESPHOME_VERSION", "latest")
status_file := "devices.status"
serial_device := "/dev/ttyUSB0"
# no pinned version: always pull the newest "latest" before building.
# pinned version: tags are immutable, no need to re-check the registry.
pull := if version == "latest" { "always" } else { "missing" }

# no argument: list recipes
default:
    @just --list

# validate a config without building it
check device:
    docker run --rm --pull {{pull}} -v "$(pwd)":/config {{image}}:{{version}} config {{device}}

# build only, don't flash
build device:
    docker run --rm --pull {{pull}} -v "$(pwd)":/config {{image}}:{{version}} compile {{device}}

# build and flash via USB (interactive); port e.g. /dev/ttyUSB0 or /dev/ttyACM0
flash device port=serial_device:
    docker run --rm -it --pull {{pull}} --device {{port}} -v "$(pwd)":/config --network host \
        {{image}}:{{version}} run {{device}} --device {{port}}

# update a single device via OTA (must already be running, reachable on Wi-Fi)
update device:
    docker run --rm --pull {{pull}} -v "$(pwd)":/config --network host \
        {{image}}:{{version}} run {{device}} --device OTA --no-logs

# connect to a running device over the network and stream its logs
logs device:
    docker run --rm -it --pull {{pull}} -v "$(pwd)":/config --network host \
        {{image}}:{{version}} logs {{device}} --device OTA

# update all devices listed in devices.status via OTA
update-active:
    #!/usr/bin/env bash
    set -euo pipefail
    grep -vE '^[[:space:]]*(#|$)' {{status_file}} | while read -r cfg; do
        echo "=== Update: $cfg ==="
        docker run --rm --pull {{pull}} -v "$(pwd)":/config --network host {{image}}:{{version}} run "$cfg" --device OTA --no-logs
    done
