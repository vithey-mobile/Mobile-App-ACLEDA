# Infrastructure — Kickoff Prompt

You are building **Infrastructure** for Vithey App — Eureka, Config Server, and shared `docker-compose.yml`.

## Read first

Follow `_shared/READ_ORDER.md` → Backend — one service.

In this folder, read in order:

1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md`
3. `API_ENDPOINTS.md`
4. `FOLDER_STRUCTURE.md`
5. `SERVICE_LOGIC.md`
6. `DB_SCHEMA.md`
7. `SERVICE_PROMPT.md`

**Precedence:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Identity

Eureka 8761, Config 8888. Shared infra ports: `_shared/SERVICE_REGISTRY.md`.

## Rules

- Infrastructure only — no domain REST APIs.
- `docker-compose.yml` creates `vithey-network` and shared Postgres, Redis, RabbitMQ, MinIO.
- Eureka and Config must start before business services.

## Definition of done

Runnable Eureka + Config Server and healthy shared infra compose per `SERVICE_PROMPT.md`.
