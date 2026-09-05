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
| Swagger | `http://localhost:8084/swagger-ui.html` |

## Entities

- `Post` — id, authorId, type (`VIDEO`/`POSTER`/`JOB`), content, mediaFileId, job fields (title/description/requirement/deadline), createdAt, updatedAt, deletedAt
- `Comment` — id, postId, authorId, text, createdAt
- `Mention` — id, commentId, mentionedUserId
- `Reaction` — id, postId, userId, unique(postId, userId)
- `Follow` — id, followerId, followingId, unique pair

Job metadata is stored as **embedded columns** on `posts` (not a separate JSON document table).

## Events Published

`post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`

## API Prefixes (implemented)

- `/api/v1/posts/**` — feed, CRUD-ish posts, nested comments and reactions
- `/api/v1/users/{userId}/posts`
- `/api/v1/users/{userId}/follow|followers|following`

Gateway may also match unused `/api/v1/comments/**`, `/reactions/**`, `/follows/**` routes; **no controllers** implement those top-level paths.

## Integrations

- **file-service** — media validation + URL resolution (Feign; auth headers forwarded)
- **user-profile-service** — author summaries (Feign; auth headers forwarded)
- **RabbitMQ** — JSON message converter on exchange `vithey.events`

## Job Post Note

Job-specific fields stored on the post. Full job application flow is in Career Service.
