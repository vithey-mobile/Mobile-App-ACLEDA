# User Profile Service — Service Prompt

Build the User/Profile microservice.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/users/me` | JWT | Current user profile + settings |
| GET | `/api/v1/users/{userId}` | JWT | Public profile view |
| PATCH | `/api/v1/users/me` | JWT | Update bio, social links, university |
| PATCH | `/api/v1/users/me/avatar` | JWT | Set avatar URL (after file upload) |
| GET | `/api/v1/users/me/settings` | JWT | Get settings |
| PATCH | `/api/v1/users/me/settings` | JWT | Update theme, language, notifications |
| GET | `/api/v1/users/search` | JWT | Search users by name (`?search=john`) |

## Profile Response
```json
{
  "data": {
    "user_id": "uuid",
    "full_name": "Jane Doe",
    "bio": "AUB CS student",
    "avatar_url": "https://minio/...",
    "telegram_link": "https://t.me/jane",
    "facebook_link": "https://facebook.com/jane",
    "university": "AUB",
    "major": "Computer Science",
    "graduation_year": 2026
  }
}
```

## Settings Request
```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "comments": true, "chat": true, "payments": true }
}
```

## Event Listener
`UserRegisteredListener` — on `user.registered`, create Profile with fullName from event.

## Required Modules
- `UserController`, `SettingsController`
- `ProfileService`, `SettingsService`, `UserSearchService`
- `ProfileRepository`, `UserSettingsRepository`
- `UserRegisteredEventListener`
- `FileServiceClient` (WebClient)
- Flyway migrations, OpenAPI, tests

## Output
Runnable service on port 8082.
