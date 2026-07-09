# Global Search — Backend Specification (Cross-Service)

**Single source of truth** for implementing Facebook-style **global search** on the Vithey backend.

Used by:
- Flutter `SearchScreen` (`Prompt Frontend/Screen prompt/search/`)
- Entry points: Home app bar, Chat list, **Notification center** app bar
- Services: **user-profile-service** (people) + **content-service** (posts/jobs/videos)

## Architecture

```text
Flutter SearchScreen
    │
    ├── GET /api/v1/users/search?search=&page=&limit=
    │         └── user-profile-service :8082  (user_db)
    │
    └── GET /api/v1/posts?search=&type=&page=&limit=
              └── content-service :8084       (content_db)
```

Gateway routes (existing):
- `/api/v1/users/**` → `user-profile-service` (includes `/users/search`)
- `/api/v1/posts/**` → `content-service` (extend `GET /posts` with `search` param)

**No new microservice.** Search is query extensions on existing services.

## Flutter contract mirror

`Prompt Frontend/api-intergration/integration-contract.md` · `Screen prompt/search/04.search_api_backend.md`

| Flutter path (no `/api/v1`) | Backend path |
|-----------------------------|--------------|
| `GET /users/search` | `GET /api/v1/users/search` |
| `GET /posts?search=&type=` | `GET /api/v1/posts?search=&type=` |

## 1. People search — user-profile-service

### Endpoint

| Method | Path | Auth |
|--------|------|------|
| GET | `/api/v1/users/search` | JWT required |

### Query parameters

| Param | Type | Required | Default | Rules |
|-------|------|----------|---------|-------|
| `search` | string | yes | — | min 2, max 100 chars after trim |
| `page` | int | no | 1 | ≥ 1 |
| `limit` | int | no | 20 | 1–50 |

### Success response `200`

```json
{
  "data": [
    {
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "full_name": "Heng Liza",
      "avatar_url": "https://minio/.../avatar.jpg",
      "university": "American University of Phnom Penh",
      "major": "Web Development",
      "headline": "Graphic designer"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 3,
    "total_pages": 1
  }
}
```

| Field | Source | Notes |
|-------|--------|-------|
| `headline` | computed | `"{major} · {university}"` or `workplace` when added to schema |
| `avatar_url` | `profiles.avatar_url` | nullable |
| Email / phone | **never** returned | public search only |

### Search algorithm (v1)

```sql
SELECT user_id, full_name, avatar_url, university, major
FROM profiles
WHERE full_name ILIKE '%' || :search || '%'
   OR university ILIKE '%' || :search || '%'
   OR major ILIKE '%' || :search || '%'
ORDER BY
  CASE WHEN full_name ILIKE :search || '%' THEN 0 ELSE 1 END,
  full_name ASC
LIMIT :limit OFFSET (:page - 1) * :limit;
```

**v2 (recommended):** PostgreSQL `pg_trgm` GIN index on `full_name` for prefix/fuzzy match.

### Privacy rules

| Rule | Behavior |
|------|----------|
| `privacy_prefs.profile_visible = false` | Exclude from search results |
| Blocked users (future chat-service) | Exclude both directions |
| Current user | May appear in results |

### Errors

| HTTP | Code | When |
|------|------|------|
| 400 | `VALIDATION_ERROR` | `search` missing or &lt; 2 chars |
| 401 | `UNAUTHORIZED` | No JWT |
| 429 | `RATE_LIMITED` | Gateway rate limit exceeded |

### Rate limit (gateway)

| Endpoint | Limit |
|----------|-------|
| `GET /users/search` | 60 req/min per `X-User-Id` |

### Implementation checklist — user-profile-service

- [ ] `UserSearchController` or method on `UserController`
- [ ] `UserSearchService.search(query, page, limit)`
- [ ] `ProfileRepository` custom `@Query` with ILIKE + pagination
- [ ] Flyway `V2__search_indexes.sql` — trigram on `full_name`
- [ ] OpenAPI tag `User Search`
- [ ] Integration test: search by partial name, pagination, min length 400

**Detailed service docs:** `services/user-profile-service/API_ENDPOINTS.md` · `SERVICE_LOGIC.md`

---

## 2. Content search — content-service

### Endpoint

Extend existing feed endpoint — **do not** add `/posts/search`.

| Method | Path | Auth |
|--------|------|------|
| GET | `/api/v1/posts` | JWT required |

### Query parameters (extended)

| Param | Type | Required | Default | Rules |
|-------|------|----------|---------|-------|
| `search` | string | no | — | When present: min 2, max 200 chars |
| `type` | enum | no | all types | `POSTER` \| `VIDEO` \| `JOB` — omit for mixed |
| `page` | int | no | 1 | ≥ 1 |
| `limit` | int | no | 10 | 1–50 |
| `sort` | string | no | `newest` | Only `newest` in v1 |

**Mode detection:**
- `search` **absent** → existing **home feed** logic (followed users + self)
- `search` **present** → **global content search** (all visible public posts, not feed-scoped)

### Success response `200`

Same `PostResponse` list as feed:

```json
{
  "data": [
    {
      "id": "post-uuid",
      "type": "JOB",
      "content": "Multiple position at Aeon Mall",
      "author": {
        "id": "author-uuid",
        "full_name": "AUB Career Center",
        "avatar_url": "https://..."
      },
      "media_url": "https://...",
      "thumbnail_url": "https://...",
      "job_meta": {
        "title": "Multiple position",
        "description": "Aeon Mall Phnom Penh",
        "requirement": null,
        "deadline": "2026-08-01"
      },
      "reaction_count": 20,
      "comment_count": 4,
      "created_at": "2026-07-09T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 10, "total": 42, "total_pages": 5 }
}
```

### Search algorithm (v1)

```sql
SELECT p.*
FROM posts p
WHERE p.deleted_at IS NULL
  AND (:type IS NULL OR p.type = :type)
  AND (
    p.content ILIKE '%' || :search || '%'
    OR p.job_title ILIKE '%' || :search || '%'
    OR p.job_description ILIKE '%' || :search || '%'
  )
ORDER BY p.created_at DESC
LIMIT :limit OFFSET (:page - 1) * :limit;
```

Join author display name via Feign `UserProfileClient.getPublicProfile(authorId)` batch or denormalized `author_name` cache (optional v2).

### Privacy rules

| Rule | Behavior |
|------|----------|
| `deleted_at IS NOT NULL` | Never returned |
| Draft posts (future) | Never returned |
| Private posts (future) | Never returned |

### Errors

| HTTP | Code | When |
|------|------|------|
| 400 | `VALIDATION_ERROR` | `search` present but &lt; 2 chars |
| 401 | `UNAUTHORIZED` | No JWT |

### Rate limit (gateway)

| Endpoint | Limit |
|----------|-------|
| `GET /posts?search=*` | 60 req/min per `X-User-Id` |

### Implementation checklist — content-service

- [ ] Extend `PostController.listPosts()` — branch on `search` param
- [ ] `PostSearchService` or method in `PostService`
- [ ] `PostRepository.searchByText(search, type, pageable)`
- [ ] Flyway `V2__post_search_indexes.sql` — GIN/trigram on `content`, `job_title`
- [ ] Do **not** break existing feed when `search` omitted
- [ ] Integration test: search job title, filter by type, feed unchanged without search

**Detailed service docs:** `services/content-service/API_ENDPOINTS.md` · `SERVICE_LOGIC.md`

---

## 3. Optional — presence for Recent subtitle

Not required for v1 search. Flutter mocks **"last seen recently"**.

| Method | Path | Service | Future |
|--------|------|---------|--------|
| GET | `/api/v1/users/{id}/presence` | chat-service or user-profile | `online`, `last_seen_at` |

---

## 4. What is NOT server-side

| Feature | Owner |
|---------|-------|
| Recent search users | Flutter `SearchRecentStore` (shared_preferences) |
| Debounce 350ms | Flutter `SearchController` |
| Grouped UI sections | Flutter only |
| Notification inbox search | Opens same `SearchScreen` — **no** `GET /notifications?search=` in v1 |

---

## 5. Gateway notes

No new routes. Ensure route order unchanged:

```text
/api/v1/posts/**     → content-service   (before users wildcard)
/api/v1/users/**     → user-profile-service
```

Add rate-limit filter for search query patterns in `api-gateway` `RateLimitConfig` (optional v1).

---

## 6. Event / audit (optional)

Do **not** publish RabbitMQ events on search. Optional audit log:

```text
search.query | userId | queryLength | resultCount | service
```

No PII in production logs (log length only, not query text).

---

## 7. Reading order for implementers

1. This file (`_shared/SEARCH.md`)
2. `services/user-profile-service/SERVICE_PROMPT.md` — people search
3. `services/content-service/SERVICE_PROMPT.md` — post search extension
4. `Prompt Frontend/Screen prompt/search/04.search_api_backend.md` — Flutter wiring
5. `Prompt Frontend/api-intergration/integration-contract.md` — contract table

## 8. Acceptance criteria (backend)

- [ ] `GET /api/v1/users/search?search=heng` returns paginated profiles
- [ ] `GET /api/v1/posts?search=workshop&type=POSTER` returns matching posters
- [ ] `GET /api/v1/posts?page=1` without `search` still returns home feed
- [ ] Validation 400 when `search` length &lt; 2
- [ ] No email/phone in user search results
- [ ] OpenAPI documents both endpoints
- [ ] Flutter `SearchRepository` works with `USE_MOCK_API=false`
