# Spec: #8118 Sound Off must not disable visual desktop alerts

Status: APPROVED (design review round 1)

## Problem

The Notifications **Sound** switch calls `setAllSlotAlertsEnabled`, which
zeros every live `slotAlertsEnabled` row. Desktop banners are gated on those
rows, so Sound Off silences **and** suppresses visual alerts while Desktop
alerts still reads On.

## Decision

Add `soundEnabled: boolean` (default `true`; missing on v2 storage sanitizes
to `true`). The Sound switch writes only that flag. Per-event
`slotAlertsEnabled` rows keep controlling visual eligibility. Alert-sound
delivery calls `playAlertSoundIfEnabled`, which no-ops when `soundEnabled` is
false. SoundPicker preview still uses ungated `playNotificationSound`.

Do not bump the storage key. Keep `setAllSlotAlertsEnabled` in the hook; stop
using it from the Sound switch.

## Non-goals

OS permission changes, mobile, new notification kinds, or a v3 storage key.

## Tests

- Sanitize: omitted `soundEnabled` → true; explicit false stays false.
- `playAlertSoundIfEnabled({ soundEnabled: false }, …)` does not construct Audio.
- Sound Off does not require `slotAlertsEnabled.mention === false`.
