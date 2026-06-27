# Content Service — Service Prompt

Build the Content microservice.

## API Endpoints

### Posts
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/posts` | Paginated feed (`?page&limit&sort=-created_at`) |
| POST | `/api/v1/posts` | Create post (video/poster/job) |
| GET | `/api/v1/posts/{postId}` | Post detail |
| DELETE | `/api/v1/posts/{postId}` | Delete own post |
| GET | `/api/v1/users/{userId}/posts` | User's posts by type |

### Comments
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/posts/{postId}/comments` | List comments |
| POST | `/api/v1/posts/{postId}/comments` | Add comment with optional mentions |

### Reactions
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/posts/{postId}/reactions` | Like/unlike toggle |
| GET | `/api/v1/posts/{postId}/reactions` | Reaction count + user reacted |

### Follows
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/users/{userId}/follow` | Follow user |
| DELETE | `/api/v1/users/{userId}/follow` | Unfollow |
| GET | `/api/v1/users/{userId}/followers` | Followers list |
| GET | `/api/v1/users/{userId}/following` | Following list |

## Create Post Request (Job)
```json
{
  "type": "JOB",
  "content": "We are hiring interns",
  "job_meta": {
    "title": "Flutter Developer Intern",
    "description": "...",
    "requirement": "Year 3+ CS",
    "deadline": "2026-08-01"
  }
}
```

## Create Post Request (Video/Poster)
```json
{
  "type": "VIDEO",
  "content": "Check out my project",
  "media_file_id": "uuid-from-file-service"
}
```

## Comment Request
```json
{
  "text": "Great post @jane_doe!",
  "mention_user_ids": ["uuid"]
}
```

## Business Rules
- Feed shows posts from followed users + own posts (chronological)
- Mention parsing: extract `@username` or use explicit `mention_user_ids`
- Toggle like: create reaction if absent, delete if exists
- Cannot follow self

## Required Modules
- `PostController`, `CommentController`, `ReactionController`, `FollowController`
- Corresponding services and repositories
- `ContentEventPublisher` (RabbitMQ)
- `UserProfileClient` — fetch author display names for feed (optional cache)
- Flyway, OpenAPI, tests

## Output
Runnable content-service on port 8084.
