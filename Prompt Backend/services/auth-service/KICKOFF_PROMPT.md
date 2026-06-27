# Auth Service — Kickoff Prompt

You are building the **Auth Service** for Vithey App: registration, login, JWT
issuance, RBAC, token refresh/logout, password reset, and AUB student verification.

## Read First (in this order, then stop and build)
1. `../../COMMON_CONTEXT.md` — global platform rules (stack, layout, envelopes, codes).
2. `COMMON_CONTEXT.md` — this service's identity, entities, events, boundaries.
3. `SERVICE_PROMPT.md` — the authoritative API contract and build checklist.

> Precedence on conflict: `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Fixed Facts
- **Port:** 8081  ·  **Database:** `auth_db`  ·  **Package:** `com.vithey.auth`
- **Access token TTL:** 15 min  ·  **Refresh token TTL:** 7 days (root rules).

## Non-Negotiable Rules
- Owns user **credentials** and **refresh tokens** only — profile data lives in User-Profile Service.
- Publishes `user.registered` and `student.verified` to RabbitMQ; never calls those services directly.
- Follow the standard response envelope and HTTP status codes from root `COMMON_CONTEXT.md`.

## Definition of Done
A runnable Spring Boot service on port 8081 implementing every endpoint in
`SERVICE_PROMPT.md`, with the required modules, tests, and docs listed there.
