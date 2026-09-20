# Content Service — Kickoff Prompt

You are building the **Content Service** for Vithey App — posts, comments, reactions, mentions, and follows.

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

- Media URLs from file-service only — store `media_file_id` references, not binaries.
- Forward Feign auth headers (`FeignAuthConfig`) to file-service and user-profile-service.
- Publish RabbitMQ **JSON** events for notification-service on social actions.
- Feed is newest-first only — do not invent a `sort` query param.
- List endpoints must batch enrichment (no per-post N+1 count/Feign loops).

## Definition of done

Runnable Spring Boot on port 8084 implementing every endpoint in `SERVICE_PROMPT.md`, with Flyway V1–V3, OpenAPI examples, and unit tests (`FollowServiceTest`, `PostServiceTest`).
