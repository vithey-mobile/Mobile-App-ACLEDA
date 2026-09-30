# 04 — Content Service Integration Contract

> **Target Service:** `content-service`  
> **Direct Port:** `8084` | **Gateway Base URLs:** `http://localhost:8080/api/v1/posts`, `http://localhost:8080/api/v1/users/*/follow*`, `http://localhost:8080/api/v1/users/*/posts`  
> **Database:** `content_db` | **Naming Convention:** `snake_case` (Jackson globally configured)

---

## 1. Feed & Posts

### 1.1 List Posts (Home Feed or Global Search)
- **Method / Path:** `GET /api/v1/posts`
- **Auth:** Bearer JWT required

#### Query Parameters
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `search` | `string` | No | - | Keyword search in post text / job title |
| `type` | `string` | No | - | Filter by post type: `"VIDEO"`, `"POSTER"`, `"JOB"` |
| `page` | `integer`| No | 1 | 1-based page number |
| `limit` | `integer`| No | 20 | Page size (max 50) |

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "author": {
        "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
        "full_name": "ACLEDA HR Team",
        "avatar_url": "http://localhost:19000/vithey/avatars/acleda.png"
      },
      "type": "JOB",
      "content": "Exciting opportunity for junior engineers to join our mobile banking department!",
      "media_url": "http://localhost:19000/vithey/posters/banner.png",
      "job_meta": {
        "title": "Junior Flutter Developer",
        "description": "Develop and test mobile fintech flows with Clean Architecture.",
        "requirement": "Year 3/4 CS students or fresh graduates with Flutter & Dart knowledge.",
        "deadline": "2026-10-31"
      },
      "reaction_count": 42,
      "comment_count": 7,
      "user_reacted": true,
      "created_at": "2026-09-14T06:30:00Z"
    },
    {
      "post_id": "c7d8e9f0-1234-5678-9abc-def012345678",
      "author": {
        "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
        "full_name": "Bora Tech",
        "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
      },
      "type": "POSTER",
      "content": "Check out our capstone project poster presented at AUB Innovation Day!",
      "media_url": "http://localhost:19000/vithey/posters/capstone.png",
      "job_meta": null,
      "reaction_count": 18,
      "comment_count": 3,
      "user_reacted": false,
      "created_at": "2026-09-13T10:15:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

---

### 1.2 Create Post
- **Method / Path:** `POST /api/v1/posts`
- **Auth:** Bearer JWT required
- **Headers:** `Content-Type: application/json`

#### Request Schema
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `type` | `string` | Yes | `"VIDEO"`, `"POSTER"`, `"JOB"` |
| `content` | `string` | No | Post caption / description |
| `media_file_id` | `string` | Required for media | UUID of uploaded file from `file-service` |
| `job_meta` | `object` | Required if `JOB` | Job metadata object |

```json
{
  "type": "JOB",
  "content": "We are hiring interns for the mobile banking project",
  "media_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
  "job_meta": {
    "title": "Flutter Mobile Intern",
    "description": "Help build state-of-the-art student banking experiences.",
    "requirement": "Knowledge of Dart and Riverpod/Bloc.",
    "deadline": "2026-10-15"
  }
}
```

#### Response Schema (`201 Created`)
Returns created `PostResponse` in `{ "data": { ... } }`.

---

### 1.3 Get Post Detail
- **Method / Path:** `GET /api/v1/posts/{postId}`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
Returns single `PostResponse` in `{ "data": { ... } }`.

---

### 1.4 Delete Own Post
- **Method / Path:** `DELETE /api/v1/posts/{postId}`
- **Auth:** Bearer JWT required (Owner only)

#### Response Schema
- **Status:** `204 No Content`

---

### 1.5 List User Posts
- **Method / Path:** `GET /api/v1/users/{userId}/posts?type=JOB&page=1&limit=20`
- **Auth:** Bearer JWT required

Returns paginated `List<PostResponse>` for the specified profile.

---

## 2. Comments & Mentions

### 2.1 List Post Comments
- **Method / Path:** `GET /api/v1/posts/{postId}/comments?page=1&limit=20`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "comment_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "author": {
        "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
        "full_name": "Bora Tech",
        "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
      },
      "content": "Can final year students apply for this role?",
      "parent_comment_id": null,
      "created_at": "2026-09-14T07:00:00Z",
      "updated_at": null
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

---

### 2.2 Add Comment
- **Method / Path:** `POST /api/v1/posts/{postId}/comments`
- **Auth:** Bearer JWT required

#### Request Schema
```json
{
  "content": "Sounds great @Jane! I am applying now.",
  "parent_comment_id": null,
  "mention_user_ids": [
    "f984000a-38f4-46e5-a047-019d20a66ce0"
  ]
}
```

#### Response Schema (`201 Created`)
Returns created `CommentResponse` in `{ "data": { ... } }`.

---

### 2.3 Edit Comment
- **Method / Path:** `PATCH /api/v1/posts/{postId}/comments/{commentId}`
- **Auth:** Bearer JWT required (Author only)

```json
{
  "content": "Updated comment content here."
}
```
**Response (`200 OK`):** Returns updated `CommentResponse`.

---

### 2.4 Delete Comment
- **Method / Path:** `DELETE /api/v1/posts/{postId}/comments/{commentId}`
- **Auth:** Bearer JWT required (Author only)

**Response:** `204 No Content`

---

## 3. Reactions (Likes)

### 3.1 Toggle Post Reaction
Adds reaction if absent, removes it if present.

- **Method / Path:** `POST /api/v1/posts/{postId}/reactions`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "reaction_count": 43,
    "user_reacted": true
  }
}
```

### 3.2 Get Post Reactions Summary
- **Method / Path:** `GET /api/v1/posts/{postId}/reactions`
- **Auth:** Bearer JWT required

Returns `ReactionSummaryResponse` in `{ "data": { ... } }`.

---

## 4. Follow Graph

### 4.1 Follow User
- **Method / Path:** `POST /api/v1/users/{userId}/follow`
- **Auth:** Bearer JWT required

**Response:** `201 Created`

### 4.2 Unfollow User
- **Method / Path:** `DELETE /api/v1/users/{userId}/follow`
- **Auth:** Bearer JWT required

**Response:** `204 No Content`

### 4.3 List Followers
- **Method / Path:** `GET /api/v1/users/{userId}/followers?page=1&limit=20`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "full_name": "Bora Tech",
      "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 12,
    "total_pages": 1
  }
}
```

### 4.4 List Following
- **Method / Path:** `GET /api/v1/users/{userId}/following?page=1&limit=20`
- **Auth:** Bearer JWT required

Returns paginated `List<AuthorSummaryResponse>` in `{ "data": [ ... ], "meta": { ... } }`.
