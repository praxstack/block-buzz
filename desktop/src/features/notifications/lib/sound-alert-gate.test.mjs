import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

import { playAlertSoundIfEnabled } from "./sound.ts";

const here = dirname(fileURLToPath(import.meta.url));

test("playAlertSoundIfEnabled does not construct Audio when Sound is off", () => {
  let constructed = 0;
  const OriginalAudio = globalThis.Audio;
  globalThis.Audio = class {
    constructor() {
      constructed += 1;
    }
    play() {
      return Promise.resolve();
    }
  };
  try {
    const result = playAlertSoundIfEnabled({ soundEnabled: false }, "flutter");
    assert.equal(result, null);
    assert.equal(constructed, 0);
  } finally {
    globalThis.Audio = OriginalAudio;
  }
});

test("alert delivery paths call playAlertSoundIfEnabled, not ungated playNotificationSound", () => {
  const files = [
    join(here, "../use-feed-desktop-notifications.ts"),
    join(here, "../../reminders/useReminderNotifications.ts"),
    join(here, "../../../app/useAppShellDesktopNotifications.ts"),
  ];
  for (const file of files) {
    const source = readFileSync(file, "utf8");
    assert.match(
      source,
      /playAlertSoundIfEnabled/,
      `${file} must gate alert audio on soundEnabled`,
    );
    assert.doesNotMatch(
      source,
      /playNotificationSound\(/,
      `${file} must not play ungated alert audio`,
    );
  }
});
