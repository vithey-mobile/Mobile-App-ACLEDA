# AI — DevOps Prompt (`ai_core`)

Python **`ai_core/`** is the Vithey AI runtime. Java `backend/services/ai-service/` is **retired**.

**Integration:** `Prompt Backend/services/ai-service/INTEGRATION.md`  
**Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `ai_core/` (repo root) |
| Port | `8100` |
| Compose name | `ai-core` |
| Image | `vithey-ai-core:local` (local) / GHCR tag when published |
| Database | `ai_db` on shared Postgres |
| Gateway | `/api/v1/ai/**` → `http://ai-core:8100` |

## Docker Compose

Defined in root `backend/docker-compose.yml` (and demo overlay). Started by:

```powershell
cd backend
.\scripts\start-all.ps1
```

Optional secrets: `ai_core/.env` (`DEEPSEEK_API_KEY`, …).

## Verification

```powershell
Invoke-RestMethod http://localhost:8100/health
# Via gateway (needs JWT):
# POST http://localhost:8080/api/v1/ai/chat
```

Confirm **no** `vithey-ai-service` container.
