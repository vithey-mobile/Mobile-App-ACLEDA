# Settings Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `16` |
| Route | `Routes.SETTINGS` |
| Flutter module | `lib/modules/settings/` |
| Backend service(s) | `user-profile-service` |
| Auth required | Yes |
| Competition feature | **Settings menu** |

## Purpose

Manage account, privacy, **theme**, **language**, notifications, and **logout**.

## Open from

- Profile (gear icon)

## Main UI

| Section | Items |
|---------|-------|
| Account | Edit profile, change password |
| Preferences | Theme, language, notifications |
| Security | Privacy, blocked users |
| About | App version |
| Logout | Red destructive action |

## Features

| Feature | Options |
|---------|---------|
| Theme | Light, Dark, System |
| Language | English, Khmer |
| Notifications | Toggle per category |
| Logout | Clear tokens → Auth |

## User actions

| Action | Result |
|--------|--------|
| Toggle theme | Instant change + persist locally |
| Change language | Persist + reload strings |
| Logout | Confirm dialog → clear storage → Auth |

## Logic & behavior

- Theme via `Get.changeThemeMode` + `shared_preferences`
- Optional sync settings to `PATCH /api/v1/users/me/settings`

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/users/me/settings` | Load prefs |
| PATCH | `/api/v1/users/me/settings` | Save prefs |
| POST | `/api/v1/auth/logout` | Revoke refresh token |

## Status checklist

- [ ] UX/UI designed
- [ ] Light + dark mode works
- [ ] Logout clears session
