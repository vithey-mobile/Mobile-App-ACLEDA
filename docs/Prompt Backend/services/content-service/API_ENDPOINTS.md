# Content Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT. JSON uses **snake_case**.

Pagination: `page` is **1-based** (default `1`, values `< 1` clamp to `1`). `limit` default `20`, max `50`.

Feed ordering is **newest first** (`created_at DESC`). There is **no** `sort` query parameter.

Swagger UI: `http://localhost:8084/swagger-ui.html` (Authorize with Bearer JWT).

## Posts

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| GET | `/posts?page=&limit=` | Home feed (followed users + self, no `search`) | 200 |
| GET | `/posts?search=&type=&page=&limit=` | **Global content search** — posters, videos, jobs | 200 |
| POST | `/posts` | Create VIDEO, POSTER, or JOB post | 201 |
| GET | `/posts/{post_id}` | Post detail (active only) | 200 |
| DELETE | `/posts/{post_id}` | Soft-delete own post | 204 |
| GET | `/users/{user_id}/posts?type=&page=&limit=` | User profile post list | 200 |

`type` filter values: `VIDEO` \| `POSTER` \| `JOB`.

## GET `/posts` — feed vs search

| `search` param | Behavior |
| --- | --- |
| **Omitted** | Home feed — posts from followed users + self, `sort=newest` |
| **Present** (≥ 2 chars) | Global search — all visible public posts matching text |

### Search query parameters

| Param | Type | Required | Default | Validation |
| --- | --- | --- | --- | --- |
| `search` | string | no | — | when present: min 2, max 200 |
| `type` | enum | no | all | `POSTER` \| `VIDEO` \| `JOB` |
| `page` | int | no | 1 | ≥ 1 |
| `limit` | int | no | 10 | 1–50 |

### Search response `200`

Same `PostResponse` shape as feed. Matches text in `content`, `job_title`, `job_description`.

```json
{
  "data": [
    {
      "id": "uuid",
      "type": "JOB",
      "content": "Multiple position at Aeon Mall",
      "author": { "id": "uuid", "full_name": "AUB Career Center" },
      "media_url": "https://...",
      "thumbnail_url": "https://...",
      "job_meta": { "title": "Multiple position", "description": "..." },
      "created_at": "2026-07-09T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 10, "total": 42, "total_pages": 5 }
}
```

**Full spec:** `Prompt Backend/_shared/SEARCH.md`

## Comments

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| GET | `/posts/{post_id}/comments?page=&limit=` | Paginated comments (newest first) | 200 |
| POST | `/posts/{post_id}/comments` | Add comment and optional mentions | 201 |
| PATCH | `/posts/{post_id}/comments/{comment_id}` | Edit comment text — author only | 200 |
| DELETE | `/posts/{post_id}/comments/{comment_id}` | Delete own comment — author only | 204 |

## Reactions

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| POST | `/posts/{post_id}/reactions` | Toggle like | 200 |
| GET | `/posts/{post_id}/reactions` | Count + current user's state | 200 |

## Follows

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| POST | `/users/{user_id}/follow` | Follow user (idempotent if already following) | 201 |
| DELETE | `/users/{user_id}/follow` | Unfollow user | 204 |
| GET | `/users/{user_id}/followers?page=&limit=` | Followers list | 200 |
| GET | `/users/{user_id}/following?page=&limit=` | Following list | 200 |

## Create bodies

**VIDEO / POSTER** (upload media via file-service first):

```json
{
  "type": "POSTER",
  "content": "Check out my project",
  "media_file_id": "f6efaa58-4dbd-4a08-8a6c-7bb59b15f589"
}
```

**JOB:**

```json
{
  "type": "JOB",
  "content": "We are hiring",
  "job_meta": {
    "title": "Flutter Intern",
    "description": "Build mobile features",
    "requirement": "Year 3+ CS",
    "deadline": "2026-08-01"
  }
}
```

**Comment:**

```json
{
  "text": "Great post!",
  "mention_user_ids": ["018a4379-a9e0-4391-8285-c231aeea577c"]
}
```

**Edit comment** (`PATCH /posts/{post_id}/comments/{comment_id}`):

```json
{ "text": "Great post! (edited)" }
```

## Empty-body responses

- `DELETE /posts/{post_id}` → `204`
- `POST /users/{user_id}/follow` → `201` (no body)
- `DELETE /posts/{post_id}/comments/{comment_id}` → `204`
- `DELETE /users/{user_id}/follow` → `204`

### Comment edit/delete rules

| Rule | Behavior |
| --- | --- |
| Author only | `PATCH` / `DELETE` compare `X-User-Id` with `comments.author_id`; not author → `403 FORBIDDEN` |
| Comment missing or not on post | `404 NOT_FOUND` |
| Post soft-deleted | `404 NOT_FOUND` (same as add/list) |
| Delete | Removes mentions then the comment row; no event published |

## Gateway notes

api-gateway routes content traffic for `/api/v1/posts/**` and `/api/v1/users/*/follow|followers|following|posts`. Controllers do **not** expose top-level `/api/v1/comments/**`, `/reactions/**`, or `/follows/**`.
