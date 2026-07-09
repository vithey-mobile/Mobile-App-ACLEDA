# Vithey Backend — Docker (Per-Service)

Each folder has its own `docker-compose.yml`. Docker Desktop shows separate projects (`infrastructure`, `auth-service`, `api-gateway`, etc.) instead of one combined stack.

## Prerequisites

- Docker Desktop with Compose v2
- At least **8 GB RAM** allocated to Docker
- Ports free: 8080 (gateway), 8761, 8888, 5432, 6379, 5672, 9000-9001

## Quick start (all services)

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\start-all.ps1
```

First build takes several minutes (Maven inside each Dockerfile).

## Manual start (one folder at a time)

### 1. Shared infrastructure (required first)

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
copy .env.example .env
docker compose up -d --build
```

Creates `vithey-network` and starts:

| Service | URL |
| --- | --- |
| Eureka | http://localhost:8761 |
| Config Server | http://localhost:8888 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |
| RabbitMQ UI | http://localhost:15672 (guest/guest) |
| MinIO Console | http://localhost:9001 (minioadmin/minioadmin) |

### 2. One business service

```powershell
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
copy .env.example .env
docker compose up -d --build
```

Repeat from each `services/<name>/` folder. Start **api-gateway** last.

## Service folders

| Folder | Port | Includes |
| --- | --- | --- |
| `infrastructure/` | — | postgres, redis, rabbitmq, minio, eureka, config |
| `services/auth-service/` | 8081 | auth-service + auth-postgres |
| `services/user-profile-service/` | 8082 | user-profile-service + profile-postgres |
| `services/file-service/` | 8083 | file-service + file-postgres |
| `services/content-service/` | 8084 | content-service + content-postgres |
| `services/career-service/` | 8085 | career-service + career-postgres |
| `services/finance-service/` | 8086 | finance-service + finance-postgres |
| `services/chat-service/` | 8087 | chat-service + chat-postgres |
| `services/notification-service/` | 8088 | notification-service + notification-postgres |
| `services/ai-service/` | 8089 | ai-service + ai-postgres |
| `services/api-gateway/` | 8080 | api-gateway |

Full registry (build order, shared infra deps, screen map): `_shared/SERVICE_REGISTRY.md`.

## Verify

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8761/actuator/health

cd services/auth-service
docker compose ps
```

Check Eureka dashboard for registered services: AUTH-SERVICE, API-GATEWAY, etc.

## Stop

Stop everything (reverse order):

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\start-all.ps1 -Down
```

Stop one folder:

```powershell
cd services/auth-service
docker compose down
```

Remove shared data:

```powershell
cd infrastructure
docker compose down -v
```

## Helper script options

```powershell
.\scripts\start-all.ps1              # build and start all folders
.\scripts\start-all.ps1 -SkipBuild   # start without rebuild
.\scripts\start-all.ps1 -Logs        # tail logs from each folder
.\scripts\start-all.ps1 -Down        # stop all folders
```

## Python AI / chatbot (optional)

`services/ai-service/` is included in `start-all.ps1`. It also joins `gdce-network` when present (created automatically by the script if missing).

See `Prompt Backend/services/ai-service/INTEGRATION.md` for external AI provider setup.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `vithey-network` not found | Start `infrastructure/` first |
| Port 8080 in use | Change `SERVER_PORT` in `services/api-gateway/.env` and port mapping in compose |
| Service unhealthy | `cd services/<name>` then `docker compose logs` |
| Gateway UP but 503 on routes | Wait 1-2 min for services to register in Eureka |
| Out of memory during build | Increase Docker RAM; build one folder: `cd services/auth-service; docker compose build` |

## Flutter emulator

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1   # Android emulator
API_BASE_URL=http://localhost:8080/api/v1  # iOS simulator
```
