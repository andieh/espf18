# tuergong

Doorbell/notification audio player - first-generation hardware for this job,
superseded by [`audio_esp`](../audio_esp/README.md) which has onboard amps
and PSRAM instead of externally wired I2S DACs.

- **Board:** esp32dev (ESP32)
- **Framework:** esp-idf (required for the `speaker`/`media_player` components)
- **Status:** testing
- **Components:** `i2s_audio`, `speaker`, `rtttl`, `media_player`

A "Testton abspielen" button plays a short square-wave test tone via
`rtttl`, without needing an audio decoder.
