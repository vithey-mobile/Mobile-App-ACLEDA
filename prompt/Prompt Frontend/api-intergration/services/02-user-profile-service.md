# 02 — User Profile Service Integration Contract

> **Target Service:** `user-profile-service`  
> **Direct Port:** `8082` | **Gateway Base URL:** `http://localhost:8080/api/v1/users`  
> **Database:** `user_db` | **Naming Convention:** `snake_case` (Jackson globally configured)

---

## 1. Get Current User Profile (Me)

- **Method / Path:** `GET /api/v1/users/me`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`

### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "full_name": "Bora Tech",
    "bio": "Senior CS student at AUB | Flutter & Spring Boot enthusiast",
    "avatar_url": "http://localhost:19000/vithey/avatars/user-id/avatar.png?X-Amz-Algorithm=...",
    "telegram_link": "https://t.me/boratech",
    "facebook_link": "https://facebook.com/boratech",
    "university": "AUB",
    "major": "Computer Science",
    "graduation_year": 2026,
    "location": "Phnom Penh, Cambodia",
    "date_of_birth": "2003-05-15",
    "workplace": "Tech Lab AUB",
    "portfolio_url": "https://boratech.dev",
    "phone": "+85512345678",
    "email": "bora.student@aub.edu.kh",
    "skills": [
      {
        "skill_name": "Flutter",
        "proficiency": "ADVANCED"
      },
      {
        "skill_name": "Spring Boot",
        "proficiency": "INTERMEDIATE"
      }
    ],
    "education": [
      "American University of Phnom Penh (2022 - 2026)"
    ],
    "field_visibility": {
      "phone": "PRIVATE",
      "email": "PUBLIC",
      "date_of_birth": "CONNECTIONS_ONLY"
    },
    "language": "EN",
    "theme": "SYSTEM"
  }
}
```

---

## 2. Get Public User Profile by ID

- **Method / Path:** `GET /api/v1/users/{userId}`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`

### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
    "full_name": "Sokha Mean",
    "bio": "Fintech Researcher & Lecturer",
    "avatar_url": "http://localhost:19000/vithey/avatars/sokha.png?X-Amz-Algorithm=...",
    "telegram_link": "https://t.me/sokhamean",
    "facebook_link": null,
    "university": "AUB",
    "major": "Finance & Banking",
    "graduation_year": 2024,
    "location": "Phnom Penh",
    "date_of_birth": null,
    "workplace": "ACLEDA Bank Plc.",
    "portfolio_url": "https://sokha.aub.edu.kh",
    "phone": null,
    "email": "sokha.mean@aub.edu.kh",
    "skills": [
      {
        "skill_name": "Risk Analysis",
        "proficiency": "EXPERT"
      }
    ],
    "education": [
      "Master of Finance, AUB"
    ],
    "field_visibility": {
      "phone": "PRIVATE"
    }
  }
}
```

---

## 3. Update My Profile

- **Method / Path:** `PATCH /api/v1/users/me`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`, `Content-Type: application/json`

### Request Schema (All fields optional for partial updates)
| Field | Type | Description |
| :--- | :--- | :--- |
| `full_name` | `string` | Max 160 chars |
| `bio` | `string` | Max 2000 chars |
| `telegram_link` | `string` | URL / handle (max 500 chars) |
| `facebook_link` | `string` | URL / handle (max 500 chars) |
| `university` | `string` | Max 160 chars |
| `major` | `string` | Max 160 chars |
| `graduation_year` | `integer` | Range 1950 - 2100 |
| `location` | `string` | Max 160 chars |
| `date_of_birth` | `string` | Format: `YYYY-MM-DD` |
| `workplace` | `string` | Max 160 chars |
| `portfolio_url` | `string` | Max 500 chars |
| `phone` | `string` | Max 32 chars |
| `email` | `string` | Max 160 chars |
| `skills` | `array[SkillRequest]` | Array of `{ "skill_name": "...", "proficiency": "..." }` |
| `education` | `array[string]` | List of degree / institution strings |
| `field_visibility` | `map[string, string]` | Key-value visibility map |

```json
{
  "full_name": "Bora Tech",
  "bio": "Software Engineering Student @ AUB | Building Mobile & Cloud Systems",
  "telegram_link": "https://t.me/boratech",
  "major": "Computer Science",
  "graduation_year": 2026,
  "skills": [
    {
      "skill_name": "Flutter",
      "proficiency": "ADVANCED"
    },
    {
      "skill_name": "Java & Spring Boot",
      "proficiency": "ADVANCED"
    }
  ]
}
```

### Response Schema (`200 OK`)
Returns the updated `ProfileResponse` object in `{ "data": { ... } }`.

---

## 4. Update Profile Avatar

- **Method / Path:** `PATCH /api/v1/users/me/avatar`
- **Auth:** Bearer JWT required
- **Prerequisite:** Upload image first to `file-service` (`POST /api/v1/files/upload?type=AVATAR`) to get `file_id`.

### Request Schema
```json
{
  "avatar_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54"
}
```

### Response Schema (`200 OK`)
Returns updated `ProfileResponse` containing the new presigned `avatar_url`.

---

## 5. User Settings & FCM Token

### 5.1 Get My Settings
- **Method / Path:** `GET /api/v1/users/me/settings`
- **Auth:** Bearer JWT required

**Response (`200 OK`):**
```json
{
  "data": {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "language": "EN",
    "theme": "SYSTEM",
    "notifications": {
      "push_enabled": true,
      "email_digest": false,
      "chat_alerts": true
    },
    "privacy": {
      "show_online_status": true,
      "allow_messages_from_strangers": false
    },
    "fcm_token": "fcm-device-registration-token"
  }
}
```

### 5.2 Update Settings
- **Method / Path:** `PATCH /api/v1/users/me/settings`
- **Auth:** Bearer JWT required

```json
{
  "language": "KM",
  "theme": "DARK",
  "notifications": {
    "push_enabled": true,
    "chat_alerts": true
  },
  "fcm_token": "dGhpcy1pcy1hLW5ldy1mY20tdG9rZW4..."
}
```

**Response (`200 OK`):** Returns updated `SettingsResponse`.

---

## 6. Search Users

Used for user mentions in comments and searching users to start chat conversations.

- **Method / Path:** `GET /api/v1/users/search?search=Jane&page=1&limit=20`
- **Auth:** Bearer JWT required

### Query Parameters
| Param | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `search` | `string` | Yes | - | Partial name query (matched case-insensitively) |
| `page` | `integer`| No | 1 | Page number |
| `limit` | `integer`| No | 20 | Page size |

### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
      "full_name": "Jane Doe",
      "major": "Computer Science",
      "avatar_url": "http://localhost:19000/vithey/avatars/jane.png"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
```
