# Vithey Backend — Docker

Three ways to run the stack. Prefer the **full stack** or **Profile M demo** for end-to-end work.

## Layout

```
backend/
  docker-compose.yml              # full Java stack + infra
  docker-compose.demo.yml         # Profile M overlay (map + ai_core + mem caps)
  DEMO.md                         # demo prerequisites and smoke
  infrastructure/docker-compose.yml   # infra-only (legacy / incremental)
  services/<name>/
    Dockerfile
    docker-compose.yml            # single-service incremental run
    .env.example
```

## Option A — Full Java stack

From `backend/`:

```powershell
.\scripts\docker-up.ps1
# or: docker compose -f docker-compose.yml up -d --build
```

Stops with `.\scripts\docker-down.ps1`.

Includes Postgres, Redis, RabbitMQ, MinIO, Eureka, Config Server, all Java microservices, and the API gateway. Does **not** include `map-service` or `ai_core` (gateway `/places/**` returns 503 until map is added via demo overlay).

## Option B — Profile M demo (recommended for Flutter live API)

Adds `map-service`, `ai-core`, JVM memory caps, and stub AI chat (no GDCE):

```powershell
.\scripts\docker-up-demo.ps1
.\scripts\docker-down-demo.ps1
# Pass -v on down to wipe volumes (Flyway / DB reset)
```

Details: [DEMO.md](DEMO.md). Smoke: `.\scripts\smoke-api.ps1`.

`ai-service` defaults to `AI_CORE_BASE_URL=http://ai-core:8100`. For host-run ai_core, override with `http://host.docker.internal:8100`.

## Option C — One service at a time

Infra once:

```powershell
cd backend/infrastructure
docker compose up -d
```

Then from a service folder (or helper script):

```powershell
cd backend
.\scripts\docker-build-service.ps1 auth-service -Up
```

Available names: `auth-service`, `user-profile-service`, `file-service`, `content-service`, `career-service`, `finance-service`, `chat-service`, `notification-service`, `ai-service`, `map-service`, `api-gateway`, `eureka-server`, `config-server`.

Maven build context remains the backend monorepo root (`context: .` or `../..` depending on compose file).

## Port map

| Service | Host port |
|---------|-----------|
| API Gateway | 8080 |
| auth | 8081 |
| user-profile | 8082 |
| file | 8083 |
| content | 8084 |
| career | 8085 |
| finance | 8086 |
| chat | 8087 |
| notification | 8088 |
| ai-service | 8089 |
| map-service (demo) | 8090 |
| ai_core (demo) | 8100 |
| Eureka | 8761 |
| Config Server | 8888 |
| PostgreSQL | 15432 |
| Redis | 16379 |
| RabbitMQ / management | 5672 / 15672 |
| MinIO API / console | 19000 / 19001 |

## Health & verify

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
```

## Notes

- Network: `vithey-network`
- Spring profile: `docker` via each `services/*/ .env.example`
- Config repo is embedded in the `config-server` image
- Monitoring stack (`../monitoring`) is separate; cAdvisor uses host **8095** so it does not clash with map **8090**

See `TESTING.md`, `DEMO.md`, and `infrastructure/.env.example`.
