# User Profile Service — Service Logic

## Ownership

Owns public profile data, avatar references, user search, app language/theme settings, notification preferences, and privacy settings.

Does not own credentials, JWT, files, follows, CV, posts, or chat messages.

## Core flows

| Flow | Logic |
| --- | --- |
| User registered | Consume `user.registered` (RabbitMQ queue `user-profile.user.registered`), deserialize with inferred JSON type mapping, create default `Profile` and `UserSettings`. |
| Get me | Load profile and settings for `X-User-Id`. |
| Public profile | Return public-safe fields only; never return email/phone/password. |
| Update profile | Validate social links and academic fields, update current user's profile. |
| Update avatar | Forward inbound auth to `file-service` via Feign; validate file exists, then store `avatar_file_id` and `avatar_url`. Upload avatars with `POST /api/v1/files/upload?type=AVATAR` first. |
| Settings | Upsert language, theme, notification preferences, privacy preferences. |
| Search users | Case-insensitive search by `full_name`, paginated for chat and mentions. |

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
| Invalid avatar file | `INVALID_FILE` | 400 |
| Validation failure | `VALIDATION_ERROR` | 400 |

