# User Profile Service — API Endpoints

Base path: `/api/v1`

Gateway note: generic `/users/**` routes here, except `/users/me/cv` and follow/follower paths which route elsewhere.

## Endpoints

| Method | Path | Purpose | Auth |
| --- | --- | --- | --- |
| GET | `/users/me` | Current user's profile + language/theme | JWT |
| GET | `/users/{user_id}` | Public profile by id | JWT |
| PATCH | `/users/me` | Partial update current profile | JWT |
| PATCH | `/users/me/avatar` | Set avatar from file-service id | JWT |
| GET | `/users/me/settings` | Current user settings | JWT |
| PATCH | `/users/me/settings` | Partial update settings | JWT |
| GET | `/users/search?search=&page=&limit=` | Search users — global search, chat, mentions | JWT |

## GET `/users/search` — global people search

Used by Flutter `SearchScreen` (Home, Chat, **Notifications** app bar).

### Query parameters

| Param | Type | Required | Default | Validation |
| --- | --- | --- | --- | --- |
| `search` | string | yes | — | trim; min 2, max 100 |
| `page` | int | no | 1 | ≥ 1 |
| `limit` | int | no | 20 | 1–50 |

### Response `200`

```json
{
  "data": [
    {
      "user_id": "uuid",
      "full_name": "Heng Liza",
      "avatar_url": "https://...",
      "university": "American University of Phnom Penh",
      "major": "Web Development",
      "headline": "Graphic designer"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 3, "total_pages": 1 }
}
```

`headline` — server-computed display subtitle (`major · university` or workplace when available).

### Errors

| HTTP | Code | When |
| --- | --- | --- |
| 400 | `VALIDATION_ERROR` | `search` missing or shorter than 2 characters |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |

### Implementation

- ILIKE on `profiles.full_name`, `university`, `major`
- Exclude users with `privacy_prefs.profile_visible = false`
- Order: prefix match on name first, then alphabetical
- Index: trigram GIN on `full_name` (Flyway `V2__search_indexes.sql`)

**Full cross-service spec:** `Prompt Backend/_shared/SEARCH.md`

## GET `/users/me` response (`MeProfileResponse`)

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
    "location": "Phnom Penh",
    "date_of_birth": "2004-08-01",
    "workplace": "Fintech Center",
    "portfolio_url": "https://example.com",
    "phone": "098765432",
    "email": "jane@example.com",
    "skills": [{ "name": "Flutter", "proficiency": 75 }],
    "education": ["High School", "AUB"],
    "field_visibility": { "phone": "PRIVATE", "email": "PRIVATE" },
    "language": "en",
    "theme": "system"
  }
}
```

## GET `/users/{user_id}` response (`ProfileResponse`)

Same profile fields as above **without** `language` / `theme`. `phone` and `email` only when `field_visibility` is `PUBLIC`.

## PATCH `/users/me` request (all fields optional — partial update)

```json
{
  "full_name": "Jane Doe",
  "bio": "Updated bio",
  "telegram_link": "https://t.me/jane",
  "facebook_link": "https://facebook.com/jane",
  "university": "AUB",
  "major": "Computer Science",
  "graduation_year": 2026,
  "location": "Phnom Penh",
  "date_of_birth": "2004-08-01",
  "workplace": "Fintech Center",
  "portfolio_url": "https://example.com",
  "phone": "098765432",
  "email": "jane@example.com",
  "skills": [{ "name": "Flutter", "proficiency": 75 }],
  "education": ["High School", "AUB"],
  "field_visibility": { "phone": "PUBLIC", "email": "PRIVATE" }
}
```

| Field | Validation |
| --- | --- |
| `full_name` | max 160 |
| `bio` | max 2000 |
| `telegram_link`, `facebook_link`, `portfolio_url` | max 500 each |
| `university`, `major`, `location`, `workplace` | max 160 each |
| `graduation_year` | 1900–2100 |
| `phone` | max 32 |
| `email` | valid email, max 160 |
| `skills` | max 12; `proficiency` 0–100 |
| `field_visibility` | `PUBLIC` \| `PRIVATE` \| `OWNER_ONLY` |

Omitted/null fields are **not** cleared. `skills` / `education` replace the full list when sent.

## PATCH `/users/me/avatar` request

```json
{
  "avatar_file_id": "uuid"
}
```

Flow: `POST /files/upload` (`type=AVATAR`) → validate via file-service Feign → store `avatar_file_id` + `avatar_url`.

## Settings

### GET `/users/me/settings`

```json
{
  "data": {
    "user_id": "uuid",
    "language": "en",
    "theme": "system",
    "notifications": { "likes": true, "comments": true, "chat": true, "payments": true },
    "privacy": { "profile_visible": true, "show_activity": true },
    "fcm_token": "optional"
  }
}
```

### PATCH `/users/me/settings` request (partial)

```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "comments": true, "chat": true, "payments": true },
  "privacy": { "profile_visible": true, "show_activity": true },
  "fcm_token": "optional-device-token"
}
```

`language`: `en` \| `km` · `theme`: `light` \| `dark` \| `system`

## Not owned by this service

| Data | Owner |
| --- | --- |
| Login password | auth-service |
| CV default | career-service (`/users/me/cv`) |
| Posts, jobs tab | content-service |
| Likes / followers | content-service |

## Events published

| Event | When |
| --- | --- |
| `profile.updated` | After `PATCH /users/me` or `PATCH /users/me/avatar` |

## Frontend mirror

`Prompt Frontend/Screen prompt/profile/v0/08.profile_api_backend.md`
