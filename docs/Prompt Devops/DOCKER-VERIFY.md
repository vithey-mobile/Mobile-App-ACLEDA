# Vithey Docker verification

Run after starting the stack.

```powershell
cd backend
.\scripts\verify-docker.ps1
# optional API smoke:
.\scripts\smoke-api.ps1
```

## Expected healthy stack

| Layer | Containers |
| --- | --- |
| Infrastructure | eureka-server, config-server, postgres, redis, rabbitmq, minio |
| Java services | auth, user-profile, file, content, career, finance, chat, notification, api-gateway |
| AI | **ai-core** (Python, `:8100`) — chat stub by default, CV via DeepSeek/OpenRouter when keyed |
| Optional | map-service (Compose profile `map`) |

Java `ai-service` / GDCE / `general-service` / Qdrant are **not** part of the current stack.

## Start order (current)

| Goal | Command |
| --- | --- |
| **Preferred full stack** | `.\scripts\start-all.ps1` |
| Skip rebuild | `.\scripts\start-all.ps1 -SkipBuild` |
| Infra only | `.\scripts\start-all.ps1 -InfraOnly` |
| Lean / Profile M demo | `.\scripts\docker-up-demo.ps1` |
| Demo + map | `.\scripts\docker-up-demo.ps1 -Profiles map` |
| Stop | `.\scripts\start-all.ps1 -Down` |

`start-all.ps1` also:

1. Detects LAN IPv4 and writes `MINIO_PUBLIC_ENDPOINT=http://<LAN>:19000` into `backend/.env`
2. Syncs `vithey_app/.env` → `API_BASE_URL` / `WS_BASE_URL` to that LAN IP (skip with `-SkipFlutterEnv`)
3. Force-recreates `file-service` so presigned media URLs work on a physical phone

See also `backend/DOCKER.md` and `backend/DEMO.md`.

## Common fixes

| Problem | Fix |
| --- | --- |
| Gateway unhealthy | Ensure Redis + Eureka are up; wait for service registration |
| file-service exited | Check MinIO health (`quay.io/minio/minio`); rebuild file-service |
| Images show placeholder on phone | `MINIO_PUBLIC_ENDPOINT` must be LAN IP, not `localhost` — re-run `start-all.ps1` |
| notification exited | Empty `FIREBASE_CREDENTIALS_PATH` is OK (push disabled) |
| map / places 503 | Start with map profile: `.\scripts\docker-up-demo.ps1 -Profiles map` |
| Flyway checksum mismatch | Wipe volumes (`docker compose down -v`) or repair history — see `DEMO.md` |
| Name conflict | `docker ps -a` then `docker rm -f <name>` |
| `vithey-network` not found | Start full stack or `infrastructure/` first |
| AI 502 from Docker | Confirm gateway routes to `http://ai-core:8100` and container `vithey-ai-core` is healthy |
| Old `vithey-ai-service` lingering | `docker rm -f vithey-ai-service` and `docker compose up -d --remove-orphans` |
