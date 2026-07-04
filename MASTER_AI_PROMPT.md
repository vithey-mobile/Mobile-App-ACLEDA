# Vithey App — Master AI Prompt

> **Human index:** `Project Overview.txt`  
> Copy everything below the line into a new Cursor chat.

---

You are building **Vithey App** for the ACLEDA Bank AUB App Competition.

## Repository (only these folders exist)

```text
MASTER_AI_PROMPT.md          ← you are here
Project Overview.txt         ← full repo map
Prompt Frontend/             ← Flutter + API contract + Screen prompt/
Prompt Backend/              ← Spring Boot microservices
Prompt Devops/               ← Docker + CI/CD
```

**Do not create** `docs/`, `archive/`, or duplicate prompt folders outside the paths above.

## Read first (in order)

1. `Prompt Frontend/api-intergration/integration-contract.md` — binding API contract
2. `Prompt Backend/SERVICE_BLUEPRINT.md` — monorepo + Spring Cloud layout
3. `Prompt Frontend/02-ai-implementation-guide.md` — phases and templates
4. `Prompt Frontend/00-project-summary.md` — product scope
5. `Prompt Frontend/01-navigation-and-flow.md` — routes and screen flow
6. Layer kickoff: `KICKOFF_PROMPT.md` in Frontend / Backend / Devops
7. Layer `COMMON_CONTEXT.md`
8. The specific task prompt file (screen, service, or devops v1)

## Outputs (create when building)

| Layer | Output folder | Stack |
|-------|---------------|-------|
| Mobile | `vithey_app/` | Flutter, GetX, Dio — `pubspec.yaml` name: `aub_connect_app` |
| Backend | `vithey-backend/` | Java 21, Spring Boot 3+, Maven |
| Infra | `vithey-backend/docker-compose.yml` | Postgres, Redis, RabbitMQ, MinIO, Eureka |

## Global rules

- **One task per session:** one screen OR one microservice OR one devops prompt
- **Complete runnable code** — no `// TODO` stubs
- **API contract:** paths and JSON envelopes must match `integration-contract.md`
- **Gateway route order:** `/users/me/cv` and `/users/*/follow` before `/users/**`
- **Flutter paths** in `api_endpoints.dart` are relative to `API_BASE_URL` (no `/api/v1` prefix)
- **Verify before next task:** compile, run, health/Swagger or screen navigation

## Build order

### Phase 0 — DevOps
`Prompt Devops/v1/00-foundation-prompt.md` → `01` → `02` → `03` → `04` → `05` → `06` → `07`

For independent service DevOps: `Prompt Devops/services/<service>/DEVOPS_PROMPT.md`

### Phase 1 — Backend (one service per session)
| # | Service | Prompt folder | Port |
|---|---------|---------------|------|
| 0 | Infrastructure | `services/infrastructure/` | 8761, 8888 |
| 1 | API Gateway | `services/api-gateway/` | 8080 |
| 2 | Auth | `services/auth-service/` | 8081 |
| 3 | User Profile | `services/user-profile-service/` | 8082 |
| 4 | File | `services/file-service/` | 8083 |
| 5 | Content | `services/content-service/` | 8084 |
| 6 | Career | `services/career-service/` | 8085 |
| 7 | Finance | `services/finance-service/` | 8086 |
| 8 | Chat | `services/chat-service/` | 8087 |
| 9 | Notification | `services/notification-service/` | 8088 |
| 10 | AI | `services/ai-service/` | 8089 |

Each service: read `KICKOFF_PROMPT.md`, `COMMON_CONTEXT.md`, `API_ENDPOINTS.md`, `FOLDER_STRUCTURE.md`, `SERVICE_LOGIC.md`, `DB_SCHEMA.md`, then `SERVICE_PROMPT.md` in that folder.

### Phase 2 — Frontend (one screen per session)
`Prompt Frontend/Screen prompt/00-foundation-prompt.md` → follow `Prompt Frontend/Screen prompt/README.md`

Each screen file contains **Product spec** + implementation instructions.  
Also read `Prompt Frontend/COMMON_CONTEXT.md` and `Folder_Stucture_flutter.md`.

### Phase 3 — Integration
Run `Prompt Frontend/api-intergration/00-api-intergration-prompt.md`, then:
- Set `vithey_app/.env` → `API_BASE_URL=http://localhost:8080/api/v1`
- Disable `USE_MOCK_AUTH` and `USE_MOCK_API`
- Test: register → login → home → posts

## Screen → backend map (quick)

| Screens | Backend services |
|---------|-------------------|
| 01–02 Splash, Onboarding | — (local only) |
| 03 Auth, 11 Student Verification | auth-service |
| 04–06 Home, Create Post, Post Detail | content-service, file-service |
| 07–08, 17 Apply/Preview/Applicant CV | career-service, file-service |
| 09 Profile, 16 Settings | user-profile-service, auth-service |
| 10 Finance | finance-service (STUDENT role) |
| 12–13 Chat | chat-service |
| 14 AI Chatbot | ai-service |
| 15 Notification | notification-service |

## Architecture

See `Prompt Backend/backend plan.png` and `Prompt Backend/COMMON_CONTEXT.md`.

## Current task

Replace with the exact prompt file path:

```
TASK: Prompt Devops/v1/00-foundation-prompt.md
```

Examples:
- `TASK: Prompt Devops/services/auth-service/DEVOPS_PROMPT.md`
- `TASK: Prompt Backend/services/auth-service/KICKOFF_PROMPT.md`
- `TASK: Prompt Frontend/Screen prompt/auth/03-auth-prompt.md`
- `TASK: Prompt Frontend/api-intergration/00-api-intergration-prompt.md`
