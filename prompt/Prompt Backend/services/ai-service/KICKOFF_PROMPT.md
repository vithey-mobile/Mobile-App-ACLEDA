# AI Service — Kickoff Prompt

You are building the **AI Service** for Vithey App — CV help, interview advice, job tips, and finance Q&A.

## Read first

Follow `_shared/READ_ORDER.md` → Backend — one service.

In this folder, read in order:

1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md`
3. `INTEGRATION.md`
4. `API_ENDPOINTS.md`
5. `FOLDER_STRUCTURE.md`
6. `SERVICE_LOGIC.md`
7. `DB_SCHEMA.md`
8. `SERVICE_PROMPT.md`

**Precedence:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Identity

Port 8089, Eureka name `ai-service`. Registry: `_shared/SERVICE_REGISTRY.md`.

## Implementation options

| Option | Where |
| --- | --- |
| Java stub (current repo) | `backend/services/ai-service/` — gateway routing + local Docker |
| Python replacement | Your project — follow `INTEGRATION.md` contract |

## Rules

- Not the same as `chat-service` (user-to-user messaging).
- Must expose `/api/v1/ai/**` per `API_ENDPOINTS.md` and Vithey response envelope.
- Optional: bridge to external Python stack on `gdce-network` (see `INTEGRATION.md`).

## Definition of done

Service registers in Eureka as `ai-service` on port 8089; `POST /api/v1/ai/chat` works through gateway with Vithey JWT per `SERVICE_PROMPT.md`.
