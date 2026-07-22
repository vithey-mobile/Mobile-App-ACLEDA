# User Profile Service — API Endpoints

Base path: `/api/v1`

Gateway note: generic `/users/**` routes here, except `/users/me/cv` and follow/follower paths which route elsewhere.

## Endpoints

| Method | Path | Purpose | Auth |
| --- | --- | --- | --- |
| GET | `/users/me` | Current user's profile | JWT |
| GET | `/users/{user_id}` | Public profile by id | JWT |
| PATCH | `/users/me` | Update current profile | JWT |
| PATCH | `/users/me/avatar` | Set avatar from uploaded file id | JWT |
| GET | `/users/me/settings` | Current user settings | JWT |
| PATCH | `/users/me/settings` | Update settings | JWT |
| GET | `/users/search?search=&page=&limit=` | Search users for chat/mentions | JWT |

## Profile response

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

## Avatar prerequisite

Upload via file-service first:

`POST /api/v1/files/upload?type=AVATAR` (multipart field `file`) → use returned `file_id` in:

```json
{ "avatar_file_id": "uuid" }
```

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

