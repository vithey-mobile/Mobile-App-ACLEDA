# Backend — Create + Complete Pack

Copy-paste prompts for a **new chat**, **one after another**.

For **10 GLM chats at the same time** (one service each), use [`../run-glm-flash/README.md`](../run-glm-flash/README.md) instead.

Read [`../LEARNING.md`](../LEARNING.md) first if you are new to this backend.

## Order (do not skip)

| # | File | What it builds | When done |
|---|------|----------------|-----------|
| 1 | [`01-create-map-service.md`](01-create-map-service.md) | The **only missing** Java service (`map-service` :8090) + enough wiring to boot | `mvn -pl services/map-service -am verify` and Swagger on 8090 |
| 2 | [`02-upgrade-existing-services.md`](02-upgrade-existing-services.md) | Missing endpoints Flutter already calls | change-password, comment delete, notification UI API, CV preview, AI extras |
| 3 | [`03-wire-gateway-contract-devops.md`](03-wire-gateway-contract-devops.md) | Gateway, contract, DevOps, Postman | `/api/v1/places/**` via 8080; compose + CI prompt |

## How to run a prompt

1. Open a **new** Cursor chat.
2. Optional: paste `../MASTER_AI_PROMPT.md` and set `TASK:` to the file.
3. Or copy **everything below the line** in that numbered file.
4. Do not start Prompt 2 until Prompt 1 is merged. Do not start Prompt 3 until 1 and 2 are merged.

## What you should not create

| Idea | Why not |
|------|---------|
| `search-service` | People + posts search already exist |
| `jobs-service` | Job *posts* are `content-service` (`type=JOB`); applications are `career-service` |
| `reels-service` | Reels are video posts |
| Google OAuth service | Flutter marks Google sign-in coming soon |
| Startup onboarding service | Skills/interests are local Flutter storage |

## Specs already written for map

`../services/map-service/` — kickoff, context, endpoints, folder tree, logic, schema, service prompt.

Prompt 1 **implements** those files. Do not rewrite the spec unless you find a conflict with `integration-contract.md`.
