import assert from "node:assert/strict";
import test from "node:test";

import { sanitizeNotificationSettings } from "./notificationSettings.ts";

test("omitted soundEnabled sanitizes to true so existing v2 storage still plays audio", () => {
  const settings = sanitizeNotificationSettings({
    desktopEnabled: true,
    slotAlertsEnabled: { mention: true },
  });
  assert.equal(settings.soundEnabled, true);
  assert.equal(settings.slotAlertsEnabled.mention, true);
});

test("explicit soundEnabled false is preserved without clearing visual slots", () => {
  const settings = sanitizeNotificationSettings({
    desktopEnabled: true,
    soundEnabled: false,
    slotAlertsEnabled: {
      mention: true,
      dm: true,
      thread_reply: false,
      needs_action: true,
    },
  });
  assert.equal(settings.soundEnabled, false);
  assert.equal(settings.slotAlertsEnabled.mention, true);
  assert.equal(settings.slotAlertsEnabled.dm, true);
  assert.equal(settings.slotAlertsEnabled.thread_reply, false);
});

test("non-object storage falls back to defaults including soundEnabled true", () => {
  assert.equal(sanitizeNotificationSettings(null).soundEnabled, true);
  assert.equal(sanitizeNotificationSettings("x").soundEnabled, true);
});
