# Content Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`, `integration-contract.md`.  
> **Scope:** Backend REST API only — posts, comments, reactions, follows.  
> **Authority:** This file reflects the implemented service. Prefer it over older notes that mention feed `sort=` or top-level `/comments` controllers.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/content-service/` |
| Port | 8084 |
| Eureka | `content-service` |
| Database | `content_db` |
| Package | `com.vithey.content` |
| Swagger | `http://localhost:8084/swagger-ui.html` |

## Spring Cloud + tools

Eureka, Config, OpenFeign (`FeignAuthConfig` header forwarding), RabbitMQ publisher (`Jackson2JsonMessageConverter`), JPA, Flyway (V1–V3), MapStruct, springdoc (`@Tag` / `@Operation` / `@Schema`).

## Folder structure

```text
services/content-service/
└── src/main/java/com/vithey/content/
    ├── ContentServiceApplication.java
    ├── config/SecurityConfig.java, RabbitMqConfig.java, OpenApiConfig.java, FeignAuthConfig.java
    ├── controller/
    │   ├── PostController.java
    │   ├── CommentController.java
    │   ├── ReactionController.java
    │   └── FollowController.java
    ├── service/PostService.java, CommentService.java, ReactionService.java, FollowService.java, FeedService.java, PostSearchService.java, PostEnrichmentService.java
    ├── repository/PostRepository.java, CommentRepository.java, ReactionRepository.java, FollowRepository.java, MentionRepository.java
    ├── entity/Post.java, Comment.java, Reaction.java, Follow.java, JobPostMeta.java (embedded or separate)
    ├── dto/request/CreatePostRequest.java, CreateCommentRequest.java
    ├── dto/response/PostResponse.java, CommentResponse.java, ReactionSummaryResponse.java
    ├── mapper/PostMapper.java, CommentMapper.java
    ├── client/UserProfileClient.java, FileServiceClient.java
    ├── event/publisher/ContentEventPublisher.java
    ├── event/payload/PostCreatedEvent.java, CommentAddedEvent.java, ...
    └── exception/GlobalExceptionHandler.java
```

See `FOLDER_STRUCTURE.md`. Notable pieces: `FeignAuthConfig`, `PostEnrichmentService.enrichAll`, `V3__Restore_reaction_and_mention_indexes.sql`, `PostServiceTest`.

## Database entities

**Post:** `id`, `author_id`, `type` VIDEO\|POSTER\|JOB, `content`, `media_file_id`, job columns, `created_at`, `updated_at`, `deleted_at`

**Comment:** `id`, `post_id`, `author_id`, `text`, `created_at`

**Mention:** `id`, `comment_id`, `mentioned_user_id`

**Reaction:** `id`, `post_id`, `user_id`, unique(`post_id`, `user_id`)

**Follow:** `id`, `follower_id`, `following_id`, unique pair

## Complete API (all JWT)

Pagination: `page` default `1` (1-based, clamped), `limit` default `20` max `50`. Feed order: `created_at DESC` only (no `sort` param).

### Posts

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| GET | `/api/v1/posts` | Feed (no `search`) OR global search (`?search=&type=`) | 200 |
| POST | `/api/v1/posts` | Create VIDEO/POSTER/JOB post | 201 |
| GET | `/api/v1/posts/{postId}` | Post detail (not soft-deleted) | 200 |
| DELETE | `/api/v1/posts/{postId}` | Soft-delete own post | 204 |
| GET | `/api/v1/users/{userId}/posts` | User posts `?type=VIDEO\|POSTER\|JOB` | 200 |

**Create VIDEO/POSTER** (upload via file-service first):
```json
{ "type": "VIDEO", "content": "Check out my project", "media_file_id": "uuid" }
```

**Create JOB:**
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

**Post response:**
```json
{
  "data": {
    "post_id": "uuid",
    "author": { "user_id": "uuid", "full_name": "Jane", "avatar_url": "..." },
    "type": "JOB",
    "content": "...",
    "media_url": null,
    "job_meta": { "title": "...", "description": "...", "requirement": "...", "deadline": "2026-08-01" },
    "reaction_count": 5,
    "comment_count": 2,
    "user_reacted": false,
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

### Comments

| Method | Path | HTTP |
|--------|------|------|
| GET | `/api/v1/posts/{postId}/comments` | 200 |
| POST | `/api/v1/posts/{postId}/comments` | 201 |
| PATCH | `/api/v1/posts/{postId}/comments/{commentId}` | 200 — author only, body `{ "text": "..." }` |
| DELETE | `/api/v1/posts/{postId}/comments/{commentId}` | 204 (author only) |

```json
{ "text": "Great post!", "mention_user_ids": ["uuid"] }
```

### Reactions

| Method | Path | HTTP |
|--------|------|------|
| POST | `/api/v1/posts/{postId}/reactions` | 200 toggle like |
| GET | `/api/v1/posts/{postId}/reactions` | 200 `{ reaction_count, user_reacted }` |

### Follows

| Method | Path | HTTP |
|--------|------|------|
| POST | `/api/v1/users/{userId}/follow` | 201 (empty body; idempotent) |
| DELETE | `/api/v1/users/{userId}/follow` | 204 |
| GET | `/api/v1/users/{userId}/followers` | 200 paginated |
| GET | `/api/v1/users/{userId}/following` | 200 paginated |

## Business logic

| Rule | Implementation |
|------|----------------|
| Feed | Posts where `author_id IN (following ∪ self)` ORDER BY `created_at DESC` — **only when `search` param absent** |
| Search posts | When `search` present: ILIKE on `content`, `job_title`, `job_description`; optional `type`; exclude `deleted_at` — see `_shared/SEARCH.md` |
| Enrichment | Batch counts + in-request author/media cache (`PostEnrichmentService.enrichAll`) |
| Like toggle | Insert reaction or delete if exists → publish `reaction.added` on insert only |
| Comment | Save + persist mention IDs → publish `comment.added`, `mention.created` |
| Follow | Reject self-follow; skip insert if pair exists → publish `follow.created` on new edge |
| Create post | Validate `media_file_id` via FileServiceClient for VIDEO/POSTER (type must match) |
| Soft delete | Owner only; set `deleted_at` |
| Edit comment | Author only; updates `text`, returns enriched `CommentResponse` |
| Delete comment | Author only; deletes mentions then comment row; no event published |
| Feign | Forward JWT / gateway user headers |
| Events | JSON RabbitMQ payloads; publish failures logged, do not mask as 401 |

## Events published

`post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`

## Errors

| Case | Code | HTTP |
|------|------|------|
| Validation / invalid enum / unreadable JSON | `VALIDATION_ERROR` | 400 |
| Invalid or missing media file | `INVALID_FILE` | 400 |
| Missing/invalid JWT | `UNAUTHORIZED` | 401 |
| Not post owner on delete | `FORBIDDEN` | 403 |
| Not comment author on edit/delete | `FORBIDDEN` | 403 |
| Post not found / deleted | `NOT_FOUND` | 404 |
| Comment not found on edit/delete | `NOT_FOUND` | 404 |
| Follow self | `BUSINESS_RULE_VIOLATION` | 422 |
| Unexpected / Feign failure | `INTERNAL_ERROR` | 500 |

## Tests

- `FollowServiceTest` — self-follow rejection
- `PostServiceTest` — media/job validation, JOB create + event, mismatched media type
- `CommentServiceTest` — delete own comment, delete other's → 403, missing → 404, edit own comment, edit other's → 403

## Local testing

- Postman: `postman/Content-Module.postman_collection.json` + `Vithey-Local.postman_environment.json`
- See root `prompt/Prompt Backend/README.md` API testing section

## Output

Runnable content-service on **8084**.
