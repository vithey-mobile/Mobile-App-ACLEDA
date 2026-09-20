# Prompt 3 of 3 — Wire gateway, contract, DevOps

Copy everything below the line into a **new chat** after Prompts 1 and 2 are merged. Do not rebuild map-service. Do not re-implement upgrade endpoints.

---

You are a docs + DevOps + gateway agent in the Vithey repo. **Make the contract, gateway tables, DevOps prompts, and Postman match what Java now does.** Prefer editing docs and compose wiring. Touch Java only if a route or env key is still missing.

## Read first

1. `prompt/Prompt Backend/LEARNING.md`
2. `prompt/_shared/SERVICE_REGISTRY.md`
3. `prompt/Prompt Frontend/api-intergration/integration-contract.md`
4. `prompt/Prompt Devops/v1/06-per-service-docker-compose-prompt.md`
5. `prompt/Prompt Devops/services/file-service/DEVOPS_PROMPT.md` (template)
6. Actual routes: `backend/infrastructure/config-repo/api-gateway.yml` and `backend/services/api-gateway/src/main/resources/application.yml`
7. `backend/pom.xml` modules and `backend/infrastructure/scripts/init-databases.sql`

## 1. Integration contract

Edit `prompt/Prompt Frontend/api-intergration/integration-contract.md`:

### Gateway table

Add (order 0, before `/users/**`):

```text
/api/v1/places/**  →  map-service
```

Keep `/api/v1/job-applications/**` → career-service.  
Do **not** list `/api/v1/jobs/**` unless Java actually serves it (it should not).

Add if missing:

```text
/api/v1/users/*/posts   →  content-service
/api/v1/users/*/report  →  chat-service
```

### Screen table

Add row:

| Screen | Services | Primary endpoints |
|--------|----------|-------------------|
| Map | map-service | `GET /places/nearby`, `GET /places/search`, `GET /places/autocomplete`, `GET /places/{id}`, `GET/POST /places/favorites`, `DELETE /places/favorites/{id}`, `GET/DELETE /places/history` |

### Auth / content / career / notification / AI rows

Align verbs with Flutter + Prompt 2:

- Settings / password: `PATCH /auth/me/password`
- Post Detail comments: add `DELETE /posts/{id}/comments/{commentId}`
- Notification: `GET /notifications?is_read=`, `DELETE /notifications/{id}`, unread-count, devices
- Applicant CV: `GET /job-applications/{id}/cv-preview`
- Chatbot: mention `/ai/chat/stream`, regenerate, cancel (see existing chatbot screen prompt)

### Checklists

- Flutter: add `PlaceRepository` / `/places/*` to the integration checklist
- Backend: gateway must include places; `GOOGLE_PLACES_API_KEY` for map-service
- Known gaps: remove items that Prompt 1–2 fixed; leave Google OAuth and startup-onboarding as non-gaps (intentionally not backend)

### COMMON_CONTEXT (frontend)

If `prompt/Prompt Frontend/COMMON_CONTEXT.md` has a feature list, add Map → map-service. Do not GenZ-sweep the app.

## 2. Gateway prompt files

Sync route tables in:

- `prompt/Prompt Backend/services/api-gateway/API_ENDPOINTS.md`
- `prompt/Prompt Backend/services/api-gateway/SERVICE_PROMPT.md`

Must match live YAML. Include `/ws/**`, `/places/**`, `/users/*/posts`, `/users/*/report`. Drop orphan `/jobs/**`.

If YAML is still missing `/places/**`, add it (same as Prompt 1).

Places rate limits (if supported): 30/min nearby+search, 60/min autocomplete, else global 100/min.

## 3. Registry / compose docs

Already listed in `_shared/SERVICE_REGISTRY.md` — verify map-service row (8090, Redis + map-postgres) is accurate. Do not duplicate the port table elsewhere.

Add `map-service` to the compose table in `prompt/Prompt Devops/v1/06-per-service-docker-compose-prompt.md`:

```text
map-service | map-service + map-postgres | redis, eureka-server, config-server
map-service -> map_db
```

## 4. DevOps prompt for map

Create `prompt/Prompt Devops/services/map-service/DEVOPS_PROMPT.md` using the file-service prompt as the template:

| Item | Value |
|------|-------|
| Port | 8090 |
| Image | `ghcr.io/<owner>/vithey-map-service` |
| DB | `map_db` |
| Compose containers | `map-service`, `map-postgres` |
| Shared | redis, eureka-server, config-server |
| Extra env | `GOOGLE_PLACES_API_KEY` |

Add the row to `prompt/Prompt Devops/services/README.md`.

If `backend/services/map-service/docker-compose.yml` / `Dockerfile` / `.env.example` are missing, create them (Prompt 1 should have). CI: `.github/workflows/map-service-ci.yml` Maven test + Docker build `SERVICE_PORT=8090` **only if** other services already have that workflow pattern — do not invent a new CI style.

## 5. Postman

Add `postman/Map-Module.postman_collection.json`:

- Auth → Login helper (same as other collections)
- Nearby, search, autocomplete, detail, favorites CRUD, history
- Variables: `lat` default `11.5564`, `lng` default `104.9282` (Phnom Penh)

Update `prompt/Prompt Backend/README.md` Postman table with this file.

## 6. Backend README

`prompt/Prompt Backend/README.md` must point to:

- `LEARNING.md`
- `MASTER_AI_PROMPT.md`
- `run-complete/`
- map-service folder
- Postman Map collection

Do not copy the full port table (link `SERVICE_REGISTRY.md`).

## Stop when

- Contract gateway + screen tables include Map and Prompt 2 endpoints
- Gateway prompt files = live YAML
- DevOps map prompt + README row exist
- Postman Map collection exists
- Print a short “docs touched” list

Do not implement new domain features. Do not call Google Places from docs.
