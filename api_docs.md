# Vithey Frontend API Docs

Single reference for Flutter (`vithey_app`) ↔ API Gateway (`:8080`) integration.  
All JSON fields are **snake_case**. Paths in Flutter are **relative to** `API_BASE_URL` (already includes `/api/v1`).

Source of truth also lives in:
- `docs/Prompt Frontend/api-intergration/integration-contract.md`
- `vithey_app/lib/core/constants/api_endpoints.dart`
- `docs/Prompt Backend/services/*/API_ENDPOINTS.md`

---

## 1. Quick start

### Base URLs

| Platform | `API_BASE_URL` | WebSocket |
|----------|----------------|-----------|
| Desktop / iOS simulator | `http://localhost:8080/api/v1` | `ws://localhost:8080/ws` |
| Android emulator | `http://10.0.2.2:8080/api/v1` | `ws://10.0.2.2:8080/ws` |
| Physical device (LAN) | `http://<PC-LAN-IP>:8080/api/v1` | `ws://<PC-LAN-IP>:8080/ws` |

### Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
Content-Type: application/json
X-Request-ID: <optional-uuid>
```

- Access token TTL: **15 minutes**
- Refresh token TTL: **7 days**
- On `401`: call `POST /auth/refresh` once, retry; if refresh fails → logout

### Public endpoints (no JWT)

`POST /auth/register` · `POST /auth/login` · `POST /auth/refresh` · `POST /auth/forgot-password` · `POST /auth/reset-password` · `POST /auth/verify-email`

### Response envelope

**Success (object):**
```json
{ "data": { }, "meta": null, "error": null }
```

**Success (list + pagination):**
```json
{
  "data": [ ],
  "meta": { "page": 1, "limit": 20, "total": 42, "total_pages": 3 },
  "error": null
}
```

**Error:**
```json
{
  "data": null,
  "meta": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [{ "field": "email", "message": "must be a valid email" }]
  }
}
```

Empty success often returns **`204 No Content`** (logout, delete, unfollow).

### Pagination query

| Param | Default | Notes |
|-------|---------|-------|
| `page` | `1` | 1-based |
| `limit` | `20` | typical max `50` |

### Flutter `.env` (demo)

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1
USE_MOCK_AUTH=false
USE_MOCK_API=false
USE_MOCK_AI=false
```

Start backend demo stack from `backend/`:
```powershell
.\scripts\docker-up-demo.ps1
```

---

## 2. Screen → endpoints map

| Screen / feature | Primary endpoints (relative) |
|------------------|------------------------------|
| Auth | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout` |
| Splash / session | `GET /auth/me` (+ refresh on 401) |
| Student verify | `POST /students/verify` |
| Home feed | `GET /posts`, reactions, follow |
| Create post | `POST /files/upload` → `POST /posts` |
| Post detail | `GET /posts/{id}`, comments, reactions |
| Search | `GET /users/search`, `GET /posts?search=` |
| Profile | `GET /users/{id}`, `GET /users/{id}/posts`, `PATCH /users/me` |
| Settings | `GET/PATCH /users/me/settings`, `PATCH /auth/me/password` |
| Apply CV | `POST /files/upload` (CV) → `POST /job-applications` |
| Own CV | `GET/PUT /users/me/cv`, `GET /files/{id}/download` |
| Applicant CV | `GET /job-applications?job_post_id=`, `GET /job-applications/{id}/cv-preview` |
| Finance | `GET /payments`, `GET /payments/alerts`, `GET /fees` (**STUDENT**) |
| Peer chat | `GET /conversations`, messages REST + STOMP `/ws` |
| AI chatbot | `POST /ai/chat`, `POST /ai/chat/stream`, sessions |
| Auto-Create CV | `POST /ai/cv/generate` |
| CV suggest | `POST /ai/cv/suggest` |
| Notifications | `GET /notifications`, read, devices (FCM) |
| Map | `GET /places/nearby`, search, autocomplete, favorites |

---

## 3. Auth

**Service:** auth-service

### `POST /auth/register` → `201`

```json
{
  "email": "student@aub.edu.kh",
  "phone": "+855123456789",
  "password": "SecurePass123!",
  "full_name": "Jane Doe",
  "role": "USER"
}
```

`role`: `USER` | `COMPANY` only. `STUDENT` comes from verification.

### `POST /auth/login` → `200`

```json
{ "email_or_phone": "student@aub.edu.kh", "password": "SecurePass123!" }
```

### Auth success `data`

```json
{
  "user": {
    "user_id": "uuid",
    "email": "...",
    "phone": "...",
    "full_name": "...",
    "role": "USER",
    "is_student_verified": false,
    "is_email_verified": false
  },
  "tokens": {
    "access_token": "...",
    "refresh_token": "...",
    "expires_in": 900
  }
}
```

### Other auth

| Method | Path | Body | Notes |
|--------|------|------|-------|
| `POST` | `/auth/refresh` | `{ "refresh_token" }` | returns new tokens |
| `POST` | `/auth/logout` | `{ "refresh_token" }` | `204`, JWT required |
| `POST` | `/auth/forgot-password` | `{ "email" }` | generic message |
| `POST` | `/auth/reset-password` | `{ "token", "new_password" }` | |
| `POST` | `/auth/verify-email` | `{ "token" }` | |
| `GET` | `/auth/me` | — | auth identity |
| `PATCH` | `/auth/me/password` | `{ "current_password", "new_password" }` | JWT |
| `POST` | `/students/verify` | `{ "student_id", "university_email" }` | JWT → role `STUDENT`; extra fields (e.g. `document_file_id`) are ignored |

---

## 4. Users / Profile

**Service:** user-profile-service (except CV / follow / posts / report — see gateway notes)

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| `GET` | `/users/me` | yes | full private profile |
| `GET` | `/users/{user_id}` | yes | public profile |
| `PATCH` | `/users/me` | yes | partial update |
| `PATCH` | `/users/me/avatar` | yes | `{ "avatar_file_id" }` after upload |
| `GET` | `/users/me/settings` | yes | language, theme, notifications, privacy |
| `PATCH` | `/users/me/settings` | yes | same fields |
| `GET` | `/users/search` | yes | `?search=&page=&limit=` (min search length **2**) |

**PATCH `/users/me` fields (all optional):**  
`full_name`, `bio`, `telegram_link`, `facebook_link`, `university`, `major`, `graduation_year`, `location`, `date_of_birth`, `workplace`, `portfolio_url`, `phone`, `email`, `skills[]`, `education[]`, `field_visibility`

**Settings:** `language` (`en`|`km`), `theme` (`light`|`dark`|`system`), `notifications`, `privacy`, `fcm_token`

---

## 5. Files

**Service:** file-service

### `POST /files/upload` → `201` (multipart)

| Form field | Value |
|------------|-------|
| `file` | binary |
| `type` | `AVATAR` \| `CV` \| `POSTER` \| `VIDEO` \| `CHAT_ATTACHMENT` |

```json
{
  "file_id": "uuid",
  "file_name": "cv.pdf",
  "file_type": "CV",
  "mime_type": "application/pdf",
  "size_bytes": 12345,
  "url": "https://...",
  "created_at": "2026-09-12T10:00:00Z"
}
```

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/files/{file_id}` | metadata + short-lived URL |
| `GET` | `/files/{file_id}/download` | binary; CV owner-restricted |
| `DELETE` | `/files/{file_id}` | `204`, owner only |

---

## 6. Posts / Content

**Service:** content-service

### Feed & CRUD

| Method | Path | Query / body |
|--------|------|--------------|
| `GET` | `/posts` | `page`, `limit`; optional `search`, `type` |
| `POST` | `/posts` | create (see below) → `201` |
| `GET` | `/posts/{post_id}` | — |
| `PATCH` | `/posts/{post_id}` | **not implemented** — `PostController` has no PATCH mapping; Flutter `updatePost` gets `404` |
| `DELETE` | `/posts/{post_id}` | owner → `204` |
| `GET` | `/users/{user_id}/posts` | `type?`, `page`, `limit` |

**Create post**

Poster / video:
```json
{ "type": "POSTER", "content": "...", "media_file_id": "uuid" }
```

Job:
```json
{
  "type": "JOB",
  "content": "...",
  "job_meta": {
    "title": "Intern",
    "description": "...",
    "requirement": "...",
    "deadline": "2026-12-31"
  }
}
```

`type`: `VIDEO` | `POSTER` | `JOB`

**Post `data` fields:** `post_id`, `author`, `type`, `content`, `media_url`, `job_meta`, `reaction_count`, `comment_count`, `user_reacted`, `created_at`

### Comments

| Method | Path | Body |
|--------|------|------|
| `GET` | `/posts/{id}/comments` | `page`, `limit` |
| `POST` | `/posts/{id}/comments` | `{ "text", "mention_user_ids?" }` → `201` |
| `PATCH` | `/posts/{id}/comments/{comment_id}` | `{ "text" }` |
| `DELETE` | `/posts/{id}/comments/{comment_id}` | → `204` |

### Reactions & follow

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/posts/{id}/reactions` | toggle like → `{ reaction_count, user_reacted }` |
| `GET` | `/posts/{id}/reactions` | same shape |
| `POST` | `/users/{id}/follow` | `201`, idempotent |
| `DELETE` | `/users/{id}/follow` | `204` |
| `GET` | `/users/{id}/followers` | paginated |
| `GET` | `/users/{id}/following` | paginated |

---

## 7. Career / Jobs / CV

**Service:** career-service  
Job **listings** are content posts: `GET /posts?type=JOB`.

| Method | Path | Body / query | Notes |
|--------|------|--------------|-------|
| `POST` | `/job-applications` | `{ "job_post_id", "cv_file_id", "application_note?" }` | `201`; optional `Idempotency-Key`; backend also accepts `cover_note` (alias) |
| `GET` | `/job-applications` | `page`, `limit`, optional `job_post_id` | applicants when `job_post_id` set |
| `GET` | `/job-applications/{id}` | — | detail |
| `GET` | `/job-applications/{id}/cv-preview` | — | `cv_file_id`, `download_url` |
| `PATCH` | `/job-applications/{id}/status` | `{ "status", "reviewer_note?" }` | **poster only** |
| `GET` | `/users/me/cv` | — | default CV |
| `PUT` | `/users/me/cv` | `{ "cv_file_id" }` | set default CV |

**Status enum:** `PENDING` | `REVIEWED` | `ACCEPTED` | `REJECTED`

**Apply flow**
1. `POST /files/upload` with `type=CV`
2. Optional `PUT /users/me/cv`
3. `POST /job-applications`

---

## 8. Finance (STUDENT only)

**Service:** finance-service — returns **`403`** if not verified student.

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/payments` | list + meta |
| `GET` | `/payments/{payment_id}` | own only |
| `GET` | `/payments/alerts` | `{ alerts: [...] }` |
| `GET` | `/fees` | fee catalog |
| `GET` | `/fees/categories` | categories |

**Payment fields:** `payment_id`, `fee_name`, `amount`, `currency`, `status`, `due_date`, `paid_at`

**Verify first:** `POST /students/verify` → then finance APIs work.

---

## 9. Peer chat

**Service:** chat-service

### REST

| Method | Path | Body / query |
|--------|------|--------------|
| `GET` | `/conversations` | `page`, `limit` |
| `POST` | `/message-requests` | `{ "to_user_id", "initial_message" }` — create pending request |
| `POST` | `/conversations/start` | `{ "to_user_id", "initial_message" }` — server alias, not used by Flutter |
| `POST` | `/conversations/{id}/accept` | — |
| `POST` | `/conversations/{id}/decline` | — |
| `POST` | `/conversations/{id}/block` | — |
| `GET` | `/conversations/{id}/presence` | `{ partner_id, status }` |
| `GET` | `/message-requests` | pending inbox |
| `GET` | `/conversations/{id}/messages` | `page`, `limit`, `before?` |
| `POST` | `/conversations/{id}/messages` | see below |
| `PATCH` | `/messages/{id}/read` | single |
| `POST` | `/conversations/{id}/messages/read` | `{ "message_ids": ["uuid"] }` batch |
| `POST` | `/users/{user_id}/report` | `{ "reason" }` |

**Send message**
```json
{
  "text": "Hello",
  "client_message_id": "client-uuid",
  "message_type": "TEXT",
  "reply_to_message_id": null,
  "file_id": null
}
```

`message_type`: `TEXT` | `IMAGE` | `FILE` — upload `CHAT_ATTACHMENT` first for media.

**Message fields:** `message_id`, `conversation_id`, `sender_id`, `text`, `message_type`, `file_id`, `file_url`, `reply_to_message_id`, `status`, `created_at`

### WebSocket (STOMP)

| Item | Value |
|------|-------|
| URL | `ws://{host}:8080/ws` |
| Protocol | STOMP 1.2 |
| Auth | `Authorization: Bearer {jwt}` on CONNECT |
| Subscribe inbox | `/user/queue/messages` |
| Subscribe presence | `/user/queue/presence` |
| Send | `/app/chat.send` |
| Typing | `/app/chat.typing` |
| Heartbeat | `/app/chat.heartbeat` |
| Read (optional) | `/app/chat.read` |

Filter inbound frames by `conversation_id` in the JSON payload.  
Frame `type` values: `MESSAGE`, `READ_RECEIPT`, `TYPING`, `PRESENCE`

---

## 10. AI / Chatbot

**Service:** `ai_core` (Python, `:8100`, via gateway `/api/v1/ai/**`). The Java `ai-service` has been retired.

Demo mode:
- Chat = **topic stub** (no GDCE / RAG)
- CV generate = **`ai_core` → LLM** (Flutter never calls `ai_core` directly)

### Chat

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/ai/chat` | sync reply |
| `POST` | `/ai/chat/stream` | **SSE** `text/event-stream` |
| `POST` | `/ai/messages/{message_id}/regenerate` | replace assistant reply |
| `DELETE` | `/ai/chat/requests/{request_id}` | Stop → `204` |
| `GET` | `/ai/sessions` | history drawer |
| `GET` | `/ai/sessions/{id}/messages` | ASC messages |
| `DELETE` | `/ai/sessions/{id}` | trash → `204` |

**Chat request**
```json
{
  "message": "How do I write a good CV?",
  "topic": "CV",
  "session_id": null,
  "client_message_id": "client-1735123456789"
}
```

| Field | Rule |
|-------|------|
| `message` | required, max 4000 |
| `topic` | optional: `CV` \| `JOB` \| `INTERVIEW` \| `STUDENT` \| `FINANCE` |
| `session_id` | `null` for new chat |
| `client_message_id` | optional idempotency |

**Chat response `data`**
```json
{
  "session_id": "uuid",
  "reply": "Markdown assistant text…",
  "topic": "CV",
  "message_id": "uuid",
  "request_id": "uuid"
}
```

`reply` is **Markdown** (use `flutter_markdown`).

### SSE stream (`POST /ai/chat/stream`)

Same body as `/ai/chat`. Event order: `meta` → `token`* → `done` (or `error`).

```
event: meta
data: {"request_id":"uuid","session_id":"uuid","user_message_id":"uuid","topic":"CV"}

event: token
data: Markdown fragment…

event: done
data: {"request_id":"uuid","session_id":"uuid","message_id":"uuid","cancelled":false}

event: error
data: {"code":"...","message":"..."}
```

Concatenate `token` payloads left-to-right. Cancel mid-stream with `DELETE /ai/chat/requests/{request_id}` → `done` may include `"cancelled": true`.

### Auto-Create CV (P0)

### `POST /ai/cv/generate`

```json
{
  "target_role": "Software Engineer Intern",
  "language": "en",
  "template_id": null
}
```

All fields optional. Body may be omitted (`{}` or empty). Server aggregates profile + recent posts.

**Response `data` (`AiCvDraft`):**
```json
{
  "full_name": "Jane Doe",
  "summary": "...",
  "skills": ["Dart", "Flutter"],
  "education": ["BSc CS — AUB"],
  "experience": ["Intern — Acme"],
  "projects": ["Vithey App"],
  "contact": "jane@aub.edu.kh",
  "template_id": null,
  "incomplete_profile": false,
  "incomplete_message": null,
  "quality_score": 85,
  "quality_grade": "B"
}
```

### CV section suggest

### `POST /ai/cv/suggest`

```json
{
  "section": "summary",
  "original_text": "I am a student...",
  "cv_file_id": null
}
```

```json
{
  "suggested_text": "Improved summary…",
  "interaction_id": "uuid"
}
```

### Not implemented (do not call yet)

`PATCH /ai/sessions/{id}` · `POST /ai/messages/{id}/feedback` · `POST /ai/jobs/{jobPostId}/match` · `GET /ai/skills/score` · `GET /ai/feed/recommendations`

Flutter gates these behind mock/feature flags and returns neutral values in live mode.

---

## 11. Notifications

**Service:** notification-service

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/notifications` | `?page&limit&is_read=` |
| `GET` | `/notifications/unread-count` | badge |
| `PATCH` | `/notifications/{id}/read` | mark one |
| `PATCH` | `/notifications/read-all` | mark all |
| `DELETE` | `/notifications/{id}` | `204` |
| `POST` | `/notifications/devices` | `{ "fcm_token", "platform" }` — `ANDROID` \| `IOS` |
| `DELETE` | `/notifications/devices/{token}` | unregister |

**Item fields:** `id` (alias `notification_id`), `type`, `event`, `title`, `body`, `is_read`, `created_at`, `read_at`, `reference_id`, `reference_type`, `actor`, `destination`, `dedupe_key`

**Types (backend `NotificationType`):** `LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `JOB`, `PAYMENT`, `SYSTEM`, `STUDENT_VERIFICATION`

> Flutter's `NotificationType` enum also defines `postShare` and `aiAssistantResponse`, but the backend never emits them.

---

## 12. Map / Places

**Service:** map-service — needs server `GOOGLE_PLACES_API_KEY` (app never sees the key).

| Method | Path | Query / body |
|--------|------|--------------|
| `GET` | `/places/nearby` | `lat`, `lng`, `radius_m?`, `category?`, `open_now?`, `min_rating?`, `price_level?`, `page_token?`, `limit?` |
| `GET` | `/places/search` | `query` (≥2) + geo filters |
| `GET` | `/places/autocomplete` | `input`, `lat?`, `lng?` |
| `GET` | `/places/{google_place_id}` | detail |
| `GET` | `/places/favorites` | list |
| `POST` | `/places/favorites` | `{ google_place_id, name, address?, latitude, longitude, category?, photo_url? }` |
| `DELETE` | `/places/favorites/{google_place_id}` | — |
| `GET` | `/places/history` | recent (max 20) |
| `DELETE` | `/places/history` | clear |

**Place card:** `google_place_id`, `name`, `address`, `category`, `latitude`, `longitude`, `rating`, `user_rating_count`, `price_level`, `open_now`, `distance_m`, `photo_url`, `is_favorite`

---

## 13. Search (cross-service)

No single `/search` aggregator — Flutter fans out:

| Tab | Endpoint |
|-----|----------|
| People | `GET /users/search?search={q}&page=&limit=` |
| Posts / Jobs / Videos | `GET /posts?search={q}&type=&page=&limit=` |

- Debounce **350ms**; min query length **2**
- Recent search history = **device-local only** (not an API)

---

## 14. Cross-service flows

### Create post with media
1. `POST /files/upload` (`POSTER` or `VIDEO`) → `file_id`
2. `POST /posts` with `media_file_id`

### Apply to job
1. `POST /files/upload` (`CV`) → `file_id`
2. Optional `PUT /users/me/cv`
3. `POST /job-applications`

### Student → Finance
1. `POST /students/verify`
2. Then `GET /payments` / `GET /fees` (else `403`)

### Auto-Create CV
1. Ensure profile has name / education / skills (better draft quality)
2. `POST /ai/cv/generate`
3. Show draft UI; user edits; later upload as CV file if saving

### Peer chat realtime
1. REST load conversations + history
2. Connect STOMP at `/ws` with Bearer JWT
3. Subscribe `/user/queue/messages`; send via `/app/chat.send`

---

## 15. Gateway routing (order matters)

| Path | Service |
|------|---------|
| `/api/v1/auth/**`, `/api/v1/students/verify` | auth-service |
| `/api/v1/users/me/cv`, `/api/v1/users/me/cv/**` | career-service |
| `/api/v1/users/*/follow`, `followers`, `following` | content-service |
| `/api/v1/users/*/posts` | content-service |
| `/api/v1/users/*/report` | chat-service |
| `/api/v1/users/**` (else) | user-profile-service |
| `/api/v1/files/**` | file-service |
| `/api/v1/posts/**`, comments, reactions | content-service |
| `/api/v1/jobs/**` | career-service (route exists; **no controller** — job listings are `POST /posts?type=JOB`) |
| `/api/v1/job-applications/**` | career-service |
| `/api/v1/fees/**`, `/api/v1/payments/**` | finance-service |
| `/api/v1/conversations/**`, `/messages/**`, `/message-requests/**` | chat-service |
| `/ws/**` | chat-service (STOMP) |
| `/api/v1/notifications/**` | notification-service |
| `/api/v1/ai/**` | ai_core (Python, direct `http://ai-core:8100` — not via Eureka) |
| `/api/v1/places/**` | map-service (optional Compose profile `map`) |

### Known contract gaps (current code)

| Item | Status |
|------|--------|
| `PATCH /posts/{post_id}` | Flutter calls it; **no backend mapping** → `404` |
| `POST /conversations/request` | Does not exist; use `POST /message-requests` |
| `GET /api/v1/jobs/**` | Gateway route exists but no controller |
| `POST /ai/jobs/{id}/match`, `GET /ai/skills/score`, `GET /ai/feed/recommendations` | Not shipped; Flutter stubs only |
| Google sign-in | Stubbed in Flutter (`ENABLE_GOOGLE_AUTH`); no endpoint |
| `GET /users/me/settings` `fcm_token` field | Device tokens use `POST /notifications/devices` instead |

---

## 16. Flutter integration checklist

- [ ] `API_BASE_URL` set per platform (emulator vs device)
- [ ] `api_endpoints.dart` matches this doc
- [ ] Dio: attach Bearer; refresh once on 401; then logout
- [ ] Parse envelope `{ data, meta, error }` + snake_case models
- [ ] Multipart uploads via `UploadService` with correct `type`
- [ ] Pagination: send `page`/`limit`; read `meta.total_pages`
- [ ] Chat: REST + STOMP (`web_socket_channel`)
- [ ] AI: prefer `/ai/chat/stream` for UX; wire Stop → cancel request
- [ ] CV: call `/ai/cv/generate` (not `ai_core` directly)
- [ ] Finance: gate UI on `is_student_verified`
- [ ] FCM: `POST /notifications/devices` after login
- [ ] Toggle `USE_MOCK_*=false` only when gateway is healthy

### Health checks (local demo)

| Service | URL |
|---------|-----|
| Gateway | http://localhost:8080/actuator/health |
| ai_core | http://localhost:8100/health |
| Eureka | http://localhost:8761 |

### Smoke: CV generate

```http
POST http://localhost:8080/api/v1/ai/cv/generate
Authorization: Bearer <access_token>
Content-Type: application/json

{ "target_role": "Software Engineer Intern", "language": "en" }
```

---

## 17. Common error codes (typical)

| HTTP | Meaning | Frontend action |
|------|---------|-----------------|
| `400` | validation | show field errors from `error.details` |
| `401` | unauthorized / expired | refresh once, else login |
| `403` | forbidden (e.g. not STUDENT) | show verify / role message |
| `404` | not found | remove from UI / toast |
| `409` | conflict (duplicate apply, etc.) | show message |
| `429` | rate limited | backoff / retry later |
| `5xx` | server | generic retry |

---

## 18. Roles

| Role | How obtained | Extra access |
|------|--------------|--------------|
| `USER` | register | default app |
| `COMPANY` | register as company | post JOB, review applicants |
| `STUDENT` | `POST /students/verify` | finance (`/payments`, `/fees`) |
| `ADMIN` | backend only | admin (not in Flutter scope) |

JWT claims: `sub` (userId), `email`, `roles[]`.
