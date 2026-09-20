# Vithey Backend — Docker

Prefer **`.\scripts\start-all.ps1`** for day-to-day local work. It brings up the full stack, sets MinIO’s public URL to your LAN IP, and syncs Flutter `.env`.

## Prerequisites

- Docker Desktop with Compose v2
- At least **8 GB RAM** allocated to Docker (12 GB+ recommended for full stack)
- Free ports: `8080–8088`, `8100` (ai_core), `8090` (map if enabled), `8761`, `8888`, `5672`, `15672`, `15432`, `16379`, `19000–19001`

## Quick start (preferred)

```powershell
cd backend
.\scripts\start-all.ps1
```

Useful flags:

```powershell
.\scripts\start-all.ps1 -SkipBuild      # reuse existing images
.\scripts\start-all.ps1 -InfraOnly      # postgres/redis/rabbitmq/minio/eureka/config only
.\scripts\start-all.ps1 -SkipFlutterEnv # do not rewrite vithey_app/.env
.\scripts\start-all.ps1 -Logs
.\scripts\start-all.ps1 -Down
```

Equivalents:

```powershell
docker compose up -d --build
.\scripts\docker-up.ps1
.\scripts\docker-up-demo.ps1            # lean Profile M caps
```

First build takes several minutes (Maven inside each Dockerfile).

What `start-all.ps1` does beyond compose:

| Step | Effect |
| --- | --- |
| Detect LAN IPv4 | Wi‑Fi preferred over Ethernet; skips WSL/Hyper-V/Docker adapters |
| `MINIO_PUBLIC_ENDPOINT` | Written to `backend/.env` as `http://<LAN>:19000` |
| Flutter sync | Updates `vithey_app/.env` `API_BASE_URL` + `WS_BASE_URL` to the same LAN host |
| file-service recreate | Picks up the new public MinIO URL for phone-reachable media |

## What starts

| Service | Host URL / port |
| --- | --- |
| API Gateway | http://localhost:8080 |
| Auth | http://localhost:8081 |
| User Profile | http://localhost:8082 |
| File | http://localhost:8083 |
| Content | http://localhost:8084 |
| Career | http://localhost:8085 |
| Finance | http://localhost:8086 |
| Chat | http://localhost:8087 |
| Notification | http://localhost:8088 |
| **ai_core (Python)** | http://localhost:8100 |
| map-service (opt-in) | http://localhost:8090 |
| Eureka | http://localhost:8761 |
| Config Server | http://localhost:8888 |
| PostgreSQL | localhost:15432 |
| Redis | localhost:16379 |
| RabbitMQ UI | http://localhost:15672 (guest/guest) |
| MinIO Console | http://localhost:19001 (minioadmin/minioadmin) |
| MinIO API | http://localhost:19000 |

Gateway routes `/api/v1/ai/**` → `http://ai-core:8100`. Java `ai-service` is **retired**.

MinIO image: `quay.io/minio/minio:latest`.

## Verify

```powershell
.\scripts\verify-docker.ps1
.\scripts\smoke-api.ps1
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8100/health
```

Open Eureka and confirm Java services are registered. `ai-core` is reached by direct URI (not Eureka lb).

## Infra only / one service

```powershell
.\scripts\start-all.ps1 -InfraOnly
# or:
cd infrastructure
docker compose up -d --build
```

One business service (infra must already be up on `vithey-network`):

```powershell
.\scripts\docker-build-service.ps1 auth-service -Up
```

## Env files

- Compose loads each service’s `services/<name>/.env.example`.
- Root `backend/.env` holds Compose interpolations (especially `MINIO_PUBLIC_ENDPOINT`).
- Optional `ai_core/.env` for `DEEPSEEK_API_KEY` / model overrides.

## Monitoring (optional)

```powershell
cd "..\monitoring"
copy .env.example .env
docker compose --profile monitoring up -d
```

Grafana: http://localhost:3000 — see `monitoring/README.md`.

## Flutter (emulator / phone)

| Target | `API_BASE_URL` / `WS_BASE_URL` |
| --- | --- |
| Android emulator | `http://10.0.2.2:8080/api/v1` / `ws://10.0.2.2:8080/ws` |
| Physical phone (same Wi‑Fi) | `http://<LAN-IP>:8080/api/v1` / `ws://<LAN-IP>:8080/ws` (set by `start-all.ps1`) |
| iOS simulator | `http://localhost:8080/api/v1` |

Keep mocks off for live stack:

```env
USE_MOCK_AUTH=false
USE_MOCK_API=false
USE_MOCK_CHAT=false
USE_MOCK_NOTIFICATIONS=false
USE_MOCK_SEARCH=false
USE_MOCK_AI=false
USE_MOCK_MAP=false
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Out of memory during build | Increase Docker RAM; build one image: `docker compose build auth-service` |
| Port already in use | Stop the other process or change the host port mapping |
| Service unhealthy | `docker compose logs <service>` |
| Gateway UP but 503 on routes | Wait 1–2 min for Eureka registration |
| Postgres empty / missing DBs | `docker compose down -v` then `up` again |
| MinIO pull fails (Hub rate limit) | Confirm image is `quay.io/minio/minio:latest` |
| Phone cannot load post images | Re-run `start-all.ps1` so `MINIO_PUBLIC_ENDPOINT` is LAN, not localhost |
| AI 502 | Ensure `vithey-ai-core` healthy; gateway URI `http://ai-core:8100` |
