# Settings Notification Preferences Prompt

Build the **Notification Settings** screen for Vithey App in Flutter, matching:

- `Prompt Frontend/screen image/setting/setting_notification.jpg`

## Quick info

| Field | Value |
|---|---|
| Route | Add `AppRoutes.settingsNotifications` → `/settings/notifications` |
| Flutter module | `lib/modules/settings/notification_preferences/` |
| Backend services | `user-profile-service`, `notification-service` |
| Auth required | Yes |
| Entry point | Settings Home → Notifications |

> This is a notification **preferences** screen. Keep it separate from
> `AppRoutes.notifications`, which opens the notification inbox/list.

## Goal

Let users enable or disable all notifications and choose which categories they
want to receive.

## Visual requirements

Match `setting_notification.jpg` and the shared Settings visual language.
The screen must look polished and remain readable in **both light and dark
mode**. Use `Theme.of(context)`, `colorScheme`, and semantic app colors; do not
hardcode white, black, teal, or grey surface colors.

- Theme-aware scaffold background.
- App bar:
  - Back arrow on the left.
  - Bold title: **Notifications**.
  - Thin divider below.
  - Reuse `settings_scaffold.dart`.
- Use 16–20 px horizontal page padding and comfortable vertical spacing.
- Cards:
  - Theme surface/card color.
  - Rounded corners (~16 px).
  - Subtle border and/or soft shadow.
  - Clip row splash and divider content to the card radius.
- Every toggle uses the same compact `shad.Switch` component as the Dark Mode
  row on Settings Home; do not use the larger Material `Switch.adaptive`.
- Enabled switch track uses `colorScheme.primary`; disabled/off states use
  theme-aware muted colors.
- Row titles use the heading/on-surface color and medium or semi-bold weight.
- Row subtitles use muted/on-surface-variant color.
- Bottom navigation remains visible with **Profile** selected.

## Screen content

Render the following content from top to bottom.

### Master notification card

One prominent rounded card:

- Primary-tinted circular icon container.
- Primary-colored notification/bell outline icon.
- Title: **Allow Notifications**
- Subtitle: **Receive alerts from Vithey**
- Compact switch on the right.

Behavior:

- Turning this switch off disables all notification delivery.
- Category values are preserved while the master switch is off.
- Category switches become visually disabled and cannot be changed while the
  master switch is off.
- Turning it back on restores the previously selected categories.
- If system notification permission is denied, enabling it requests permission.
- If permission is permanently denied, keep it off and show an action that
  opens the operating-system app settings. Do not pretend permission was granted.

### Activity section

Section label: **ACTIVITY**

One grouped rounded card with inset dividers and these rows:

1. **Chat Messages**
   - Subtitle: **Replies and new conversations**
   - Chat/message outline icon in primary color.
2. **Reminders**
   - Subtitle: **Study sessions and due dates**
   - Clock/reminder outline icon in primary color.

Each row has its icon on the left, title/subtitle in the center, and a compact
switch aligned on the right.

### From Vithey section

Section label: **FROM VITHEY**

One grouped rounded card with inset dividers and these rows:

1. **Announcements**
   - Subtitle: **News and important updates**
   - Megaphone outline icon in primary color.
2. **App Updates**
   - Subtitle: **New features and improvements**
   - Book/app-update outline icon in primary color.

Use the app primary color consistently for icons. The reference image uses
multiple accent colors, but this app's Settings screens use one theme primary
color for a coherent light/dark-mode design.

### Save button

- Full-width primary rounded button.
- Label: **Save Preferences**
- Label centered horizontally and vertically.
- Show a loading indicator while saving.
- Disable the button while loading.
- Prefer disabling it when nothing has changed.
- Keep enough bottom padding above the app bottom navigation.

## Preferences model

```dart
class NotificationPreferences {
  final bool allowNotifications;
  final bool chatMessages;
  final bool reminders;
  final bool announcements;
  final bool appUpdates;
}
```

Suggested API representation:

```json
{
  "notifications": {
    "enabled": true,
    "chat_messages": true,
    "reminders": true,
    "announcements": false,
    "app_updates": true
  }
}
```

## Architecture

```text
lib/modules/settings/notification_preferences/
  notification_preferences_screen.dart
  notification_preferences_controller.dart
  notification_preferences_binding.dart
  widgets/
    notification_master_card.dart
    notification_preference_card.dart
    notification_preference_tile.dart
```

Reuse shared settings components where appropriate:

- `settings_scaffold.dart` for app bar and divider.
- `settings_tile_divider.dart` for inset dividers.
- `settings_switch_tile.dart` / its compact `shad.Switch` pattern.
- `custom_button.dart` for the centered Save Preferences button.

## Controller behavior

- `loadPreferences()`:
  - Load cached preferences first for immediate rendering.
  - Fetch `GET /api/v1/users/me/settings`.
  - Merge the server `notifications` object without discarding valid local
    values when optional keys are missing.
- `toggleAllowNotifications(bool value)`:
  - When enabling, verify/request operating-system notification permission.
  - Update only the master value; preserve category selections.
- Category toggle methods update local draft state only.
- `savePreferences()`:
  - Return immediately if input is unchanged or a save is already running.
  - Persist the complete notification preference object with
    `PATCH /api/v1/users/me/settings`.
  - Update local cache only after successful persistence.
  - Show **Notification preferences saved** on success.
  - On failure, retain the user's draft values and show the API error so they
    can retry.
  - Register/unregister the FCM device token only when push notifications and
    the backend device endpoint are actually available.

## API

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/v1/users/me/settings` | Load notification preferences |
| `PATCH` | `/api/v1/users/me/settings` | Save the `notifications` object |
| `POST` | `/api/v1/notifications/devices` | Register FCM device token when enabled |
| `DELETE` | `/api/v1/notifications/devices/{token}` | Unregister token when disabled |

Use `Prompt Frontend/api-intergration/integration-contract.md`.

If per-category settings are not yet supported by the backend, persist locally
and clearly document that limitation. Do not show fake remote success.

## UX and accessibility rules

- The entire row may toggle its switch, not only the small switch control.
- Provide semantic labels and switch state for screen readers.
- Maintain at least a 44×44 logical-pixel tap target.
- Category switches must clearly appear disabled when Allow Notifications is off.
- Preserve user choices when the master switch is toggled off and on.
- Never silently override operating-system notification permission.
- All text, icons, dividers, cards, disabled states, and shadows must have
  sufficient contrast in both themes.

## Testing

- Screen matches the reference grouping, labels, subtitles, cards, and button.
- Master switch requests/checks system permission correctly.
- Master switch disables category interaction without clearing selections.
- Re-enabling restores the previous category selections.
- Every category switch updates independently.
- Save button is centered, shows loading, prevents duplicate submissions, and
  is disabled when there are no changes.
- Successful save updates cache and shows confirmation.
- Failed save keeps draft values and allows retry.
- Screen remains legible and correctly themed in light and dark mode.
- Settings Home opens this route, while the notification bell continues to open
  the notification inbox route.

## Output

Complete Notification Settings screen matching `setting_notification.jpg`,
with theme-aware grouped cards, compact switches, operating-system permission
handling, persistent preferences, and safe light/dark-mode behavior.
