# Content Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT.

## Posts

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/posts?page=&limit=&sort=` | Home feed |
| POST | `/posts` | Create VIDEO, POSTER, or JOB post |
| GET | `/posts/{post_id}` | Post detail |
| DELETE | `/posts/{post_id}` | Delete own post |
| GET | `/users/{user_id}/posts?type=` | User profile post list |

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

