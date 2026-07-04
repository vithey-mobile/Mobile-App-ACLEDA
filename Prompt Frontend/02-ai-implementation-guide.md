# AI Implementation Guide — Full Stack

Use this document to build Vithey App end-to-end with Cursor or another AI coding agent.  
**Read `api-intergration/integration-contract.md` first** — it is the binding API contract.

## Current repo status

| Area | Status |
|------|--------|
| Documentation & prompts | Complete frontend feature-flow prompts, 10 backend services, DevOps |
| Flutter app (`vithey_app/`) | Not started — prompts in `Screen prompt/` |
| Backend (`vithey-backend/`) | Not started — prompts ready |
| Integration contract | `api-intergration/integration-contract.md` |

## Master prompt (copy this to start a new AI session)

```text
You are building Vithey App for the ACLEDA AUB App Competition.

Read these files in order before writing code:
1. Prompt Frontend/api-intergration/integration-contract.md
2. Prompt Frontend/00-project-summary.md
3. Prompt Frontend/01-navigation-and-flow.md
4. The KICKOFF_PROMPT.md for the layer you are building (Frontend / Backend / Devops)
5. That layer's COMMON_CONTEXT.md
6. The specific screen or service prompt for this task

Rules:
- Match API paths and response envelopes exactly as in integration-contract.md
- Flutter: GetX + Dio, folder vithey_app/, package name aub_connect_app in pubspec.yaml
- Backend: Java 21, Spring Boot 3+, one runnable service per folder under vithey-backend/services/
- Build complete runnable code, not TODO stubs
- One module or one microservice per session; verify compile/run before moving on

Current task: [DESCRIBE — e.g. "Build auth-service" or "Build Flutter auth module"]
```

## Recommended build order

### Phase 0 — DevOps foundation

1. `Prompt Devops/v1/00-foundation-prompt.md`
2. `Prompt Devops/v1/01-local-docker-compose-prompt.md`
3. `Prompt Devops/v1/02-dockerfiles-prompt.md`

**Gate:** `docker compose up` brings up Postgres, Redis, RabbitMQ, MinIO, Eureka.

### Phase 1 — Backend (one service per AI session)

| Order | Prompt folder | Port |
|-------|---------------|------|
| 1 | `Prompt Backend/services/infrastructure/` | 8761, 8888 |
| 2 | `Prompt Backend/services/api-gateway/` | 8080 |
| 3 | `Prompt Backend/services/auth-service/` | 8081 |
| 4 | `Prompt Backend/services/user-profile-service/` | 8082 |
| 5 | `Prompt Backend/services/file-service/` | 8083 |
| 6 | `Prompt Backend/services/content-service/` | 8084 |
| 7 | `Prompt Backend/services/career-service/` | 8085 |
| 8 | `Prompt Backend/services/finance-service/` | 8086 |
| 9 | `Prompt Backend/services/chat-service/` | 8087 |
| 10 | `Prompt Backend/services/notification-service/` | 8088 |
| 11 | `Prompt Backend/services/ai-service/` | 8089 |

**Gate per service:** `/actuator/health` OK + Swagger shows endpoints + gateway route works.

### Phase 2 — Flutter (one screen per AI session)

1. `Screen prompt/00-foundation-prompt.md` — skeleton + core widgets
2. Follow feature flows in `Screen prompt/README.md`
3. After each screen: register route, test navigation per `01-navigation-and-flow.md`

**Gate per screen:** navigates correctly, uses repositories (mock or real), light/dark theme.

### Phase 3 — Wire real API

Run:

```text
TASK: Prompt Frontend/api-intergration/00-api-intergration-prompt.md
```

Then verify:

1. Set `API_BASE_URL` in `vithey_app/.env`
2. Disable `USE_MOCK_AUTH` and `USE_MOCK_API`
3. Mark **API integrated** in each screen file's Status checklist when live calls work

---

## Per-screen AI prompts (quick reference)

Each screen/flow prompt lives under `Screen prompt/` and may be grouped by feature folders.

### Template

```text
Build Vithey App Flutter screen/flow per:
- Prompt Frontend/Screen prompt/<feature>/<prompt-file>.md (full spec)
- Prompt Frontend/api-intergration/integration-contract.md (API paths)

Use existing core/widgets and data layer from foundation.
Implement: screen, controller, binding, module widgets, repository methods.
Register route in app_pages.dart.
Wire API calls to gateway base URL; use mock only if USE_MOCK_AUTH=true.
Deliver complete runnable Dart code.
```

### Screen index

| # | Screen | Prompt file | Backend needed |
|---|--------|-------------|----------------|
| 01 | Splash | `Screen prompt/auth/01-splash-prompt.md` | — |
| 02 | Onboarding | `Screen prompt/auth/02-onboarding-prompt.md` | — |
| 03 | Auth/Register/Startup | `Screen prompt/auth/03-auth-prompt.md` (then remaining `auth/` prompts) | auth-service |
| 04 | Home Media | `Screen prompt/media/01-home-prompt.md` | content-service |
| 05 | Create Poster/Video/Job | `Screen prompt/media/03.create_poster.md` | content, file |
| 06 | Post Detail | `Screen prompt/media/05.post_detail.md` | content |
| 07 | Apply CV | `Screen prompt/upload_cv/01.upload_cv.md` | career, file |
| 08 | Preview Own CV | `Screen prompt/profile/preview_own_cv.md` | career, file |
| 09 | Profile/Applicants | `Screen prompt/profile/README.md` | user-profile, content, career |
| 10 | Finance | `Screen prompt/finance/03.finance_home.md` | finance |
| 11 | Student Verification | `Screen prompt/finance/01.verify_from.md` then `02.pending_verify.md` | auth |
| 12 | Chat | `Screen prompt/chat/01.list_chat.md` | chat |
| 13 | Chat Detail/Profile | `Screen prompt/chat/02.chat_message.md` then `03.chat_profile.md` | chat |
| 14 | AI Chatbot | `Screen prompt/chatbot/README.md` | ai |
| 15 | Notification | `Screen prompt/notification/01-notification-prompt.md` | notification |
| 16 | Settings | `Screen prompt/setting/README.md` | user-profile, auth |
| 17 | Applicant CV Preview | `Screen prompt/profile/poster_job/preview_cv.md` | career, file |

---

## Per-service AI prompt (backend)

```text
Build the Vithey <service-name> microservice per:
- Prompt Backend/services/<service>/KICKOFF_PROMPT.md
- Prompt Backend/services/<service>/COMMON_CONTEXT.md
- Prompt Backend/services/<service>/SERVICE_PROMPT.md
- Prompt Backend/COMMON_CONTEXT.md
- Prompt Frontend/api-intergration/integration-contract.md (gateway routes & events)

Output under vithey-backend/services/<service>/.
Java 21, Spring Boot 3+, Flyway, OpenAPI, tests.
Register with Eureka. Expose port per integration contract.
```

---

## Integration test script (manual)

After backend + one Flutter screen (Auth) exist:

```bash
# 1. Register
curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@aub.edu.kh","phone":"+855120000001","password":"SecurePass1!","full_name":"Test User","role":"USER"}'

# 2. Login — save access_token
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"test@aub.edu.kh","password":"SecurePass1!"}'

# 3. Profile (replace TOKEN)
curl -s http://localhost:8080/api/v1/users/me -H "Authorization: Bearer TOKEN"
```

Flutter: login with same credentials → should land on Home when content-service returns posts (empty list OK).

---

## Keeping docs in sync

When you change an endpoint or screen flow:

1. Update `api-intergration/integration-contract.md`
2. Update `api-intergration/api-overview.md`
3. Update the screen file in `Screen prompt/`
4. Update `api_endpoints.dart` in Flutter (when it exists)
