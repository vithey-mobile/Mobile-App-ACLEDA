# 06 - Per-Service Docker Compose Prompt

Create **one independent Docker Compose file per business service** so each service can run and be deployed without duplicating shared infrastructure.

## Goal

Every business service has its own `docker-compose.yml` with only the service and its private dependencies.

## Read First

1. `Prompt Devops/COMMON_CONTEXT.md`
2. `Prompt Backend/SERVICE_BLUEPRINT.md`
3. `Prompt Backend/services/<service>/KICKOFF_PROMPT.md`
4. `Prompt Backend/services/<service>/FOLDER_STRUCTURE.md`
5. `Prompt Backend/services/<service>/DB_SCHEMA.md`
6. `Prompt Devops/services/<service>/DEVOPS_PROMPT.md`

## Output Pattern

```text
backend/
├── infrastructure/
│   └── docker-compose.yml
└── services/
    └── <service>/
        ├── Dockerfile
        ├── docker-compose.yml
        ├── .env.example
        └── src/
```

Registry (ports, shared infra deps): `_shared/SERVICE_REGISTRY.md`.

Examples:

```text
backend/services/auth-service/docker-compose.yml
backend/services/content-service/docker-compose.yml
backend/services/ai-service/docker-compose.yml
```

## Compose Rules

- Use Docker Compose v2 syntax.
- Shared infrastructure must already be running from `backend/infrastructure/docker-compose.yml`.
- Each service compose file must join the external network:

```yaml
networks:
  vithey-network:
    external: true
```

- Do **not** duplicate Eureka Server, Config Server, RabbitMQ, Redis, MinIO, or shared Postgres in service compose files.
- Include only the service container and service-specific database if needed.
- Use `build.context: ../..` and `dockerfile: services/<service>/Dockerfile`.
- Expose the service's real local port from backend common context.
- Include health checks for all containers in the service compose file.
- Do not commit secrets; use `.env.example` and copy to `.env` locally.

## Required Dependency Patterns

| Service | Service compose includes | Uses shared infrastructure for |
| --- | --- | --- |
| `api-gateway` | api-gateway only | redis, eureka-server, config-server |
| `auth-service` | auth-service + auth-postgres | rabbitmq, eureka-server, config-server |
| `user-profile-service` | user-profile-service + profile-postgres | rabbitmq, eureka-server, config-server |
| `file-service` | file-service + file-postgres | minio, eureka-server, config-server |
| `content-service` | content-service + content-postgres | rabbitmq, eureka-server, config-server |
| `career-service` | career-service + career-postgres | rabbitmq, eureka-server, config-server |
| `finance-service` | finance-service + finance-postgres | rabbitmq, eureka-server, config-server |
| `chat-service` | chat-service + chat-postgres | redis, rabbitmq, eureka-server, config-server |
| `notification-service` | notification-service + notification-postgres | rabbitmq, eureka-server, config-server |
| `ai-service` | ai-service + ai-postgres | redis, eureka-server, config-server |
| `map-service` | map-service + map-postgres | redis, eureka-server, config-server |

## Database Rule

Service-specific Postgres containers must create only that service database:

```text
auth-service -> auth_db
user-profile-service -> user_db
file-service -> file_db
content-service -> content_db
career-service -> career_db
finance-service -> finance_db
chat-service -> chat_db
notification-service -> notification_db
ai-service -> ai_db
map-service -> map_db
```

## Verification

Each service compose file must document:

```bash
cd backend/infrastructure
docker compose up -d --build

cd ../services/<service>
copy .env.example .env
docker compose config
docker compose up -d --build
curl http://localhost:<port>/actuator/health
docker compose down
```

## Output

Independent per-service compose files that connect to the shared infrastructure network `vithey-network`.
