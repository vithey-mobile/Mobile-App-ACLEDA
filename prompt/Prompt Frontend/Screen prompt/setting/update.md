# Settings Account — update notes

## Status: as-built

Update **Settings → Account** and **Edit Account**.

### Requirements

- Change interface and UI to match Settings home (gray page, white card groups).
- Remove inline text fields from Edit Account list.
- Use the same interaction style as **Edit Profile** (tap row → bottom sheet).
- Example: tap **Full name** → bottom sheet to edit.

### Scope split

| Screen | Owns |
|---|---|
| Account / Edit Account | Private personal identity only |
| Edit Profile | Professional / public profile (skills, bio, work, …) |

### Prompts

- `02.setting_account.md` — Account overview
- `setting_edit_account.md` — Sheet-based Edit Account

### Implementation

```text
lib/modules/settings/account/
  account_settings_screen.dart
  edit_account_settings_screen.dart
  widgets/account_section_sheets.dart
```
