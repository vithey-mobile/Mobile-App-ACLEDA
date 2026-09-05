# Chat Service — Kickoff Prompt

You are building the **Chat Service** for Vithey App — private messaging, requests, read status, block, and report.

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

- User-to-user chat only — not the AI chatbot (`ai-service`).
- Owns conversations and messages; not profiles or push notifications.

## Definition of done

Runnable Spring Boot on port 8087 implementing every endpoint in `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`.
