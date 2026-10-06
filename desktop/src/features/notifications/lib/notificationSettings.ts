import {
  DEFAULT_SLOT_ALERTS_ENABLED,
  DEFAULT_SLOT_SOUNDS,
  SOUND_NAMES,
  SOUND_SLOTS,
  type SlotSounds,
  type SoundName,
  type SoundSlot,
} from "./sound";

export type NotificationSettings = {
  desktopEnabled: boolean;
  homeBadgeEnabled: boolean;
  notifyWhileViewing: boolean;
  /**
   * Master audio preference. Independent of `slotAlertsEnabled`, which
   * gates visual banners. Missing values sanitize to true so existing v2
   * storage keeps playing sounds.
   */
  soundEnabled: boolean;
  sounds: SlotSounds;
  slotAlertsEnabled: Record<SoundSlot, boolean>;
  /**
   * Per-row state captured when the master switch bulk-disables, so turning
   * it back on restores the user's granular picks instead of enabling all.
   * Cleared by any individual row toggle.
   */
  slotAlertsSnapshot: Record<SoundSlot, boolean> | null;
};

export const DEFAULT_NOTIFICATION_SETTINGS: NotificationSettings = {
  desktopEnabled: true,
  homeBadgeEnabled: true,
  notifyWhileViewing: false,
  soundEnabled: true,
  sounds: { ...DEFAULT_SLOT_SOUNDS },
  slotAlertsEnabled: { ...DEFAULT_SLOT_ALERTS_ENABLED },
  slotAlertsSnapshot: null,
};

const SOUND_NAME_SET = new Set<SoundName>(SOUND_NAMES);

function sanitizeSoundsMap(value: unknown): SlotSounds {
  const result = { ...DEFAULT_SLOT_SOUNDS };
  if (!value || typeof value !== "object") return result;
  const candidate = value as Partial<Record<SoundSlot, unknown>>;
  for (const slot of SOUND_SLOTS) {
    const picked = candidate[slot];
    if (typeof picked === "string" && SOUND_NAME_SET.has(picked as SoundName)) {
      result[slot] = picked as SoundName;
    }
  }
  return result;
}

function sanitizeSlotAlertsEnabled(value: unknown): Record<SoundSlot, boolean> {
  const result = { ...DEFAULT_SLOT_ALERTS_ENABLED };
  if (!value || typeof value !== "object") return result;
  const candidate = value as Partial<Record<SoundSlot, unknown>>;
  for (const slot of SOUND_SLOTS) {
    const picked = candidate[slot];
    if (typeof picked === "boolean") {
      result[slot] = picked;
    }
  }
  return result;
}

export function sanitizeNotificationSettings(
  value: unknown,
): NotificationSettings {
  if (!value || typeof value !== "object") {
    return DEFAULT_NOTIFICATION_SETTINGS;
  }

  const candidate = value as Partial<NotificationSettings>;
  return {
    desktopEnabled:
      typeof candidate.desktopEnabled === "boolean"
        ? candidate.desktopEnabled
        : DEFAULT_NOTIFICATION_SETTINGS.desktopEnabled,
    homeBadgeEnabled:
      typeof candidate.homeBadgeEnabled === "boolean"
        ? candidate.homeBadgeEnabled
        : DEFAULT_NOTIFICATION_SETTINGS.homeBadgeEnabled,
    notifyWhileViewing:
      typeof candidate.notifyWhileViewing === "boolean"
        ? candidate.notifyWhileViewing
        : DEFAULT_NOTIFICATION_SETTINGS.notifyWhileViewing,
    soundEnabled:
      typeof candidate.soundEnabled === "boolean"
        ? candidate.soundEnabled
        : DEFAULT_NOTIFICATION_SETTINGS.soundEnabled,
    sounds: sanitizeSoundsMap(candidate.sounds),
    slotAlertsEnabled: sanitizeSlotAlertsEnabled(candidate.slotAlertsEnabled),
    slotAlertsSnapshot:
      candidate.slotAlertsSnapshot != null &&
      typeof candidate.slotAlertsSnapshot === "object"
        ? sanitizeSlotAlertsEnabled(candidate.slotAlertsSnapshot)
        : null,
  };
}
