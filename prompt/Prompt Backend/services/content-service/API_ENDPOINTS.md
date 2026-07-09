# Content Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT.

## Posts

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/posts?page=&limit=&sort=` | Home feed (no `search` param) |
| GET | `/posts?search=&type=&page=&limit=` | **Global content search** — posters, videos, jobs |
| POST | `/posts` | Create VIDEO, POSTER, or JOB post |
| GET | `/posts/{post_id}` | Post detail |
| DELETE | `/posts/{post_id}` | Delete own post |
| GET | `/users/{user_id}/posts?type=` | User profile post list |

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

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/posts/{post_id}/comments` | Paginated comments |
| POST | `/posts/{post_id}/comments` | Add comment and mentions |

## Reactions

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/posts/{post_id}/reactions` | Toggle like/reaction |
| GET | `/posts/{post_id}/reactions` | Count and current user's state |

## Follows

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/users/{user_id}/follow` | Follow user |
| DELETE | `/users/{user_id}/follow` | Unfollow user |
| GET | `/users/{user_id}/followers` | Followers list |
| GET | `/users/{user_id}/following` | Following list |

## Create job post body

```json
{
  "type": "JOB",
  "content": "We are hiring",
  "job_meta": {
    "title": "Flutter Intern",
    "description": "...",
    "requirement": "Year 3+ CS",
    "deadline": "2026-08-01"
  }
}
```

