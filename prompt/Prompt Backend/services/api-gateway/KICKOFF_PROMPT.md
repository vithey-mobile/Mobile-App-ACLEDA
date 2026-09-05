# API Gateway — Kickoff Prompt

You are building the **API Gateway** for Vithey App — single entry point with JWT, rate limiting, CORS, and routing.

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

Also read `Prompt Frontend/api-intergration/integration-contract.md` for gateway route order.

**Precedence:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Identity

Port 8080, no database. Registry: `_shared/SERVICE_REGISTRY.md`.

## Rules

- No domain business logic or database.
- Start **after** domain services register in Eureka.

## Definition of done

Runnable gateway on port 8080 routing all `/api/v1/**` paths per `SERVICE_PROMPT.md` and `integration-contract.md`.
