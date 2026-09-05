# Prompt 2 of 3 — Upgrade existing services

Copy everything below the line into a **new chat** after Prompt 1 is merged. Do not create map-service again. Do not write Flutter.

---

You are a Spring Boot backend agent in the Vithey repo. **Close contract gaps** so existing Java services match Flutter `vithey_app/lib/core/constants/api_endpoints.dart` and `prompt/Prompt Frontend/api-intergration/integration-contract.md`.

## Read first

1. `prompt/Prompt Backend/LEARNING.md`
2. `prompt/Prompt Frontend/api-intergration/integration-contract.md`
3. Current controllers under `backend/services/*/src/main/java/`
4. The service files listed per gap below

## Rules

- **Backend only.** Match existing package style, envelope, snake_case, Flyway versioning, tests.
- Do **not** add a new microservice.
- Do **not** implement Google OAuth.
- Do **not** add a startup/onboarding API (Flutter `StartupController` is local-only).
- Do **not** add a `/jobs` CRUD API. Job listings are `GET /api/v1/posts?type=JOB` on content-service.
- Do **not** restyle or move Flutter modules.
- If a spec and Flutter disagree on HTTP verb, **Flutter wins** for the path/verb; then update the prompt spec to match.

## Gaps to implement (all of them)

### 1. auth-service — change password

Flutter: `PATCH /auth/me/password` with `{ "current_password", "new_password" }` (`AuthService.changePassword`).

| Item | Value |
|------|-------|
| Method / path | `PATCH /api/v1/auth/me/password` |
| Auth | JWT / `X-User-Id` |
| HTTP | `200` `{ "data": { "message": "..." } }` |
| Wrong current password | `401` `INVALID_CREDENTIALS` |
| Weak new password | `400` `VALIDATION_ERROR` |

Logic: load user → BCrypt check current → hash new → save. Do not rotate refresh tokens unless the service already does that on password reset (then do the same here).

Update: `prompt/Prompt Backend/services/auth-service/API_ENDPOINTS.md`, `SERVICE_PROMPT.md`, `SERVICE_LOGIC.md`.

### 2. content-service — delete comment

Flutter: `DELETE /posts/{postId}/comments/{commentId}` (`post_service.dart`).

| Item | Value |
|------|-------|
| Method / path | `DELETE /api/v1/posts/{postId}/comments/{commentId}` |
| Auth | comment author only (or post owner if you already have that rule — document it) |
| HTTP | `204` |
| Missing / not owner | `404` / `403` |

If Flutter also PATCHes the same path to edit text, implement `PATCH` with `{ "text": "..." }` (author only). Read `vithey_app/lib/data/services/post_service.dart` and match both calls.

Update: `API_ENDPOINTS.md`, `SERVICE_PROMPT.md`, `SERVICE_LOGIC.md` under content-service.

### 3. notification-service — UI contract

The spec is already written. **Implement the code.**

Read and follow:

- `prompt/Prompt Backend/services/notification-service/UPGRADE_FOR_UI.md`
- `prompt/Prompt Backend/services/notification-service/API_ENDPOINTS.md`

Must work:

| Method | Path |
|--------|------|
| GET | `/api/v1/notifications?page=&limit=&is_read=` |
| GET | `/api/v1/notifications/unread-count` |
| PATCH | `/api/v1/notifications/{id}/read` |
| PATCH | `/api/v1/notifications/read-all` |
| DELETE | `/api/v1/notifications/{id}` → **204** |
| POST/DELETE | `/api/v1/notifications/devices` (already exists — keep) |

List item **must** include `actor`, `destination`, `event`, `dedupe_key`, `read_at`. Meta **must** include `unread_total`.

Add Flyway only if columns are missing. Do not duplicate `UPGRADE_FOR_UI.md` as a new essay — implement it.

### 4. career-service — CV preview

Flutter: `GET /job-applications/{id}/cv-preview` → reads `download_url` or `url` (`CvRepository.getApplicantCvDownloadUrl`).

| Item | Value |
|------|-------|
| Method / path | `GET /api/v1/job-applications/{applicationId}/cv-preview` |
| Who | applicant **or** job poster (verify via content-service like other career endpoints) |
| HTTP | `200` |

```json
{
  "data": {
    "application_id": "uuid",
    "cv_file_id": "uuid",
    "cv_file_name": "resume.pdf",
    "download_url": "https://..."
  }
}
```

Resolve `download_url` through existing `FileServiceClient` (same as other file metadata/download helpers). `404` if application missing; `403` if neither applicant nor poster.

Update: career `API_ENDPOINTS.md`, `SERVICE_PROMPT.md`.

### 5. ai-service — Flutter chatbot extras

Flutter already defines:

- `POST /ai/chat/stream`
- `POST /ai/messages/{messageId}/regenerate`
- `DELETE /ai/chat/requests/{requestId}`
- existing `POST /ai/chat`, sessions CRUD

Implement these on the **current Java stub** (do not replace with Python in this chat).

| Path | Behavior |
|------|----------|
| `POST /api/v1/ai/chat/stream` | Same body as `/ai/chat`; respond `text/event-stream` (or documented chunk JSON if the stub cannot SSE — prefer SSE). Persist the final assistant message. |
| `POST /api/v1/ai/messages/{id}/regenerate` | Owner-only; replace last assistant reply; `200` same shape as chat |
| `DELETE /api/v1/ai/chat/requests/{requestId}` | Cancel in-flight generation if you track ids; otherwise `204` no-op if already finished, `404` if unknown |

Keep `POST /ai/cv/suggest`. Update `prompt/Prompt Backend/services/ai-service/API_ENDPOINTS.md` so stream/regenerate/cancel are no longer “planned only”.

### 6. Gateway leftover (small, required)

In `backend/infrastructure/config-repo/api-gateway.yml` **and** `backend/services/api-gateway/.../application.yml`:

- **Keep** `/api/v1/job-applications/**` → career-service
- **Remove** `/api/v1/jobs/**` → career-service (orphan; Flutter never calls it; job posts are content `/posts`)
- **Keep** `/api/v1/places/**` if Prompt 1 added it; add it if missing
- Ensure these exist (they may already be in YAML):
  - `/api/v1/users/*/posts` → content-service (before `/users/**`)
  - `/api/v1/users/*/report` → chat-service (before `/users/**`)

Update `prompt/Prompt Backend/services/api-gateway/API_ENDPOINTS.md` and `SERVICE_PROMPT.md` to the same table. Full contract rewrite is Prompt 3 — here only keep YAML + gateway prompt files honest.

## Do not change

- file-service, finance-service, chat-service (unless a compile breaks from gateway YAML)
- map-service domain logic
- Flutter

## Tests

Add or extend unit tests:

- Auth: wrong current password; happy path
- Content: delete own comment; delete someone else’s → 403
- Notification: `is_read=false` filter; delete owner-only
- Career: cv-preview applicant vs stranger
- AI: regenerate owner isolation

## Stop when

- Flutter paths above would not 404 on a running gateway
- Prompt specs listed above match the new code
- `mvn -pl services/auth-service,services/content-service,services/notification-service,services/career-service,services/ai-service,services/api-gateway -am test` (or equivalent) passes
- Print a table: service → endpoints added

Do not write DevOps compose/CI or Postman (Prompt 3).
