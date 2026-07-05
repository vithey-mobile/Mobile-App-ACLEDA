# Content Service Architecture

## Responsibility

Owns social feed posts, comments, reactions, mentions, and the follow graph.

Does not own user profile fields, file bytes, job applications, or notifications.

## Dependencies

| Service | Usage |
| --- | --- |
| `user-profile-service` | Author summaries for posts, comments, and follow lists |
| `file-service` | Validate and resolve media URLs for VIDEO/POSTER posts |
| `rabbitmq` | Publish domain events |
| `eureka-server` | Service discovery |
| `config-server` | Externalized configuration |

## Data store

PostgreSQL database `content_db` with tables: `posts`, `comments`, `mentions`, `reactions`, `follows`.

Posts use soft delete via `deleted_at`.

## Key flows

1. **Feed** — posts from followed users plus self, newest first.
2. **Create post** — validate media via file-service for VIDEO/POSTER; publish `post.created`.
3. **Comment** — save comment and mentions; publish `comment.added` and `mention.created`.
4. **Reaction** — toggle one reaction per user/post; publish `reaction.added` on insert.
5. **Follow** — reject self-follow; publish `follow.created`.

## Port

`8084` (Eureka name: `content-service`)
