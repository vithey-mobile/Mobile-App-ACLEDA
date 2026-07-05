# Prompt Backend — Vithey App (Spring Boot)

All backend microservice AI prompts live here.

## Start

1. Read `KICKOFF_PROMPT.md`
2. Read `COMMON_CONTEXT.md` and `SERVICE_BLUEPRINT.md` (monorepo + Spring Cloud layout)
3. Read `Prompt Frontend/api-intergration/integration-contract.md` (gateway routes + events)
4. Build one service at a time per table below

## Services (build order)

| # | Folder | Port | Eureka name |
|---|--------|------|-------------|
| 0 | `infrastructure/` | 8761, 8888 | — |
| 1 | `services/api-gateway/` | 8080 | api-gateway |
| 2 | `services/auth-service/` | 8081 | auth-service |
| 3 | `services/user-profile-service/` | 8082 | user-profile-service |
| 4 | `services/file-service/` | 8083 | file-service |
| 5 | `services/content-service/` | 8084 | content-service |
| 6 | `services/career-service/` | 8085 | career-service |
| 7 | `services/finance-service/` | 8086 | finance-service |
| 8 | `services/chat-service/` | 8087 | chat-service |
| 9 | `services/notification-service/` | 8088 | notification-service |
| 10 | `services/ai-service/` | 8089 | ai-service (external Python — integration docs only) |

Each service folder contains:
- `KICKOFF_PROMPT.md` — service overview
- `COMMON_CONTEXT.md` — service-specific rules
- `API_ENDPOINTS.md` — endpoint contract for frontend/backend integration
- `FOLDER_STRUCTURE.md` — exact output tree and dependencies
- `SERVICE_LOGIC.md` — service boundaries, flows, events, errors
- `DB_SCHEMA.md` — database tables, indexes, and migration notes
- `SERVICE_PROMPT.md` — combined build prompt and completion criteria

**ai-service only:** also read `INTEGRATION.md` (Python ↔ Java gateway/Eureka).

## Key files

- `SERVICE_BLUEPRINT.md` — monorepo parent POM, Spring Cloud 2023.0.3, standard package layout
- `backend plan.png` — architecture diagram
- `COMMON_CONTEXT.md` — envelope, RBAC, events, ports

## Output

Build generates `vithey-backend/` with `services/<name>/` runnable Spring Boot apps.

## Master prompt

Use `MASTER_AI_PROMPT.md` at repo root — set `TASK:` to a service `KICKOFF_PROMPT.md`, then read all files in that service folder.
