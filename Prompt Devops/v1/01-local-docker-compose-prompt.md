# 01 - Local Docker Compose Prompt

Build **Docker Compose** files for full local development of Vithey App microservices.

## Goal
One-command local stack: infrastructure + all Spring Boot services + API Gateway.

## Depends On
- `00-foundation-prompt.md`
- Backend service code under `vithey-backend/services/`

## Must Create
```text
vithey-backend/
├── docker-compose.yml           # all-in-one (includes infra)
├── docker-compose.infra.yml       # data layer only
├── docker-compose.apps.yml        # app services only (for dev iteration)
└── docker-compose.<service>.yml   # added by prompt 06 for independent services
```

## Infrastructure Services (`docker-compose.infra.yml`)
| Service | Image | Ports | Healthcheck |
|---------|-------|-------|-------------|
| postgres | postgres:16-alpine | 5432 | `pg_isready` |
| redis | redis:7-alpine | 6379 | `redis-cli ping` |
| rabbitmq | rabbitmq:3-management-alpine | 5672, 15672 | `rabbitmq-diagnostics ping` |
| minio | minio/minio | 9000, 9001 | `mc ready` or HTTP |
| eureka-server | build ./eureka-server | 8761 | `/actuator/health` |
| config-server | build ./config-server | 8888 | `/actuator/health` |

### PostgreSQL Volume
Mount `docker/postgres/init-databases.sql` to create all databases on first start.

### MinIO
- Command: `server /data --console-address ":9001"`
- Run `create-buckets.sh` via init container or documented manual step

## Application Services (`docker-compose.apps.yml`)
Each service:
- `build: ./services/<name>` or `context` + `dockerfile`
- `env_file: .env`
- `environment:` override Spring profiles to `docker`
- `depends_on` infra with `condition: service_healthy`
- Expose port per COMMON_CONTEXT port registry
- Network: `vithey-network`

### Startup Order
```yaml
depends_on:
  eureka-server:
    condition: service_healthy
  config-server:
    condition: service_healthy
  postgres:
    condition: service_healthy
```

Gateway depends on all domain services being started (soft depends_on OK).

## Spring Docker Profile
Each service `application-docker.yml`:
```yaml
spring:
  config:
    import: optional:configserver:${CONFIG_SERVER_URL}
  datasource:
    url: jdbc:postgresql://postgres:5432/<service_db>
  rabbitmq:
    host: rabbitmq
  data:
    redis:
      host: redis
eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URL}
```

## `docker-compose.yml`
Extends or includes both infra + apps (use `include` or merge into single file).

## Developer Experience
- API entry: `http://localhost:8080`
- Eureka UI: `http://localhost:8761`
- RabbitMQ UI: `http://localhost:15672`
- MinIO Console: `http://localhost:9001`
- Per-service Swagger: `http://localhost:8081/swagger-ui.html` (auth) etc.

## Flutter Local Config
Document in `LOCAL_DEV.md`:
```env
API_BASE_URL=http://10.0.2.2:8080/api/v1   # Android emulator
API_BASE_URL=http://localhost:8080/api/v1  # iOS simulator
```

## Rules
- Use named volumes for postgres, minio, rabbitmq data.
- No production secrets in compose files — reference `.env`.
- All services on same bridge network.
- Full-stack Compose must not block independent per-service Compose from prompt `06`.

## Verification Checklist
- [ ] `docker compose up -d --build` succeeds
- [ ] Eureka shows all services REGISTERED
- [ ] `curl http://localhost:8080/actuator/health` returns UP
- [ ] `POST http://localhost:8080/api/v1/auth/register` reachable (once auth built)

## Output
Complete runnable Compose files for local development.
