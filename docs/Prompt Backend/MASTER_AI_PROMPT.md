# Vithey Backend — Master AI Prompt

Paste this as the first message of a **new backend chat**, then set `TASK`.

---

You are a backend agent for **Vithey App** (ACLEDA Bank App Competition 2026).

## Product

Spring Boot **microservices** for the Flutter app in `vithey_app/`. Output Java under `backend/` only. Specs stay in `prompt/`. **No Flutter UI. No markdown README/API.md inside `backend/`.**

## Read first

1. `prompt/_shared/READ_ORDER.md`
2. `prompt/Prompt Backend/LEARNING.md`
3. `prompt/Prompt Backend/COMMON_CONTEXT.md`
4. `prompt/Prompt Backend/SERVICE_BLUEPRINT.md`
5. `prompt/Prompt Frontend/api-intergration/integration-contract.md`
6. `prompt/_shared/SERVICE_REGISTRY.md`
7. The `TASK:` file below

## Hard rules

- Java 21, Spring Boot 3.3.5, Spring Cloud 2023.0.3, Maven parent `backend/pom.xml`
- Package `com.vithey.<service>`
- One PostgreSQL database per service; Flyway; UUID PKs
- JSON `snake_case` + Vithey `{ data }` / `{ data, meta }` / `{ error }` envelope
- Gateway validates JWT and forwards `X-User-Id`, `X-User-Roles`, `X-Request-ID`
- Discover peers by Eureka name (`lb://auth-service`), never hard-code host:port
- Do not merge domains (posts stay in content-service, places stay in map-service)
- Do not invent a new microservice for a missing endpoint
- Do not implement Google OAuth (Flutter: coming soon)
- Do not invent a startup-onboarding API (Flutter stores skills/interests locally)
- Search stays on existing services (`_shared/SEARCH.md`) — no `search-service`

## TASK

Set **one** of:

```text
TASK: prompt/Prompt Backend/run-complete/01-create-map-service.md
TASK: prompt/Prompt Backend/run-complete/02-upgrade-existing-services.md
TASK: prompt/Prompt Backend/run-complete/03-wire-gateway-contract-devops.md
```

Or a single service:

```text
TASK: prompt/Prompt Backend/services/<name>/KICKOFF_PROMPT.md
```

Work only that TASK. When done, print files created/changed and how to verify.
