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

## API testing (Postman)

Local collections live in `postman/` at the repo root:

| File | Purpose |
| --- | --- |
| `User-Module.postman_collection.json` | user-profile-service endpoints (`/api/v1/users/**`) plus auth login helper |
| `File-Module.postman_collection.json` | file-service endpoints (`/api/v1/files/**`) plus auth login helper |
| `Content-Module.postman_collection.json` | content-service endpoints (`/api/v1/posts/**`, follow graph) plus auth login helper |
| `Vithey-Local.postman_environment.json` | Shared local variables (`base_url`, credentials, tokens, `file_id`, `post_id`) |

**Flow:** import collections + env → select **Vithey Local** → run **Auth → Login** (saves Bearer token) → run module requests. Collections auto-login when `access_token` is empty.

Swagger (direct): user-profile `http://localhost:8082/swagger-ui.html`, file-service `http://localhost:8083/swagger-ui.html`, content-service `http://localhost:8084/swagger-ui.html` — Authorize with the same JWT.

Gateway base URL: `http://localhost:8080`. Avatar updates require uploading a file first via `POST /api/v1/files/upload` (`type=AVATAR`), then passing the returned `file_id` to `PATCH /api/v1/users/me/avatar`. Media posts need a prior `POSTER`/`VIDEO` upload; set `poster_file_id` / `video_file_id` before Content Module create-post requests. Presigned URLs use `MINIO_PUBLIC_ENDPOINT` (local default `http://localhost:19000`).

Personal environment overrides are ignored by `postman/.gitignore`.

## Related

| Topic | Location |
| --- | --- |
| Docker run | `Prompt Devops/DOCKER.md` |
| Paths | `_shared/REPO_PATHS.md` |
| **Global search API** | `_shared/SEARCH.md` |
| Architecture diagram | `backend plan.png` |

## Output

Generates `backend/services/<name>/` runnable Spring Boot apps.

## Master prompt

`MASTER_AI_PROMPT.md` — set `TASK:` to a service `SERVICE_PROMPT.md` or `KICKOFF_PROMPT.md`.
