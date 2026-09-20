# File Service — Kickoff Prompt

You are building the **File Service** for Vithey App — upload, storage, and download via MinIO.

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

Port, storage buckets, package: see service `COMMON_CONTEXT.md`. Registry: `_shared/SERVICE_REGISTRY.md`.

## Rules

- Build **before** content-service and career-service (they depend on file URLs).

## Definition of done

Runnable Spring Boot on port 8083 implementing every endpoint in `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`.
