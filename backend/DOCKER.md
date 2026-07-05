# Vithey Backend — Docker (Full Stack)

One command to run infrastructure + all Java microservices.

## Prerequisites

- Docker Desktop with Compose v2
- At least **8 GB RAM** allocated to Docker (full stack builds 11 images)
- Port **8080** free (stop other apps using it, e.g. ERPNext)

## Quick start

```powershell
cd "D:\project\Acleda Mobile App\backend"
copy .env.example .env
docker compose up -d --build
```

First build takes several minutes (Maven inside each Dockerfile).

## What starts

| Layer | Services |
| --- | --- |
| Infrastructure | postgres, redis, rabbitmq, minio, eureka-server, config-server |
| Domain | auth, user-profile, file, content, career, finance, chat, notification |
| Gateway | api-gateway |

All services use **one shared Postgres** (`postgres:5432`) with databases from `infrastructure/scripts/init-databases.sql`.

## URLs

| Service | URL |
| --- | --- |
| API Gateway | http://localhost:${GATEWAY_PORT:-8080} |
| Eureka | http://localhost:8761 |
| Config Server | http://localhost:8888 |
| RabbitMQ UI | http://localhost:15672 (guest/guest) |
| MinIO Console | http://localhost:9001 (minioadmin/minioadmin) |
| Auth Swagger | http://localhost:8081/swagger-ui.html |

## Verify

```powershell
docker compose ps
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8761/actuator/health
```

Check Eureka dashboard for registered services: AUTH-SERVICE, API-GATEWAY, etc.

## Stop

```powershell
docker compose down
```

Remove all data:

```powershell
docker compose down -v
```

## Per-service compose (still available)

Each service under `services/<name>/docker-compose.yml` can run independently with its own Postgres for isolated dev. The root `docker-compose.yml` is for **full stack** only.

## Python AI / chatbot (separate)

AI is **not** in this compose. After Java stack is up:

1. Start your Python `ai-service` (port 8089, Eureka name `ai-service`)
2. Join `vithey-network` — see `services/ai-service/INTEGRATION.md`

Optional GDCE stack on `gdce-network`:

```powershell
cd "D:\GDCE-chatbot\chatbot_review\backend\api-layer\scripts"
.\start-development.ps1 -SkipBuild
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Port 8080 in use | `docker ps` — stop conflicting container |
| Service unhealthy | `docker logs vithey-auth-service` (replace service name) |
| Postgres connection refused | Wait for `vithey-postgres` healthy; first start runs init SQL |
| Gateway UP but 503 on routes | Wait 1–2 min for all services to register in Eureka |
| Out of memory during build | Increase Docker RAM; build one service: `docker compose build auth-service` |

## Build single service

```powershell
docker compose build auth-service
docker compose up -d auth-service
```

## Flutter emulator

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1   # Android emulator
API_BASE_URL=http://localhost:8080/api/v1  # iOS simulator
```
