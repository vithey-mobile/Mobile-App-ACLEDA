# Map Service — Kickoff Prompt

You are building the **Map Service** for Vithey App — Google Maps / Places integration so users can find shops and places around their current location with filterable search.

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

- **Backend REST API only** — no Flutter / Google Maps SDK UI code
- Call **Google Places API (New)** from the server; never expose `GOOGLE_MAPS_API_KEY` / `GOOGLE_PLACES_API_KEY` to the mobile client
- Cache nearby/search results in **Redis** to protect Google quota
- Store only Vithey-owned data in PostgreSQL (favorites, recent searches, optional place snapshots) — do **not** mirror the full Google Places catalog
- API paths must match `integration-contract.md` once routes are added
- Snake_case JSON + standard Vithey response envelope

## Definition of done

Runnable Spring Boot on port **8090** implementing every endpoint in `SERVICE_PROMPT.md`, with tests per root `COMMON_CONTEXT.md`, Eureka registration as `map-service`, and gateway route `/api/v1/places/**`.
