# User Profile Service — Common Context

## Service Role
User profiles, avatars (URL ref), bios, Telegram/Facebook links, user search, and app settings sync.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `user-profile-service` |
| Port | 8082 |
| Database | `user_db` |
| Package | `com.vithey.profile` |
| Swagger | `http://localhost:8082/swagger-ui.html` |

## Entities
- `Profile` — userId, fullName, bio, avatarFileId, avatarUrl, university, major, graduationYear, telegramLink, facebookLink
- `UserSettings` — userId, language, theme, notificationPrefs (JSON), privacyPrefs (JSON), fcmToken
- Enums: `AppLanguage` (`km`\|`en`), `AppTheme` (`light`\|`dark`\|`system`)

## Read projections
- `LanguageThemeProjection` — `/users/me` language + theme only
- `UserSearchProjection` — search result columns only

## Events
- **Consumes:** `user.registered` → create default profile + settings
- **Publishes:** none (do not invent `profile.updated` unless product requires it)

## External Clients
- `FileServiceClient` — resolve avatar metadata/URL from `file-service` (Feign forwards caller auth headers; connect 2s / read 5s)

## Local API testing
- Postman collection: `postman/User-Module.postman_collection.json`
- Environment: `postman/Vithey-Local.postman_environment.json`
- Flow: Login → Bearer `access_token` on all `/users/**` requests; auto-login prerequest when token empty

## API Prefix
`/api/v1/users/**`
