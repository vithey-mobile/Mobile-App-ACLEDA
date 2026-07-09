# Vithey App — Master AI Prompt

> **Human index:** `Project Overview.txt`  
> **Shared registry:** `_shared/SERVICE_REGISTRY.md` · **Paths:** `_shared/REPO_PATHS.md`  
> Copy everything below the line into a new Cursor chat.

---

You are building **Vithey App** for the ACLEDA Bank AUB App Competition.

## Repository

```text
MASTER_AI_PROMPT.md
Project Overview.txt
_shared/                 ← registry, paths, read order (link, do not duplicate)
Prompt Frontend/
Prompt Backend/
Prompt Devops/
```

**Do not create** `docs/`, `archive/`, or markdown inside `backend/` — docs live in `prompt/` only.

## Read first

See `_shared/READ_ORDER.md`. Minimum for any task:

1. `Prompt Frontend/api-intergration/integration-contract.md`
2. Layer `KICKOFF_PROMPT.md` + `COMMON_CONTEXT.md`
3. The `TASK:` file at the bottom of this prompt

## Outputs

See `_shared/REPO_PATHS.md`. Summary:

| Layer | Folder | Stack |
| --- | --- | --- |
| Mobile | `vithey_app/` | Flutter, GetX, Dio |
| Backend | `backend/` | Java 21, Spring Boot 3.3.5, Maven |
| Docker | `backend/infrastructure/` + `backend/services/*/` | Per-folder compose |

## Global rules

- **One task per session:** one screen OR one microservice OR one devops prompt
- **Complete runnable code** — no `// TODO` stubs
- **API contract:** paths and JSON envelopes must match `integration-contract.md`
- **Gateway route order:** `/users/me/cv` and `/users/*/follow` before `/users/**`
- **Flutter paths** in `api_endpoints.dart` are relative to `API_BASE_URL` (no `/api/v1` prefix)
- **Do not duplicate** port tables, envelope specs, or Docker steps — link `_shared/` and layer docs

## Build phases

| Phase | What | Entry |
| --- | --- | --- |
| 0 DevOps | Docker + CI | `Prompt Devops/v1/00-foundation-prompt.md` or `services/<name>/DEVOPS_PROMPT.md` |
| 0b Observability | Monitoring stack | `Prompt Devops/v1/08-monitoring-observability-prompt.md` |
| 1 Backend | One service per session | `Prompt Backend/services/<name>/KICKOFF_PROMPT.md` |
| 2 Frontend | One screen per session | `Prompt Frontend/Screen prompt/README.md` |
| 3 Integration | Wire Flutter to API | `Prompt Frontend/api-intergration/00-api-intergration-prompt.md` |

**Service build order and ports:** `_shared/SERVICE_REGISTRY.md` (do not copy table here).

## Architecture

`Prompt Backend/backend plan.png` · `Prompt Backend/COMMON_CONTEXT.md`

## Current task

```
TASK: Prompt Devops/v1/00-foundation-prompt.md
```

## Frontend UI System (Run this first for UI work)

When the `TASK:` targets any **Frontend** prompt, the UI must follow these rules:

- **GetX + GetMaterialApp** for routing/DI/state
- **Clean Architecture** folder structure (features split into domain/data/presentation)
- **Material 3 theme** enabled
- **Use Shadcn Flutter components** (`shadcn_flutter ^0.0.52`) for UI. Requires Dart ≥3.3 / Flutter ≥3.22. Do not use default Material widgets unless necessary.

Source of truth for frontend UI rules:
- `Prompt Frontend/KICKOFF_PROMPT.md`
- `Prompt Frontend/COMMON_CONTEXT.md`

If you are migrating UI: keep existing controllers/repositories/services, and refactor only the presentation/widgets layer to use Shadcn Flutter-style components and the shared component system.

Examples:
- `TASK: Prompt Devops/v1/08-monitoring-observability-prompt.md`
- `TASK: Prompt Devops/services/auth-service/DEVOPS_PROMPT.md`
- `TASK: Prompt Backend/services/auth-service/SERVICE_PROMPT.md`
- `TASK: Prompt Frontend/Screen prompt/auth/03-auth-prompt.md`
