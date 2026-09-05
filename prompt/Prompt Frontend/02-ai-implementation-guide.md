# AI Implementation Guide — Full Stack

Use this document to build Vithey App end-to-end with Cursor or another AI coding agent.  
**Read `api-intergration/integration-contract.md` first** — it is the binding API contract.

## Current repo status

| Area | Location |
| --- | --- |
| Shared registry | `_shared/SERVICE_REGISTRY.md`, `_shared/REPO_PATHS.md` |
| Flutter app | `vithey_app/` |
| Backend | `backend/` |
| API contract | `api-intergration/integration-contract.md` |

## Master prompt

Use `MASTER_AI_PROMPT.md` — set `TASK:` to your prompt file. Read order: `_shared/READ_ORDER.md`.

## Recommended build order

### Phase 0 — DevOps

`Prompt Devops/v1/00` → `02` → `06` → `07` (skip deprecated `v1/01`)

**Gate:** `backend/scripts/start-all.ps1` → gateway health OK

### Phase 1 — Backend

`_shared/SERVICE_REGISTRY.md` — one service per session.

**Gate:** `/actuator/health` + Swagger + Eureka registration

### Phase 2 — Flutter (one screen per AI session)

1. `Screen prompt/00-foundation-prompt.md` — skeleton + core widgets
2. Follow feature flows in `Screen prompt/README.md`
3. After each screen: register route, test navigation per `01-navigation-and-flow.md`

**Gate per screen:** navigates correctly, uses repositories (mock or real), light/dark theme.

### Phase 3 — Wire real API

Run:

```text
TASK: Prompt Frontend/api-intergration/00-api-intergration-prompt.md
```

Then verify:

1. Set `API_BASE_URL` in `vithey_app/.env`
2. Disable `USE_MOCK_AUTH` and `USE_MOCK_API`
3. Mark **API integrated** in each screen file's Status checklist when live calls work

---

## Per-screen AI prompts (quick reference)

Each screen/flow prompt lives under `Screen prompt/` and may be grouped by feature folders.

### Template

```text
Build Vithey App Flutter screen/flow per:
- Prompt Frontend/Screen prompt/<feature>/<prompt-file>.md (full spec)
- Prompt Frontend/api-intergration/integration-contract.md (API paths)

Use existing core/widgets and data layer from foundation.
Implement: screen, controller, binding, module widgets, repository methods.
Register route in app_pages.dart.
Wire API calls to gateway base URL; use mock only if USE_MOCK_AUTH=true.
Deliver complete runnable Dart code.
```

### Screen index

See `_shared/SERVICE_REGISTRY.md` → Screen → backend map, and `Screen prompt/README.md` for full file list.

---

## Per-service AI prompt (backend)

```text
Build the Vithey <service-name> microservice per _shared/READ_ORDER.md (Backend section).
Authoritative checklist: Prompt Backend/services/<service>/SERVICE_PROMPT.md
Output: backend/services/<service>/
```

---

## Integration test script (manual)

After backend + one Flutter screen (Auth) exist:

```bash
# 1. Register
curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@aub.edu.kh","phone":"+855120000001","password":"SecurePass1!","full_name":"Test User","role":"USER"}'

# 2. Login — save access_token
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"test@aub.edu.kh","password":"SecurePass1!"}'

# 3. Profile (replace TOKEN)
curl -s http://localhost:8080/api/v1/users/me -H "Authorization: Bearer TOKEN"
```

Flutter: login with same credentials → should land on Home when content-service returns posts (empty list OK).

---

## Keeping docs in sync

When you change an endpoint or screen flow:

1. Update `api-intergration/integration-contract.md`
2. Update `api-intergration/api-overview.md`
3. Update the screen file in `Screen prompt/`
4. Update `api_endpoints.dart` in Flutter (when it exists)
