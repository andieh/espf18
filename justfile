# ESPHome workflow via Docker, no local install needed.
# Switch ESPHome version: ESPHOME_VERSION=2024.6.0 just <recipe>

image := "ghcr.io/esphome/esphome"
version := env_var_or_default("ESPHOME_VERSION", "latest")
status_file := "devices.status"
serial_device := "/dev/ttyUSB0"

# no argument: list recipes
default:
    @just --list

# validate a config without building it
check device:
    docker run --rm -v "$(pwd)":/config {{image}}:{{version}} config {{device}}

# build only, don't flash
build device:
    docker run --rm -v "$(pwd)":/config {{image}}:{{version}} compile {{device}}

# build and flash via USB (interactive); port e.g. /dev/ttyUSB0 or /dev/ttyACM0
flash device port=serial_device:
    docker run --rm -it --device {{port}} -v "$(pwd)":/config --network host \
        {{image}}:{{version}} run {{device}} --device {{port}}

# update a single device via OTA (must already be running, reachable on Wi-Fi)
update device:
    docker run --rm -v "$(pwd)":/config --network host \
        {{image}}:{{version}} run {{device}} --device OTA

# update all devices marked "active" in devices.status via OTA
update-active:
    #!/usr/bin/env bash
    set -euo pipefail
    grep -E '^active[[:space:]]' {{status_file}} | awk '{print $2}' | while read -r cfg; do
        echo "=== Update: $cfg ==="
        docker run --rm -v "$(pwd)":/config --network host {{image}}:{{version}} run "$cfg" --device OTA
    done
