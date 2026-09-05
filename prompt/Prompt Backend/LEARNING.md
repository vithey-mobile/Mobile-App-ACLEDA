# Learn the Vithey Backend

Use this file to understand the platform before you write or run a create/upgrade prompt.

## What you are building

Vithey is a **Spring Boot microservice** backend for a Flutter app. The phone never talks to a service port directly. It always calls the **API Gateway**.

```text
Flutter (vithey_app)
    │  Authorization: Bearer <JWT>
    │  API_BASE_URL = http://localhost:8080/api/v1
    ▼
API Gateway :8080
    │  validates JWT
    │  adds X-User-Id, X-User-Roles, X-Request-ID
    │  routes by path prefix
    ▼
One domain service (8081–8090)
    │  owns its own PostgreSQL database
    ▼
Optional: Redis cache · RabbitMQ events · MinIO files · Google Places
```

**Rule:** one service = one database = one domain. Do not put posts in user-profile, or places in content.

## The two kinds of work

| Kind | Meaning | Example |
|------|---------|---------|
| **Create a new service** | No Java folder yet | `map-service` (port 8090) |
| **Upgrade an existing service** | Java exists; Flutter already calls a missing path | change password, delete comment, delete notification |

Search is **not** a new service. People search lives on user-profile; post/job/video search lives on content. Spec: `_shared/SEARCH.md`.

Startup onboarding (skills / interests / discovery) is **local Flutter only** today. Do not invent a backend for it unless the app starts calling one.

Google sign-in is **coming soon** on the app. Do not implement OAuth in these prompts.

## Service map (learn this table)

| # | Service | Port | Owns | Flutter screens |
|---|---------|------|------|-----------------|
| 0 | infrastructure | 8761, 8888 | Eureka + Config Server | — |
| 1 | api-gateway | 8080 | JWT, CORS, rate limit, routes | every network call |
| 2 | auth-service | 8081 | register, login, JWT, student verify | Auth, Student Verification, Settings password |
| 3 | user-profile-service | 8082 | profile, avatar, settings, **people search** | Profile, Settings, Search (people) |
| 4 | file-service | 8083 | MinIO upload/download | Create Post, Apply CV, avatar |
| 5 | content-service | 8084 | posts, comments, likes, follows, **post search**, job *posts* | Home, Reels, Post Detail, Search (posts) |
| 6 | career-service | 8085 | applications + default CV metadata | Apply CV, Applicant list |
| 7 | finance-service | 8086 | fees / payments (STUDENT only) | Finance |
| 8 | chat-service | 8087 | conversations, messages, STOMP `/ws` | Chat |
| 9 | notification-service | 8088 | inbox + FCM | Notification, Home badge |
| 10 | ai-service | 8089 | chatbot sessions | AI Chatbot |
| 11 | **map-service** | **8090** | nearby shops via Google Places | Map |

Ports and start order: `_shared/SERVICE_REGISTRY.md`.

## How a typical feature is split

**Apply to a job**

1. `file-service` — upload CV (`POST /files/upload?type=CV`)
2. `career-service` — save default CV (`PUT /users/me/cv`) and apply (`POST /job-applications`)
3. `content-service` — already owns the job *post* (`type=JOB`)
4. RabbitMQ `job.application.submitted` → `notification-service`

**Create a post**

1. `file-service` — upload poster/video
2. `content-service` — create post with `media_file_id`
3. Event `post.created` → notification

**Open Map**

1. Flutter Google Maps SDK draws the map (client key)
2. `map-service` searches Google Places **on the server** (server key, never in the app)
3. Response includes `latitude` / `longitude` for markers + the result list

## Standard API rules (every service)

- Base path: `/api/v1/...`
- JSON: `snake_case`
- Envelope: `{ "data": ... }` success, `{ "data": [...], "meta": {...} }` lists, `{ "error": { "code", "message", "details" } }` errors
- Identity: gateway JWT → `X-User-Id`
- Pagination: `page` (1-based), `limit`
- UUID primary keys, Flyway migrations, `created_at` / `updated_at`

Full contract: `Prompt Frontend/api-intergration/integration-contract.md`.

## Local run (mental model)

1. Start shared infra: Eureka, Config, Postgres, Redis, RabbitMQ, MinIO  
   `backend/infrastructure/docker-compose.yml`
2. Start domain services (8081–8090). Each has its own compose + private Postgres.
3. Start **gateway last** (8080).
4. Flutter points at `http://localhost:8080/api/v1` (Android emulator: `http://10.0.2.2:8080/api/v1`).
5. Swagger on each service: `http://localhost:<port>/swagger-ui.html`

## How to read prompts (one service)

Follow `_shared/READ_ORDER.md`:

1. `KICKOFF_PROMPT.md`
2. Root `COMMON_CONTEXT.md` (stack + envelope + events)
3. Service `COMMON_CONTEXT.md` (this domain only)
4. `API_ENDPOINTS.md`
5. `FOLDER_STRUCTURE.md`
6. `SERVICE_LOGIC.md`
7. `DB_SCHEMA.md`
8. `SERVICE_PROMPT.md` — **authoritative build checklist**

On conflict: `SERVICE_PROMPT.md` wins.

## How to add a brand-new service

Copy this checklist. `map-service` is the current example.

1. Spec folder: `prompt/Prompt Backend/services/<name>/` (7 files)
2. Java module: `backend/services/<name>/` (Spring Boot, package `com.vithey.<name>`)
3. Parent POM: add `<module>services/<name></module>` in `backend/pom.xml`
4. Database: `CREATE DATABASE <name>_db;` in `backend/infrastructure/scripts/init-databases.sql`
5. Config: `backend/infrastructure/config-repo/<name>.yml`
6. Gateway: route `/api/v1/<prefix>/**` → `lb://<name>` **before** `/users/**`
7. Registry: `_shared/SERVICE_REGISTRY.md`
8. Contract: `integration-contract.md` gateway table + screen row
9. DevOps: `prompt/Prompt Devops/services/<name>/DEVOPS_PROMPT.md` + service `docker-compose.yml`
10. Env: `_shared/ENV_VARS.md`

**Do not** add a new service for a single missing endpoint. Extend the owner service instead.

## Current completeness (2026-09-05)

| Area | Status |
|------|--------|
| Java services 8080–8089 | Built |
| **map-service 8090** | **Prompts only — no Java** |
| Flutter Map | Still calls Photon/Komoot, not Vithey |
| Auth change password | Flutter `PATCH /auth/me/password` — **missing** |
| Comment delete | Flutter `DELETE /posts/{id}/comments/{id}` — **missing** |
| Notification delete + `is_read` + rich DTO | Spec exists; **code incomplete** |
| Career CV preview | Flutter `GET /job-applications/{id}/cv-preview` — **missing** |
| AI stream / regenerate / cancel | Flutter paths exist; **Java stub incomplete** |
| Gateway `/places/**` | **Missing** |
| Orphan `/jobs/**` | Gateway points at career; Flutter uses `/posts?type=JOB` |

## What to run next

**10 GLM chats in parallel** (one service per terminal): [`run-glm-flash/README.md`](run-glm-flash/README.md)

Or sequential (one chat at a time): [`run-complete/README.md`](run-complete/README.md)

1. Create `map-service` (only missing Java service)
2. Upgrade existing services to match Flutter
3. Wire gateway, contract, DevOps, Postman

Session starter: [`MASTER_AI_PROMPT.md`](MASTER_AI_PROMPT.md)
