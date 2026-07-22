# User Profile Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — profiles, settings, user search.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/user-profile-service/` |
| Port | 8082 |
| Eureka | `user-profile-service` |
| Database | `user_db` |
| Package | `com.vithey.profile` |

## Spring Cloud + tools

Eureka, Config, OpenFeign, RabbitMQ listener, JPA, Flyway, MapStruct, springdoc.

## Folder structure

```text
services/user-profile-service/
└── src/main/java/com/vithey/profile/
    ├── UserProfileServiceApplication.java
    ├── config/SecurityConfig.java, RabbitMqConfig.java, FeignAuthConfig.java, OpenApiConfig.java
    ├── controller/
    │   ├── UserController.java
    │   └── SettingsController.java
    ├── service/ProfileService.java, SettingsService.java, UserSearchService.java
    ├── repository/ProfileRepository.java, UserSettingsRepository.java
    ├── entity/Profile.java, UserSettings.java
    ├── dto/request/UpdateProfileRequest.java, UpdateSettingsRequest.java, UpdateAvatarRequest.java
    ├── dto/response/ProfileResponse.java, SettingsResponse.java, UserSearchResultResponse.java
    ├── mapper/ProfileMapper.java, SettingsMapper.java
    ├── client/FileServiceClient.java          # @FeignClient file-service
    ├── event/listener/UserRegisteredEventListener.java
    ├── security/CurrentUserProvider.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**Profile:** `id` (= user_id UUID), `full_name`, `bio`, `avatar_file_id`, `avatar_url`, `telegram_link`, `facebook_link`, `university`, `major`, `graduation_year`, `created_at`, `updated_at`

**UserSettings:** `user_id` PK, `language` km|en, `theme` light|dark|system, `notification_prefs` JSONB, `fcm_token`, `updated_at`

## Complete API (all JWT)

| Method | Path | Request body | Response | HTTP |
|--------|------|--------------|----------|------|
| GET | `/api/v1/users/me` | — | Profile + settings summary | 200 |
| GET | `/api/v1/users/{userId}` | — | Public profile | 200 |
| PATCH | `/api/v1/users/me` | Update profile fields | Updated profile | 200 |
| PATCH | `/api/v1/users/me/avatar` | `{ "avatar_file_id": "uuid" }` | Profile with avatar_url | 200 |
| GET | `/api/v1/users/me/settings` | — | Settings | 200 |
| PATCH | `/api/v1/users/me/settings` | Settings JSON | Updated settings | 200 |
| GET | `/api/v1/users/search` | `?search=john&page=1&limit=20` | Paginated users | 200 |

**Profile response:**
```json
{
  "data": {
    "user_id": "uuid",
    "full_name": "Jane Doe",
    "bio": "AUB CS student",
    "avatar_url": "https://...",
    "telegram_link": "https://t.me/jane",
    "facebook_link": "https://facebook.com/jane",
    "university": "AUB",
    "major": "Computer Science",
    "graduation_year": 2026
  }
}
```

**Settings request:**
```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "comments": true, "chat": true, "payments": true },
  "fcm_token": "optional-device-token"
}
```

## Business logic

| Flow | Logic |
|------|-------|
| User registered event | Consume `user.registered` from RabbitMQ; create Profile + default UserSettings (`full_name` from event) |
| Update avatar | Forward caller JWT / `X-User-*` headers to `file-service` via Feign; validate file exists → store `avatar_file_id` + URL |
| Search | ILIKE on `full_name`, paginated, exclude blocked users (future) |
| Public profile | Hide email/phone; show bio, links, university |

## Events consumed

| Event | Action |
|-------|--------|
| `user.registered` | Insert Profile |

## Errors

| Case | HTTP |
|------|------|
| Profile not found | 404 |
| Invalid file id for avatar | 404 |
| Validation error | 400 |

## Integration notes

- **RabbitMQ:** Auth publishes `user.registered` with `__TypeId__=com.vithey.auth.event.payload.UserRegisteredEvent`. Register a `Jackson2JsonMessageConverter` bean with `TypePrecedence.INFERRED` so the listener deserializes into the local `UserRegisteredEvent` DTO without matching packages.
- **OpenFeign:** `FeignAuthConfig` forwards `Authorization`, `X-User-Id`, `X-User-Email`, and `X-User-Roles` from the inbound HTTP request to downstream services (required for avatar lookup via `FileServiceClient`).
- **Postman:** `postman/User-Module.postman_collection.json` + `postman/Vithey-Local.postman_environment.json` at repo root.

## Output

Runnable user-profile-service on **8082**.
