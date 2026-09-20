# File Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `file-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/file-service` |
| Port | `8083` |
| Image | `ghcr.io/<owner>/vithey-file-service` |
| Database | `file_db` |

## Docker Compose Output

```text
backend/services/file-service/docker-compose.yml
backend/services/file-service/.env.example
```

**Service compose containers only:** `file-service`, `file-postgres`  
**Shared infra:** `minio` (`quay.io/minio/minio`), `eureka-server`, `config-server`  
**Public media URLs:** set `MINIO_PUBLIC_ENDPOINT` to a phone-reachable host (`start-all.ps1` writes LAN IP into `backend/.env`).

## Verification

```powershell
cd backend
.\scripts\start-all.ps1 -SkipBuild   # or infra + this service only
curl http://localhost:8083/actuator/health
# Confirm MINIO_PUBLIC_ENDPOINT is LAN IP when testing on a physical phone
```
## GitHub Actions

`.github/workflows/file-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8083`.
