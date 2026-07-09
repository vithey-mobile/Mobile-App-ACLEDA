# User Profile Service — Service Logic

## Ownership

Owns public profile data, avatar references, user search, app language/theme settings, notification preferences, and privacy settings.

Does not own credentials, JWT, files, follows, CV, posts, or chat messages.

## Core flows

| Flow | Logic |
| --- | --- |
| User registered | Consume `user.registered`, create default `Profile` and `UserSettings`. |
| Get me | Load profile and settings for `X-User-Id`. |
| Public profile | Return public-safe fields only; never return email/phone/password. |
| Update profile | Validate social links and academic fields, update current user's profile. |
| Update avatar | Validate file exists through `file-service`, then store `avatar_file_id` and `avatar_url`. |
| Settings | Upsert language, theme, notification preferences, privacy preferences. |
| Search users | Case-insensitive search on `full_name`, `university`, `major`; paginated; used by global search, chat add-user, mentions, notification app bar search. |

### GET `/users/search` flow

1. Validate JWT → `X-User-Id`
2. Validate `search` trim length ≥ 2
3. Query `profiles` with ILIKE (see `_shared/SEARCH.md`)
4. Filter out `privacy_prefs.profile_visible = false`
5. Map to `UserSearchResultResponse` — no email/phone
6. Return paginated envelope with `meta.total_pages`

| Step | Detail |
| --- | --- |
| Sort | Prefix match on `full_name` first, then `full_name ASC` |
| Rate limit | 60/min per user at gateway (recommended) |
| Block list | Exclude blocked users when chat block API ships |

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

