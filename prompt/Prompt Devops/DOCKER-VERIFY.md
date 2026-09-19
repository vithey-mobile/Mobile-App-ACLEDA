# Vithey Docker verification (Profile M)

Run after starting the stack.

```powershell
cd backend
.\scripts\verify-docker.ps1
```

## Expected healthy stack

| Layer | Containers |
| --- | --- |
| Infrastructure | eureka, config, postgres, redis, rabbitmq, minio |
| Services | auth, user-profile, file, content, career, finance, chat, notification, api-gateway, ai-service |
| Demo optional | map-service, ai-core (via `docker-up-demo.ps1`) |

GDCE / `general-service` / Qdrant are **not** part of Profile M. Vithey AI chat uses stub mode.

## Start order

**Full Java stack:** `.\scripts\docker-up.ps1`  
**Profile M demo (map + ai_core):** `.\scripts\docker-up-demo.ps1`  
**Stop demo:** `.\scripts\docker-down-demo.ps1`

See also `backend/DOCKER.md` and `backend/DEMO.md`.

## Common fixes

| Problem | Fix |
| --- | --- |
| Gateway unhealthy | Ensure Redis + Eureka are up; wait for service registration |
| file-service exited | Check MinIO health; rebuild file-service |
| notification exited | Empty `FIREBASE_CREDENTIALS_PATH` is OK (push disabled) |
| map / ai_core SKIP | Start demo overlay: `.\scripts\docker-up-demo.ps1` |
| Flyway checksum mismatch | See Flyway recovery in `DEMO.md` (`docker-down-demo.ps1 -v` or repair history) |
| Name conflict | `docker ps -a` then `docker rm -f <name>` |
| `vithey-network` not found | Start full stack or `infrastructure/` first |
| AI CV 502 from Docker | Confirm `AI_CORE_BASE_URL=http://ai-core:8100` when ai-core is in Compose |
