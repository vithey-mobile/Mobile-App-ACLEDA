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
| Swagger | `http://localhost:8082/swagger-ui.html` |

## Spring Cloud + tools

Eureka, Config, OpenFeign, RabbitMQ listener, JPA, Flyway, MapStruct, springdoc (`@Tag` / `@Operation` / `@Schema` examples).

## Folder structure

```text
services/user-profile-service/
└── src/main/java/com/vithey/profile/
    ├── UserProfileServiceApplication.java
    ├── config/SecurityConfig.java, RabbitMqConfig.java, FeignAuthConfig.java, OpenApiConfig.java
    ├── controller/
    │   ├── UserController.java       # @Tag("User Profile")
    │   └── SettingsController.java   # @Tag("User Settings")
    ├── service/ProfileService.java, SettingsService.java, UserSearchService.java
    ├── repository/
    │   ├── ProfileRepository.java, UserSettingsRepository.java
    │   ├── UserSearchProjection.java, LanguageThemeProjection.java
    ├── entity/Profile.java, UserSettings.java, AppLanguage.java, AppTheme.java
    ├── dto/request/UpdateProfileRequest.java, UpdateSettingsRequest.java, UpdateAvatarRequest.java  # @Schema samples
    ├── dto/response/ProfileResponse.java, MeProfileResponse.java, SettingsResponse.java, UserSearchResultResponse.java
    ├── mapper/ProfileMapper.java, SettingsMapper.java
    ├── client/FileServiceClient.java
    ├── event/listener/UserRegisteredEventListener.java, event/payload/UserRegisteredEvent.java
    ├── security/JwtProvider.java, JwtAuthenticationFilter.java, CurrentUser.java, CurrentUserProvider.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**Profile:** `user_id` PK, `full_name`, `bio`, `avatar_file_id`, `avatar_url`, `telegram_link`, `facebook_link`, `university`, `major`, `graduation_year`, `created_at`, `updated_at`

**UserSettings:** `user_id` PK, `language` km|en, `theme` light|dark|system, `notification_prefs` JSONB, `privacy_prefs` JSONB, `fcm_token`, `updated_at`

**Index:** GIN trigram on `LOWER(full_name)` (`pg_trgm`) — see `DB_SCHEMA.md`.

## Complete API (all JWT)

| Method | Path | Request body | Response | HTTP |
|--------|------|--------------|----------|------|
| GET | `/api/v1/users/me` | — | Profile + `language`/`theme` | 200 |
| GET | `/api/v1/users/{userId}` | — | Public profile | 200 |
| PATCH | `/api/v1/users/me` | Update profile fields (partial) | Updated profile | 200 |
| PATCH | `/api/v1/users/me/avatar` | `{ "avatar_file_id": "uuid" }` | Profile with avatar_url | 200 |
| GET | `/api/v1/users/me/settings` | — | Settings | 200 |
| PATCH | `/api/v1/users/me/settings` | Settings JSON (partial) | Updated settings | 200 |
| GET | `/api/v1/users/search` | `?search=jane&page=1&limit=20` | Paginated users | 200 |

**Search constraints:** `search` min length 2; escape `%`/`_`; `page` ≤ 100; `limit` ≤ 50; order by `full_name` ASC; return projected columns only.

**Me profile response:**
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
    "graduation_year": 2026,
    "language": "km",
    "theme": "dark"
  }
}
```

**Settings request:**
```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "comments": true, "chat": true, "payments": true },
  "privacy": { "profile_visible": true, "show_activity": true },
  "fcm_token": "optional-device-token"
}
```

## Business logic

| Flow | Logic |
|------|-------|
| User registered event | Consume `user.registered`; create Profile + default UserSettings (`full_name` from event); idempotent |
| Get me | Profile + language/theme projection (not full settings JSONB) |
| Update profile / settings | Dirty-check; skip no-op writes |
| Update avatar | Feign **outside** DB TX; skip Feign when file id unchanged; store `avatar_file_id` + URL |
| Search | Escaped ILIKE on `full_name`, projected columns, stable order, page/limit caps |
| Public profile | Hide email/phone; show bio, links, university |

## Events consumed

| Event | Action |
|-------|--------|
| `user.registered` | Insert Profile + default settings |

## Errors

| Case | Code | HTTP |
|------|------|------|
| Profile / settings not found | `NOT_FOUND` | 404 |
| Invalid file id for avatar | `INVALID_FILE` | 400 |
| Validation error | `VALIDATION_ERROR` | 400 |
| Unauthorized | `UNAUTHORIZED` | 401 |

## Integration notes

- **RabbitMQ:** Auth publishes `user.registered` with `__TypeId__=com.vithey.auth.event.payload.UserRegisteredEvent`. Register a `Jackson2JsonMessageConverter` bean with `TypePrecedence.INFERRED` so the listener deserializes into the local `UserRegisteredEvent` DTO without matching packages.
- **OpenFeign:** `FeignAuthConfig` forwards `Authorization`, `X-User-Id`, `X-User-Email`, and `X-User-Roles`. Service timeouts: connect **2s**, read **5s** (`file-service` + default).
- **Hikari:** `maximum-pool-size` default 10, `connection-timeout` 3s (env-overridable).
- **OpenAPI:** Document every endpoint with `@Operation`; request bodies with `@Schema` examples so Swagger Try it out matches Postman samples.
- **Postman:** `postman/User-Module.postman_collection.json` + `postman/Vithey-Local.postman_environment.json` — Bearer on protected requests; collection prerequest auto-logins when `access_token` is empty.

## Output

Runnable user-profile-service on **8082**, Swagger documented, Postman-tested.
