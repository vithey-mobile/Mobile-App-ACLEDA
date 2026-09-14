# GLM 5.3 Flash — Terminal 4 / 10 — content-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `content-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/_shared/SEARCH.md`
- `prompt/Prompt Backend/services/content-service/` (all files)
- `vithey_app/lib/data/services/post_service.dart` (comment delete/edit verbs)
- Live code: `backend/services/content-service/`

## Identity

Port **8084** · Eureka `content-service` · DB `content_db` · package `com.vithey.content`

## Allowed paths

```text
backend/services/content-service/**
prompt/Prompt Backend/services/content-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (upgrade)

Java already exists (posts, feed, search, reactions, follows). Add Flutter gap:

`DELETE /api/v1/posts/{postId}/comments/{commentId}`

- Comment **author** only → `204`
- Not author → `403`
- Missing → `404`

If `post_service.dart` also **PATCH**es that path to edit `text`, implement `PATCH` (author only) with `{ "text": "..." }`.

Keep:

- `GET/POST /posts`, `GET/DELETE /posts/{id}`, `GET /users/{id}/posts`
- `GET /posts?search=&type=` (no new search-service)
- Job **posts** stay here (`type=JOB`). Do **not** add `/jobs/**`.

Update content `API_ENDPOINTS.md` / `SERVICE_PROMPT.md` / `SERVICE_LOGIC.md` if needed.

## Verify

- Test: delete own comment; delete someone else’s → 403
- `mvn -pl services/content-service -am test` from `backend/`

Print files changed. Stop.
