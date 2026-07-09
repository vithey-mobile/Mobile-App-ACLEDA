# Content Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`, `integration-contract.md`.  
> **Scope:** Backend REST API only — posts, comments, reactions, follows.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/content-service/` |
| Port | 8084 |
| Eureka | `content-service` |
| Database | `content_db` |
| Package | `com.vithey.content` |

## Spring Cloud + tools

Eureka, Config, OpenFeign, RabbitMQ publisher, JPA, Flyway, MapStruct, springdoc.

## Folder structure

```text
services/content-service/
└── src/main/java/com/vithey/content/
    ├── ContentServiceApplication.java
    ├── config/SecurityConfig.java, RabbitMqConfig.java, OpenApiConfig.java
    ├── controller/
    │   ├── PostController.java
    │   ├── CommentController.java
    │   ├── ReactionController.java
    │   └── FollowController.java
    ├── service/PostService.java, CommentService.java, ReactionService.java, FollowService.java, FeedService.java
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

## Database entities

**Post:** `id`, `author_id`, `type` VIDEO|POSTER|JOB, `content` text, `media_file_id`, `job_title`, `job_description`, `job_requirement`, `job_deadline`, `created_at`, `deleted_at`

**Comment:** `id`, `post_id`, `author_id`, `text`, `created_at`

**Mention:** `id`, `comment_id`, `mentioned_user_id`

**Reaction:** `id`, `post_id`, `user_id`, unique(post_id, user_id)

**Follow:** `id`, `follower_id`, `following_id`, unique pair

## Complete API (all JWT)

### Posts

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| GET | `/api/v1/posts` | Feed: followed users + own, paginated | 200 |
| POST | `/api/v1/posts` | Create VIDEO/POSTER/JOB post | 201 |
| GET | `/api/v1/posts/{postId}` | Post detail | 200 |
| DELETE | `/api/v1/posts/{postId}` | Delete own post | 204 |
| GET | `/api/v1/users/{userId}/posts` | User posts `?type=VIDEO` | 200 |

**Create VIDEO/POSTER:**
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
    "job_meta": { "title": "...", "deadline": "2026-08-01" },
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

```json
{ "text": "Great post @jane!", "mention_user_ids": ["uuid"] }
```

### Reactions

| Method | Path | HTTP |
|--------|------|------|
| POST | `/api/v1/posts/{postId}/reactions` | 200 toggle like |
| GET | `/api/v1/posts/{postId}/reactions` | 200 count + user_reacted |

### Follows

| Method | Path | HTTP |
|--------|------|------|
| POST | `/api/v1/users/{userId}/follow` | 201 |
| DELETE | `/api/v1/users/{userId}/follow` | 204 |
| GET | `/api/v1/users/{userId}/followers` | 200 paginated |
| GET | `/api/v1/users/{userId}/following` | 200 paginated |

## Business logic

| Rule | Implementation |
|------|----------------|
| Feed | Posts where `author_id IN (following ∪ self)` ORDER BY `created_at DESC` |
| Like toggle | Insert reaction or delete if exists → publish `reaction.added` |
| Comment | Save + parse mentions → publish `comment.added`, `mention.created` |
| Follow | Reject self-follow → publish `follow.created` |
| Create post | Validate media_file_id via FileServiceClient for VIDEO/POSTER |

## Events published

`post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`

## Errors

| Case | HTTP |
|------|------|
| Post not found | 404 |
| Not post owner on delete | 403 |
| Follow self | 422 |
| Invalid media file | 400 |

## Output

Runnable content-service on **8084**.
