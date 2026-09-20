# Read Order

Standard file read order. Paths are under **`docs/`** (e.g. `docs/Prompt Backend/...`).  
Service kickoffs should link here — do not invent shorter lists.

## Any AI session

1. `Prompt Backend/MASTER_AI_PROMPT.md` (or layer kickoff)
2. `Prompt Backend/LEARNING.md` when new to the backend
3. `Prompt Frontend/api-intergration/integration-contract.md` — API contract (binding)
4. Layer `COMMON_CONTEXT.md`
5. The `TASK:` prompt file

## Backend — one service

Read in `Prompt Backend/services/<name>/`:

1. `KICKOFF_PROMPT.md`
2. `../../COMMON_CONTEXT.md` (root backend rules)
3. `COMMON_CONTEXT.md` (service domain rules)
4. `API_ENDPOINTS.md`
5. `FOLDER_STRUCTURE.md`
6. `SERVICE_LOGIC.md`
7. `DB_SCHEMA.md`
8. `SERVICE_PROMPT.md` (build checklist — authoritative)

**AI only:** docs still live under `services/ai-service/`, but runtime is **`ai_core/` :8100**. Read `INTEGRATION.md` after step 3 (before `API_ENDPOINTS.md`).

**Precedence on conflict:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md` > `integration-contract.md` for cross-layer API paths.

## DevOps — one service

1. `Prompt Devops/KICKOFF_PROMPT.md`
2. `Prompt Devops/COMMON_CONTEXT.md`
3. `Prompt Devops/DOCKER.md` + `docs/LOCAL_DEV.md` (how we run today)
4. `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` (incremental compose)
5. `Prompt Devops/services/<name>/DEVOPS_PROMPT.md`
6. Matching `Prompt Backend/services/<name>/` files if wiring env or ports

## Frontend — one screen

1. `Prompt Frontend/KICKOFF_PROMPT.md`
2. `Prompt Frontend/COMMON_CONTEXT.md`
3. `Prompt Frontend/api-intergration/integration-contract.md`
4. `Prompt Frontend/Screen prompt/<feature>/<screen>.md`
5. `Folder_Stucture_flutter.md` when creating new modules

## DevOps scaffolding (full platform)

`Prompt Devops/v1/00-foundation-prompt.md` → `01` → `02` → `03` → `04` → `05` → `06` → `07` → `08`

Note: `v1/01` is legacy all-in-one compose. **Day-to-day run:** `backend/scripts/start-all.ps1` + `DOCKER.md`. Incremental model: `v1/06`. **Monitoring:** `v1/08` → output in `monitoring/`.
