# Content Service — Common Context

## Service Role
Social content: video/poster/job posts, comments with @mentions, likes/reactions, and follow relationships.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `content-service` |
| Port | 8084 |
| Database | `content_db` |
| Package | `com.vithey.content` |

## Entities
- `Post` — id, authorId, type (VIDEO/POSTER/JOB), content, mediaUrl, jobMeta (JSON), createdAt
- `Comment` — id, postId, authorId, text, mentions (UUID[]), createdAt
- `Reaction` — id, postId, userId, type (LIKE), unique(postId, userId)
- `Follow` — id, followerId, followingId, unique pair

## Events Published
`post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`

## API Prefixes
`/api/v1/posts/**`, `/api/v1/comments/**`, `/api/v1/reactions/**`, `/api/v1/follows/**`

## Job Post Note
Job-specific fields (title, description, requirement, deadline) stored in `jobMeta` JSON or embedded columns. Full job application flow is in Career Service.
