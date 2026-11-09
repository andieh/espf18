# Heating temperature sensors (ESPHome)

Two ESPHome nodes measure pipe temperatures of an oil-fired heating system
with underfloor heating (FBH). Data goes to Home Assistant via the native API.

| Node | ESPHome name | Probes | Location |
|---|---|---|---|
| Underfloor manifold | `fbh-temp-senser` | 12 | supply + return of 10 heating loops + total return |
| Boiler | `oil-heater-senser` | 7 | boiler flow/return, upstairs (OG) and basement (KG) circuits, flue pipe |

## Hardware

Per node:

- Wemos D1 mini (ESP8266), powered via USB 5 V
- DS18B20 waterproof probes (stainless steel sleeve, 1 m cable), all on one 1-Wire bus
- Pull-up resistor between DATA and 3V3
  - `fbh-temp-senser`: 4.7 kΩ
  - `oil-heater-senser`: 2 kΩ (2 × 1 kΩ in series, more probes and longer cables)

### Wiring

| DS18B20 wire | D1 mini pin |
|---|---|
| red (VDD) | 3V3 |
| black (GND) | GND |
| yellow (DATA) | D2 (GPIO4) |

All probes are connected in parallel (VDD, GND and DATA each joined).
No parasitic power.

### Mounting

- Pipe probes are placed on bare metal close to the manifold or boiler.
  They are held with a cable tie or hose clamp and covered with pipe insulation.
  They measure the pipe surface temperature, not the water temperature.
- Flue probe (`Abgas grob`) hangs freely about 5 cm above the flue pipe,
  without touching it, as a rough burner on/off signal. Keep it below 80 °C,
  because the PVC cable is not rated higher.
- `Vorlauf Brenner` sits about 50 cm after the boiler outlet. It is closer to
  boiler temperature while the pump runs, but cools down faster in standby.

## ESPHome configuration

Common parts (both nodes):

```yaml
esp8266:
  board: d1_mini

one_wire:
  - platform: gpio
    pin: D2

sensor:
  - platform: dallas_temp
    address: 0x...28        # from the boot log
    name: "Vorlauf"
    resolution: 12
    update_interval: 30s    # flue probe: 10s
    filters:
      - offset: 0.05        # from water-bath calibration
```

Further notes:

- **Finding addresses:** flash once with any dummy address. All probes found
  on the bus are listed in the boot log (`Found sensors: 0x…28`). Every
  DS18B20 address ends in `28` (family code).

## Calibration

All probes of one node were put into the same water bath and left until
stable (30 min, two temperature levels for the boiler node). Each offset is
the deviation from the mean of all probes of that node. After calibration,
all probes agree within ±0.05 K.

The two nodes are calibrated separately. A constant offset of about 0.1 K
between them is possible. This does not matter for the evaluations, because
they only compare probes within one node.

### fbh-temp-senser (calibrated 2026-11-06, ~23 °C)

| Name | Address | Offset (K) |
|---|---|---|
| Vorlauf | 0x9200000048961028 | +0.05 |
| Rücklauf HK 1 | 0x330000006e22f828 | −0.03 |
| Rücklauf HK 2 | 0x8500000048fb9028 | +0.17 |
| Rücklauf HK 3 | 0xc40000004932f428 | +0.06 |
| Rücklauf HK 4 | 0xd400000071220928 | −0.22 |
| Rücklauf HK 5 | 0x1900000071be1928 | −0.16 |
| Rücklauf HK 6 | 0xbd00000048e11e28 | +0.50 |
| Rücklauf HK 7 | 0xda00000049313e28 | −0.11 |
| Rücklauf HK 8 | 0xda00000048150928 | +0.27 |
| Rücklauf HK 9 | 0x6f0000004a8a2d28 | −0.13 |
| Rücklauf HK 10 | 0x010000004937dc28 | −0.10 |
| Rücklauf gesamt | 0x38000000711af628 | −0.30 |

### oil-heater-senser (calibrated 2026-11-08, ~22.5 °C and ~18 °C)

| Name | Address | Offset (K) |
|---|---|---|
| Vorlauf Brenner | 0xf500000048a74028 | +0.09 |
| Rücklauf Brenner | 0x8500000048399828 | −0.12 |
| Vorlauf OG | 0xee000000487a0428 | +0.05 |
| Rücklauf OG | 0xdb00000048216a28 | +0.01 |
| Vorlauf KG | 0x7e000000481e4128 | +0.02 |
| Rücklauf KG | 0xb800000048954d28 | −0.09 |
| Abgas grob | 0xdf00000048379328 | +0.04 |

## Home Assistant entities

- `sensor.fbh_temperature_senser_vorlauf`
- `sensor.fbh_temperature_senser_rucklauf_hk_1` … `_hk_10`
- `sensor.fbh_temperature_senser_rucklauf_gesamt`
- `sensor.oil_heater_temperature_senser_vorlauf_brenner`
- `sensor.oil_heater_temperature_senser_rucklauf_brenner`
- `sensor.oil_heater_temperature_senser_vorlauf_og`
- `sensor.oil_heater_temperature_senser_rucklauf_og`
- `sensor.oil_heater_temperature_senser_vorlauf_kg`
- `sensor.oil_heater_temperature_senser_rucklauf_kg`
- `sensor.oil_heater_temperature_senser_abgas_grob`
