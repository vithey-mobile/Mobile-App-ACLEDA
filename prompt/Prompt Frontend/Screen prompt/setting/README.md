# Settings Prompt Index

**UI status: complete** in `vithey_app/lib/modules/settings/`.

Use this folder as the single source of truth for Settings screens.

## Visual references

All current references live in:

```text
Prompt Frontend/screen image/setting/
```

| Image | Prompt |
|---|---|
| `setting_home.png` | `01.setting_home.md` |
| `setting_account.png` | `02.setting_account.md` |
| `setting_privacy.png` | `03.setting_privacy.md` |
| `setting_security.png` | `03.setting_security.md` (legacy filename) |
| `setting_change_password.png` | `06.setting_change_password.md` |

No images are currently provided for Help Center or About; those prompts follow the same settings visual system.

## Reading order

1. `01.setting_home.md` — settings menu, dark mode, logout.
2. `02.setting_account.md` — profile/account information and avatar update.
3. `setting_edit_account.md` — edit account fields.
4. `03.setting_privacy.md` — privacy switches and data protection card.
5. `03.setting_security.md` — security settings, sessions, 2FA/biometric placeholders.
6. `06.setting_change_password.md` — password update form.
7. `setting_notification.md` — notification preferences.
8. `04.setting_help_center.md` — FAQ and support.
9. `05.setting_about.md` — app/version/legal information.

## Route constants (sync with `AppRoutes`)

```dart
static const settings = '/settings';
static const settingsAccount = '/settings/account';
static const settingsEditAccount = '/settings/account/edit';
static const settingsPrivacy = '/settings/privacy';
static const settingsPrivacyPractices = '/settings/privacy/practices';
static const settingsNotifications = '/settings/notifications';
static const settingsSecurity = '/settings/security';
static const settingsChangePassword = '/settings/security/change-password';
static const settingsHelpCenter = '/settings/help-center';
static const settingsAbout = '/settings/about';
```

## Shared module

```text
lib/modules/settings/
  settings_home_screen.dart
  settings_controller.dart
  settings_binding.dart
  account/
  privacy/
  security/
  change_password/
  notification_preferences/
  help_center/
  about/
  widgets/
```

## API contract

```text
Prompt Frontend/api-intergration/integration-contract.md
```

## Backend mapping

| Setting area | Backend service |
|---|---|
| Account/profile | `user-profile-service`, `file-service` |
| Privacy/settings | `user-profile-service` |
| Security/logout/password | `auth-service` |
| Notification preferences | local (`LocalStorageService`) until API exists |
| Help/About | local / external links |

## Notes

- Notification **inbox** is not Settings — see `../notification/README.md`.
- Do not fake unsupported security APIs. Show disabled/coming-soon states.

## Acceptance checklist (release)

- [x] Settings home — dark mode toggle, logout
- [x] Account + edit account
- [x] Privacy toggles
- [x] Security + change password
- [x] Notification preferences screen
- [x] Help center and About
- [x] Logout clears token and routes to Auth
- [x] Dark mode readable on settings screens
