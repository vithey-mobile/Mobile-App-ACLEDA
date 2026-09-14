# Finance Service — Kickoff Prompt

You are building the **Finance Service** for Vithey App — payment history, status, and due alerts for verified students.

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

Port, DB, package: see service `COMMON_CONTEXT.md`. Registry: `_shared/SERVICE_REGISTRY.md`.

## Rules

- **STUDENT** role required for finance endpoints.
- Fees are seeded upstream — students have read-only access via API.

## Definition of done

Runnable Spring Boot on port 8086 implementing every endpoint in `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`.
