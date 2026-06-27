# 16 - Settings Screen Prompt

Build the **Settings** module for Vithey App.

## Goal
Manage account, privacy, theme (light/dark), language, notifications prefs, security, and logout.

## Depends On
- `00-foundation-prompt.md`, `03-auth-prompt.md`

## Reuse From Core
- `AppAppBar`
- `SectionHeader`
- `ConfirmDialog`
- `CustomButton`
- Theme from `app_theme.dart`, `LocalStorageService`

## Module Files
```text
lib/modules/settings/
  settings_screen.dart
  settings_controller.dart
  settings_binding.dart
  widgets/
    setting_tile.dart
    theme_toggle.dart
    language_selector.dart

lib/data/repositories/settings_repository.dart  # optional API sync for user prefs
```

## Screen Spec (Competition requirement: Settings menu default)
| Item | Detail |
|------|--------|
| Features | Account, privacy, theme, language, logout |
| Theme | Light Mode and Dark Mode |
| Logic | Save locally + optional `PATCH /users/me` |

## Controller Logic
- `toggleTheme()` — update `Get.changeThemeMode`, persist to storage
- `setLanguage(code)` — en / km, persist
- `logout()` — `ConfirmDialog` → clear tokens → `Get.offAllNamed(Routes.AUTH)`
- Navigate to sub-screens or show bottom sheets for account/privacy/security

## UI Requirements
- Grouped list with `SectionHeader`: **Account**, **Preferences**, **Security**, **About**
- `setting_tile`: leading icon, title, subtitle optional, trailing chevron or switch
- `theme_toggle`: Light / Dark / System segmented control
- `language_selector`: English / Khmer radio or dropdown
- Logout tile in red at bottom
- App version in footer

## Widget Rules
- `setting_tile` is reusable — if needed on other screens, move to `core/widgets/setting_tile.dart`
- Theme toggle must call existing `AppTheme` helper from foundation

## Route Registration
Add `Routes.SETTINGS`

## Competition Checklist
- [x] Settings menu present
- [x] Light + Dark mode
- [x] Logout clears secure storage

## Output
Complete settings screen with theme and language persistence.
