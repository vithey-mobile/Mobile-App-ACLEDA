# Vithey App — Backend Kickoff Prompt

You are building the **Vithey App** Spring Boot microservice backend for the ACLEDA Bank AUB App Competition. Use the provided context files and work **one service at a time**.

## Read First
1. `SERVICE_BLUEPRINT.md` — monorepo layout, parent POM, Spring Cloud 2023.0.3, package tree
2. `Prompt Frontend/api-intergration/integration-contract.md` — gateway routes, screen↔API map
3. `COMMON_CONTEXT.md` (root — shared standards for all services)
4. The target service folder's `KICKOFF_PROMPT.md`
5. The target service folder's `COMMON_CONTEXT.md`
6. The target service folder's `API_ENDPOINTS.md`
7. The target service folder's `FOLDER_STRUCTURE.md`
8. The target service folder's `SERVICE_LOGIC.md`
9. The target service folder's `DB_SCHEMA.md`
10. The target service folder's `SERVICE_PROMPT.md` — final combined build prompt/checklist

## Architecture Overview
Microservice platform with:
- **API Gateway** (Spring Cloud Gateway) — single entry, JWT, rate limit, CORS
- **Service Discovery** (Eureka) + **Config Server** (Spring Cloud Config)
- **9 domain services** — each owns its API + PostgreSQL database
- **Redis** — cache, session, WebSocket support (Chat)
- **RabbitMQ** — async events between services
- **MinIO** — object storage (File Service)
- **External:** FCM (push), OpenAI/Gemini (AI)

## Rules
- **Backend API only.** No Flutter/frontend code.
- **Java 21**, **Spring Boot 3.3.5**, **Spring Cloud 2023.0.3**, **Maven** multi-module for domain services.
- **`ai-service` / chatbot:** Python — you build separately; Java repo has integration docs only (`backend/services/ai-service/`).
- Follow folder structure in `SERVICE_BLUEPRINT.md` for every service.
- One **independently runnable** Spring Boot app per service folder.
- **Database per service** — no shared tables across services.
- Service-to-service calls via **REST over HTTP** (WebClient or OpenFeign).
- Async side effects via **RabbitMQ events** where specified.
- JWT validated at Gateway; services trust internal network or re-validate.
- Build **complete runnable code**, not placeholders.
- Every service must expose **OpenAPI/Swagger** via springdoc-openapi.
- Follow API contract in `Prompt Frontend/api-intergration/integration-contract.md` and the target service's `API_ENDPOINTS.md`.

## Recommended Execution Order
| # | Service Folder | Port (default) |
|---|----------------|----------------|
| 0 | `infrastructure/` | Eureka 8761, Config 8888 |
| 1 | `services/api-gateway/` | 8080 |
| 2 | `services/auth-service/` | 8081 |
| 3 | `services/user-profile-service/` | 8082 |
| 4 | `services/file-service/` | 8083 |
| 5 | `services/content-service/` | 8084 |
| 6 | `services/career-service/` | 8085 |
| 7 | `services/finance-service/` | 8086 |
| 8 | `services/chat-service/` | 8087 |
| 9 | `services/notification-service/` | 8088 |
| 10 | `services/ai-service/` | 8089 | External Python — integration docs only |

Build **File Service** before Content/Career (they depend on file URLs).

**AI / chatbot:** Do not build in Java. Wire your Python service using `backend/services/ai-service/INTEGRATION.md`.

## Working Style
- Build one service fully before moving to the next.
- Each service: compile → run → hit `/actuator/health` → test main endpoints via Swagger.
- Add unit + integration tests per service prompt.
- Register with Eureka after infrastructure is up.
- Do not put another service's domain logic into the wrong service.

## Monorepo Layout (target output)
```text
vithey-backend/
├── infrastructure/
│   ├── eureka-server/
│   ├── config-server/
│   ├── config-repo/
│   ├── scripts/
│   └── docker-compose.yml
├── services/
│   ├── api-gateway/
│   ├── auth-service/
│   ├── user-profile-service/
│   ├── content-service/
│   ├── career-service/
│   ├── finance-service/
│   ├── chat-service/
│   ├── notification-service/
│   ├── ai-service/                      # Integration docs only — Python built separately
│   └── file-service/
└── pom.xml
```

## Output Quality
- Layered architecture: controller → service → repository.
- DTOs for all request/response — never expose entities directly.
- Global exception handler with standard error envelope.
- Lombok for boilerplate reduction.
- MapStruct or manual mappers for entity ↔ DTO.
- Structured logging with correlation ID from gateway header `X-Request-ID`.
