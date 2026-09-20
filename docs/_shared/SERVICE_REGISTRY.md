# Service Registry

**Single source of truth** for build order, ports, and Eureka names.  
Other prompts must link here instead of copying this table.

## Build order

| # | Folder | Port | Eureka / Compose name | Notes |
| --- | --- | --- | --- | --- |
| 0 | `backend/infrastructure/` | 8761, 8888 | — | Start first when running incremental; creates `vithey-network` |
| 1 | `backend/services/api-gateway/` | 8080 | `api-gateway` | Start **last** among apps; routes `/api/v1/ai/**` → `ai-core:8100` |
| 2 | `backend/services/auth-service/` | 8081 | `auth-service` | |
| 3 | `backend/services/user-profile-service/` | 8082 | `user-profile-service` | |
| 4 | `backend/services/file-service/` | 8083 | `file-service` | Before content/career; needs MinIO + `MINIO_PUBLIC_ENDPOINT` |
| 5 | `backend/services/content-service/` | 8084 | `content-service` | |
| 6 | `backend/services/career-service/` | 8085 | `career-service` | |
| 7 | `backend/services/finance-service/` | 8086 | `finance-service` | |
| 8 | `backend/services/chat-service/` | 8087 | `chat-service` | User-to-user messaging only |
| 9 | `backend/services/notification-service/` | 8088 | `notification-service` | |
| 10 | `ai_core/` | **8100** | `ai-core` | Python FastAPI; Vithey AI chat + CV. **No Java `ai-service`.** |
| 11 | `backend/services/map-service/` | 8090 | `map-service` | Opt-in (`COMPOSE_PROFILES=map` / demo `-Profiles map`) |

Paths relative to repo root. See [REPO_PATHS.md](REPO_PATHS.md).

> Java `backend/services/ai-service/` is **retired**. Do not start `vithey-ai-service`. Gateway does not route to :8089.

## Shared infrastructure ports

| Component | Container port | Host port (Docker Desktop) |
| --- | --- | --- |
| PostgreSQL | 5432 | **15432** |
| Redis | 6379 | **16379** |
| RabbitMQ | 5672 / 15672 | **5672** / **15672** |
| MinIO | 9000 / 9001 | **19000** (API) / **19001** (console) |
| Eureka | 8761 | 8761 |
| Config Server | 8888 | 8888 |

MinIO image: `quay.io/minio/minio:latest` (avoid Docker Hub rate limits).

## Screen → backend map

| Screens | Backend services |
| --- | --- |
| Splash, Select Language, Onboarding | — (local only) |
| Auth (login/register; Google UI via `ENABLE_GOOGLE_AUTH`), Student Verification, change password | auth-service |
| Home, Create Post, Post Detail, Reels (video-only) | content-service, file-service |
| Apply / Preview / Applicant CV | career-service, file-service |
| Profile, Settings | user-profile-service, auth-service |
| Finance | finance-service (STUDENT role) |
| Chat | chat-service |
| AI Chatbot / AI CV | **ai_core** (`/api/v1/ai/**`) |
| Notification | notification-service |
| Map / nearby shops | map-service (`/places/**` — 503 until map profile is up) |

Full screen index: `docs/Prompt Frontend/Screen prompt/README.md`.

## Gateway route prefixes

**Order matters** — specific `/users/...` paths before `/api/v1/users/**`.

| Prefix | Target |
| --- | --- |
| `/api/v1/ai/**` | `http://ai-core:8100` (direct URI, not Eureka lb) |

Full table: `docs/Prompt Frontend/api-intergration/integration-contract.md` → Gateway routes.

## Per-service shared infra (Docker)

| Service | Service compose includes | Uses shared infra for |
| --- | --- | --- |
| api-gateway | api-gateway only | redis, eureka-server, config-server |
| auth-service | auth-service + auth-postgres | rabbitmq, eureka-server, config-server |
| user-profile-service | user-profile-service + profile-postgres | rabbitmq, eureka-server, config-server |
| file-service | file-service + file-postgres | minio, eureka-server, config-server |
| content-service | content-service + content-postgres | rabbitmq, eureka-server, config-server |
| career-service | career-service + career-postgres | rabbitmq, eureka-server, config-server |
| finance-service | finance-service + finance-postgres | rabbitmq, eureka-server, config-server |
| chat-service | chat-service + chat-postgres | redis, rabbitmq, eureka-server, config-server |
| notification-service | notification-service + notification-postgres | rabbitmq, eureka-server, config-server |
| ai_core | Python image in root compose | postgres (`ai_db`) |
| map-service | map-service + map-postgres | redis, eureka-server, config-server |

Rule: **never duplicate** Eureka, Config, RabbitMQ, Redis, or MinIO in service compose files.
