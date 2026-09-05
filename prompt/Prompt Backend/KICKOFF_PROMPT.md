# Vithey App — Backend Kickoff Prompt

You are building the **Vithey App** Spring Boot microservice backend. Work **one service at a time**.

## Read first

Follow `_shared/READ_ORDER.md` → Backend — one service.

Always read `SERVICE_BLUEPRINT.md`, root `COMMON_CONTEXT.md`, and `integration-contract.md` before a service folder.

## Architecture

See `backend plan.png` and root `COMMON_CONTEXT.md` (Eureka, Config, RabbitMQ, Redis, MinIO, gateway).

## Rules

- **Backend API only** — no Flutter code
- **Java 21**, Spring Boot 3.3.5, Spring Cloud 2023.0.3, Maven multi-module
- One runnable Spring Boot app per `backend/services/<name>/`
- Database per service — no shared tables
- REST between services; RabbitMQ for async events
- OpenAPI/Swagger on every service
- API paths must match `integration-contract.md`
- **No markdown docs in `backend/`** — specs stay in `prompt/`

## Build order

`_shared/SERVICE_REGISTRY.md` — do not copy the port table here.

Build **file-service** before content/career. Start **api-gateway** after domain services.

## ai-service

Java stub in `backend/services/ai-service/`. Optional Python replacement: `services/ai-service/INTEGRATION.md`.

## Working style

- One service fully done before the next
- Verify: compile → `/actuator/health` → Swagger
- Register with Eureka after infrastructure is up

## Output layout

`_shared/REPO_PATHS.md`
