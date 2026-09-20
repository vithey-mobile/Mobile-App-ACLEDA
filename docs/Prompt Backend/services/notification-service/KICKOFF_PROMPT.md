# Notification Service — Kickoff Prompt

You are building the **Notification Service** for Vithey App — in-app notifications and FCM push delivery.

## Read first

Follow `_shared/READ_ORDER.md` → Backend — one service.

In this folder, read in order:

1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md`
3. **`UPGRADE_FOR_UI.md`** — UI contract (start here if upgrading)
4. `API_ENDPOINTS.md`
5. `FOLDER_STRUCTURE.md`
6. `SERVICE_LOGIC.md`
7. `DB_SCHEMA.md`
8. `SERVICE_PROMPT.md`

**Precedence:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Identity

Port, DB, package: see service `COMMON_CONTEXT.md`. Registry: `_shared/SERVICE_REGISTRY.md`.

## Rules

- Consumes RabbitMQ domain events from other services.
- Empty `FIREBASE_CREDENTIALS_PATH` is OK for local dev (push disabled).

## Definition of done

Runnable Spring Boot on port 8088 implementing every endpoint in `UPGRADE_FOR_UI.md` + `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`. Verify against frontend `Screen prompt/notification/README.md` acceptance checklist.
