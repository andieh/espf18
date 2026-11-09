# Soundbar IR Control (M5Stack Atom Lite)

## Goal

Switch the JBL Bar 5.0 input (mainly to Bluetooth) from Home Assistant. Google Cast covers play/pause/volume but not input selection; HDMI-CEC and the JBL_Soundbar integration don't help, so IR is used.

## Hardware

| Part | Notes |
|---|---|
| M5Stack Atom Lite (ESP32) | Built-in IR LED on GPIO12, Grove port GPIO26/GPIO32 |
| M5Stack IR Unit U002 | IR TX + RX, Grove; RX = GPIO32, TX = GPIO26 |
| SFH415 + BC547 | Planned final IR sender on Grove GPIO26 |
| Seeed Grove to Dupont cable | To connect the SFH415 circuit to the Grove port |

### SFH415 driver

```
5V ── 47 Ω ── LED anode
              LED cathode ── BC547 collector
GPIO26 ── 1 kΩ ── BC547 base
              BC547 emitter ── GND
```

~75 mA pulsed. Don't go below 47 Ω; use a BC337 for more current.

## Firmware

File: `m5stack-atom-lite-ir.yaml`

- Board `m5stack-atom`, friendly name "Soundbar IR", 8 template buttons
- `ir_tx_pin` substitution: `GPIO26` (IR Unit / SFH415) or `GPIO12` (built-in LED)
- `remote_receiver` on GPIO32 stays in for re-learning (`dump: nec`)
- Buttons send raw Pronto frames (main frame + repeat frame)
- Secrets: `wifi_ssid`, `wifi_password`, `api_encryption_key`, `ota_password`

## Learned codes

| Button | NEC address | NEC command |
|---|---|---|
| Power | 0x7484 | 0x00FF |
| TV | 0x7080 | 0x46B9 |
| Bluetooth | 0x7080 | 0x45BA |
| Atmos | 0x7080 | 0x52AD |
| HDMI | 0x7080 | 0x0DF2 |
| Vol + | 0x7080 | 0x38C7 |
| Vol − | 0x7080 | 0x37C8 |
| Mute | 0x7080 | 0x3EC1 |

Pronto repeat frame: `0000 006D 0002 0000 0159 0056 0015 0181`
Full Pronto main frames are in the YAML (verified against the learn log).

Power uses a different address than all other keys; re-learn if it doesn't work.

## Status

- NEC version: IR LED fires (visible on phone camera), soundbar does not react, even at 50 cm.

## Next steps

1. Flash via `--device <IP>`, test "Bluetooth" at ~50 cm.
2. If no reaction: check the receiver still decodes the JBL remote (`Received NEC: address=0x7080, command=0x45BA`), then try the built-in LED (`ir_tx_pin: GPIO12`).
3. Once it works: replace `name_add_mac_suffix` with a fixed name.
4. Final install: swap IR Unit for SFH415 circuit, aim at the soundbar's front center.
