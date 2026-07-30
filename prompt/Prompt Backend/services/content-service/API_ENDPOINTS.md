# Content Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT. JSON uses **snake_case**.

Pagination: `page` is **1-based** (default `1`, values `< 1` clamp to `1`). `limit` default `20`, max `50`.

Feed ordering is **newest first** (`created_at DESC`). There is **no** `sort` query parameter.

Swagger UI: `http://localhost:8084/swagger-ui.html` (Authorize with Bearer JWT).

## Posts

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| GET | `/posts?page=&limit=` | Home feed (followed users + self) | 200 |
| POST | `/posts` | Create VIDEO, POSTER, or JOB post | 201 |
| GET | `/posts/{post_id}` | Post detail (active only) | 200 |
| DELETE | `/posts/{post_id}` | Soft-delete own post | 204 |
| GET | `/users/{user_id}/posts?type=&page=&limit=` | User profile post list | 200 |

`type` filter values: `VIDEO` \| `POSTER` \| `JOB`.

## Comments

| Method | Path | Purpose | HTTP |
| --- | --- | --- | --- |
| GET | `/posts/{post_id}/comments?page=&limit=` | Paginated comments (newest first) | 200 |
| POST | `/posts/{post_id}/comments` | Add comment and optional mentions | 201 |

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

## Empty-body responses

- `DELETE /posts/{post_id}` → `204`
- `POST /users/{user_id}/follow` → `201` (no body)
- `DELETE /users/{user_id}/follow` → `204`

## Gateway notes

api-gateway routes content traffic for `/api/v1/posts/**` and `/api/v1/users/*/follow|followers|following|posts`. Controllers do **not** expose top-level `/api/v1/comments/**`, `/reactions/**`, or `/follows/**`.
