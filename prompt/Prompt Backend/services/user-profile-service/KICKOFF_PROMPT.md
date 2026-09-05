# User Profile Service — Kickoff Prompt

You are building the **User Profile Service** for Vithey App — profiles, avatars, bios, social links, and settings.

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

## Definition of done

Runnable Spring Boot on port 8082 implementing every endpoint in `SERVICE_PROMPT.md`, with:

- OpenAPI annotations (`@Tag` / `@Operation` / `@Schema` examples) verified in Swagger UI
- Performance rules from `SERVICE_LOGIC.md` (Feign outside TX, projections, dirty-check, timeouts)
- Tests per root `COMMON_CONTEXT.md`
