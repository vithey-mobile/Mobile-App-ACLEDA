# User Profile Service — Common Context

## Service Role
User profiles, avatars (URL ref), bios, Telegram/Facebook links, and app settings sync.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `user-profile-service` |
| Port | 8082 |
| Database | `user_db` |
| Package | `com.vithey.user` |

## Entities
- `Profile` — userId, fullName, bio, avatarUrl, university, major, graduationYear, telegramLink, facebookLink
- `UserSettings` — userId, language, theme, notificationPrefs (JSON)

## Events
- **Consumes:** `user.registered` → create default profile
- **Publishes:** `profile.updated`

## External Clients
- `FileServiceClient` — upload avatar, get URL

## API Prefix
`/api/v1/users/**`
