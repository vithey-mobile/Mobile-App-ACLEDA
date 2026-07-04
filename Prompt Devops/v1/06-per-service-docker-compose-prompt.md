# 06 - Per-Service Docker Compose Prompt

Create **one independent Docker Compose file per backend service** so each service can run and be debugged without starting the full Vithey stack.

## Goal

Every service has its own local Compose file with only the dependencies it needs.

## Read First

1. `Prompt Devops/COMMON_CONTEXT.md`
2. `Prompt Backend/SERVICE_BLUEPRINT.md`
3. `Prompt Backend/services/<service>/KICKOFF_PROMPT.md`
4. `Prompt Backend/services/<service>/FOLDER_STRUCTURE.md`
5. `Prompt Backend/services/<service>/DB_SCHEMA.md`
6. `Prompt Devops/services/<service>/DEVOPS_PROMPT.md`

## Output Pattern

Create:

```text
vithey-backend/
├── docker-compose.<service>.yml
└── services/<service>/
    ├── Dockerfile
    └── .env.example
```

Examples:

```text
vithey-backend/docker-compose.auth-service.yml
vithey-backend/docker-compose.content-service.yml
vithey-backend/docker-compose.ai-service.yml
```

## Compose Rules

- Use Docker Compose v2 syntax.
- Each service Compose file must be runnable with:

```bash
docker compose -f docker-compose.<service>.yml up -d --build
```

- Include only required dependencies for that service.
- Use a service-specific network name: `vithey-<service>-network`.
- Use service-specific volumes to avoid clashing with full-stack local dev.
- Expose the service's real local port from backend common context.
- Include health checks for all dependency containers.
- Do not commit secrets; use `.env.example`.

## Required Dependency Patterns

| Service | Required compose dependencies |
| --- | --- |
| `api-gateway` | redis, eureka-server, config-server |
| `auth-service` | postgres, rabbitmq, eureka-server, config-server |
| `user-profile-service` | postgres, rabbitmq, eureka-server, config-server |
| `file-service` | postgres, minio, eureka-server, config-server |
| `content-service` | postgres, rabbitmq, eureka-server, config-server |
| `career-service` | postgres, rabbitmq, eureka-server, config-server |
| `finance-service` | postgres, rabbitmq, eureka-server, config-server |
| `chat-service` | postgres, redis, rabbitmq, eureka-server, config-server |
| `notification-service` | postgres, rabbitmq, eureka-server, config-server |
| `ai-service` | postgres, redis, eureka-server, config-server |
| `infrastructure` | postgres, redis, rabbitmq, minio, eureka-server, config-server |

## Database Rule

Per-service Compose may use one local Postgres container but must create only the service database:

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
```

## Verification

Each Compose file must document:

```bash
docker compose -f docker-compose.<service>.yml config
docker compose -f docker-compose.<service>.yml up -d --build
curl http://localhost:<port>/actuator/health
docker compose -f docker-compose.<service>.yml down -v
```

## Output

Independent per-service Compose files that are compatible with the full-stack Compose files from prompts `01` and `05`.

