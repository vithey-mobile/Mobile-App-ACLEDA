# Prompt Backend — Vithey App (Spring Boot)

All backend microservice AI prompts live here.

## Start

1. `_shared/READ_ORDER.md` — standard read order
2. `KICKOFF_PROMPT.md` + `COMMON_CONTEXT.md` + `SERVICE_BLUEPRINT.md`
3. `Prompt Frontend/api-intergration/integration-contract.md`
4. One service at a time: `services/<name>/KICKOFF_PROMPT.md`

**Build order and ports:** `_shared/SERVICE_REGISTRY.md` (do not copy table here).

## Per-service files

Each `services/<name>/` folder:

| File | Purpose |
| --- | --- |
| `KICKOFF_PROMPT.md` | Session entry — links to `_shared/READ_ORDER.md` (7-file order) |
| `COMMON_CONTEXT.md` | Domain entities, boundaries, events |
| `API_ENDPOINTS.md` | REST contract |
| `FOLDER_STRUCTURE.md` | Output tree |
| `SERVICE_LOGIC.md` | Flows, errors, integrations |
| `DB_SCHEMA.md` | Tables and migrations |
| `SERVICE_PROMPT.md` | Build checklist (authoritative) |

**ai-service:** also `INTEGRATION.md`.

## Related

| Topic | Location |
| --- | --- |
| Docker run | `Prompt Devops/DOCKER.md` |
| Paths | `_shared/REPO_PATHS.md` |
| Architecture diagram | `backend plan.png` |

## Output

Generates `backend/services/<name>/` runnable Spring Boot apps.

## Master prompt

`MASTER_AI_PROMPT.md` — set `TASK:` to a service `SERVICE_PROMPT.md` or `KICKOFF_PROMPT.md`.
