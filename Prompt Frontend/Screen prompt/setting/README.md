# Settings Prompt Index

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
3. `03.setting_privacy.md` — privacy switches and data protection card.
4. `03.setting_security.md` — security settings, sessions, 2FA/biometric placeholders.
5. `06.setting_change_password.md` — password update form.
6. `04.setting_help_center.md` — FAQ and support.
7. `05.setting_about.md` — app/version/legal information.

## Route constants

```dart
static const SETTINGS = '/settings';
static const SETTING_ACCOUNT = '/settings/account';
static const SETTING_PRIVACY = '/settings/privacy';
static const SETTING_SECURITY = '/settings/security';
static const SETTING_CHANGE_PASSWORD = '/settings/security/change-password';
static const SETTING_HELP_CENTER = '/settings/help-center';
static const SETTING_ABOUT = '/settings/about';
```

## Shared module recommendation

Settings can be implemented as one feature module:

```text
lib/modules/settings/
  settings_home_screen.dart
  settings_controller.dart
  settings_binding.dart
  account/
  privacy/
  security/
  change_password/
  help_center/
  about/
  widgets/
```

## API contract

Use only:

```text
Prompt Frontend/api-intergration/integration-contract.md
```

## Backend mapping

| Setting area | Backend service |
|---|---|
| Account/profile | `user-profile-service`, `file-service` |
| Privacy/settings | `user-profile-service` |
| Security/logout/password | `auth-service` |
| Help/About | local / external links |

## Notes

- Do not duplicate notification inbox behavior here; Settings can link to notification preferences only when a specific prompt exists.
- Do not fake unsupported security APIs. Show disabled/coming-soon states or document backend contract gaps.

