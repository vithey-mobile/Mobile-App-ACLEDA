# Career Service — Kickoff Prompt

You are building the **Career Service** for Vithey App — job applications, CV references, and applicant review.

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

- Job posts live in content-service; CV files in file-service — store references only.

## Definition of done

Runnable Spring Boot on port 8085 implementing every endpoint in `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`.
