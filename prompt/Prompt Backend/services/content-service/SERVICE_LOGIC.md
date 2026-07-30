# Content Service — Service Logic

## Ownership

Owns social feed posts, comments, reactions, mentions, and follow graph.

Does not own profile fields, media bytes, CV applications, or notifications.

## Core flows

| Flow | Logic |
| --- | --- |
| Feed | Return posts from followed users plus self, ordered by newest, paginated. Enrich with batched counts + author/media resolution. |
| Create post | Validate post type; for VIDEO/POSTER validate `media_file_id` via file-service (type must match); for JOB require `job_meta.title`; save; publish `post.created`. |
| Job post | Store job metadata on post columns so career-service can verify job ownership/application target. |
| Soft delete | Owner-only; set `deleted_at` / `updated_at`. Comments/reactions remain; deleted posts return `NOT_FOUND`. |
| Comment | Save comment, persist provided `mention_user_ids`, publish `comment.added` and `mention.created` per mention. |
| Reaction | Toggle one reaction per user/post; publish `reaction.added` only on insert (not on remove). |
| Follow | Reject self-follow (`422`); if already following, return success without duplicate row; else insert and publish `follow.created`. |

## Enrichment and integrations

| Dependency | Use |
| --- | --- |
| `UserProfileClient` | Author `full_name` / `avatar_url` on posts, comments, follow lists |
| `FileServiceClient` | Validate media type on create; resolve `media_url` on read |
| Feign auth | Forward `Authorization` and `X-User-Id` / `X-User-Email` / `X-User-Roles` via `FeignAuthConfig` |
| RabbitMQ | JSON events via `Jackson2JsonMessageConverter`; publish failures are logged and do not fail the HTTP request after successful persistence |

`PostEnrichmentService.enrichAll` batches reaction/comment counts and viewer-reacted lookups for a page, and caches author/media Feign calls within the request.

## Events published

- `post.created`
- `comment.added`
- `reaction.added`
- `follow.created`
- `mention.created`

Exchange: `vithey.events` (topic).

## Frontend alignment

- Home feed uses `GET /posts` (no `sort` param).
- Post cards use reaction and comment counts from `PostResponse`.
- Create poster/video: upload via file-service first (`type=POSTER|VIDEO`), then `POST /posts` with `media_file_id`.
- Create job stores `job_meta` for application flow in career-service.

## Performance notes (local Docker)

After batch enrichment + restored `idx_reactions_post`:

| Endpoint | Scenario | Approx. time |
| --- | --- | --- |
| `GET /api/v1/posts?page=1&limit=20` | warm feed | ~47–51 ms |
| `GET /api/v1/users/{id}/posts?page=1&limit=20` | warm list | ~45–54 ms |

Do not reintroduce per-post N+1 count/Feign loops on list endpoints.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Bean validation / unreadable body / invalid enum | `VALIDATION_ERROR` | 400 |
| Media missing or type mismatch / file 404 | `INVALID_FILE` | 400 |
| Missing or invalid JWT | `UNAUTHORIZED` | 401 |
| Not post owner on delete | `FORBIDDEN` | 403 |
| Post not found or soft-deleted | `NOT_FOUND` | 404 |
| Self follow | `BUSINESS_RULE_VIOLATION` | 422 |
| Unexpected / Feign 5xx | `INTERNAL_ERROR` | 500 |

JWT filter returns JSON `UNAUTHORIZED` on bad tokens (same envelope as other APIs). Feign 404 is `INVALID_FILE` only for file-service URLs; other remote 404s map to `NOT_FOUND`.
