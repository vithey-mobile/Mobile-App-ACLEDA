# User Profile Service — API Endpoints

Base path: `/api/v1`

Gateway note: generic `/users/**` routes here, except `/users/me/cv` and follow/follower paths which route elsewhere.

Swagger UI: `http://localhost:8082/swagger-ui.html` (Bearer JWT). Controllers use `@Tag` / `@Operation`; request DTOs include `@Schema` sample bodies for Try it out.

## Endpoints

| Method | Path | Purpose | Auth |
| --- | --- | --- | --- |
| GET | `/users/me` | Current user's profile + language/theme summary | JWT |
| GET | `/users/{user_id}` | Public profile by id | JWT |
| PATCH | `/users/me` | Update current profile (partial; dirty-check) | JWT |
| PATCH | `/users/me/avatar` | Set avatar from uploaded file id | JWT |
| GET | `/users/me/settings` | Current user settings | JWT |
| PATCH | `/users/me/settings` | Update settings (partial; skip no-op writes) | JWT |
| GET | `/users/search?search=&page=&limit=` | Search users for chat/mentions | JWT |

## Search query rules

| Param | Rules |
| --- | --- |
| `search` | Required; trimmed; **min length 2**; `%` / `_` escaped for LIKE |
| `page` | Default `1`; capped at **100** |
| `limit` | Default `20`; capped at **50** |

Returns projected fields only: `user_id`, `full_name`, `avatar_url`, `university` (ordered by `full_name` ASC). Empty result when search is blank or shorter than 2 chars.

## Me profile response

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

Public `GET /users/{user_id}` omits `language` / `theme`.

## Avatar prerequisite

Upload via file-service first:

`POST /api/v1/files/upload?type=AVATAR` (multipart field `file`) → use returned `file_id` in:

```json
{ "avatar_file_id": "uuid" }
```

Same `avatar_file_id` as already stored → no Feign call / no write (idempotent).

## Settings request

```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "comments": true, "chat": true, "payments": true },
  "privacy": { "profile_visible": true, "show_activity": true },
  "fcm_token": "optional-device-token"
}
```

All fields optional. Unchanged values are not persisted (avoids dirty JSONB updates).
