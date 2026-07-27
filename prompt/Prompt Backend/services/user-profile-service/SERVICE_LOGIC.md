# User Profile Service — Service Logic

## Ownership

Owns public profile data, avatar references, user search, app language/theme settings, notification preferences, and privacy settings.

Does not own credentials, JWT issuance, files, follows, CV, posts, or chat messages.

## Core flows

| Flow | Logic |
| --- | --- |
| User registered | Consume `user.registered` (queue `user-profile.user.registered`), deserialize with inferred JSON type mapping, create default `Profile` and `UserSettings` (idempotent if profile already exists). |
| Get me | Load profile + **language/theme projection only** (do not load full settings JSONB). |
| Public profile | Return public-safe fields only; never return email/phone/password. |
| Update profile | Partial update; apply field only when value actually changes. |
| Update avatar | Short TX to load profile → if `avatar_file_id` unchanged, return as-is. Else call `file-service` **outside** DB TX, then persist `avatar_file_id` + `avatar_url` in a short TX. Upload first via `POST /api/v1/files/upload?type=AVATAR`. |
| Settings | Partial upsert of language, theme, notification/privacy prefs, FCM token; **skip save when nothing changed**. |
| Search users | Escape LIKE wildcards; reject/empty if `search` length &lt; 2; project `user_id`, `full_name`, `avatar_url`, `university`; `ORDER BY full_name`; page ≤ 100, limit ≤ 50. Uses GIN trigram index on `LOWER(full_name)`. |

## Performance rules

| Rule | Why |
| --- | --- |
| Never hold a DB transaction open across Feign | Avoids tying Hikari connections to HTTP latency |
| Projected queries for `/me` and search | Avoid reading unused JSONB / `bio` TEXT |
| Dirty-check profile/settings mutations | Avoid no-op JSONB/row updates |
| Hikari + Feign timeouts in `application.yml` | Fail fast under downstream pressure |
| Reuse `JwtParser`; skip JWT filter on actuator/swagger | Cut per-request overhead on probes |

## Events consumed

| Event | Action |
| --- | --- |
| `user.registered` | Create profile and default settings |

## Frontend alignment

- Settings screens call `GET/PATCH /users/me/settings`.
- Account screen calls `GET/PATCH /users/me` and `PATCH /users/me/avatar`.
- Chat add-user and mentions use `/users/search`.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Profile missing | `NOT_FOUND` | 404 |
| Settings missing | `NOT_FOUND` | 404 |
| Invalid avatar file | `INVALID_FILE` | 400 |
| Validation failure | `VALIDATION_ERROR` | 400 |
| Missing/invalid JWT | `UNAUTHORIZED` | 401 |
