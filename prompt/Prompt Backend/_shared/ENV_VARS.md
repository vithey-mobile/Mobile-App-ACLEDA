# Vithey Backend — Environment Variables

> **Never commit production secrets.** Use Docker secrets, CI variables, or a vault. Local dev may use `.env.example` defaults.

## Required in production (`SPRING_PROFILES_ACTIVE=prod`)

| Variable | Used by | Description |
|----------|---------|-------------|
| `VITHEY_JWT_SECRET` | auth, gateway, all secured services | Min 256-bit secret for JWT sign/verify |
| `CONFIG_SERVER_URL` | all domain services | e.g. `http://config-server:8888` |
| `EUREKA_URL` | all Eureka clients | e.g. `http://eureka-server:8761/eureka/` |

## Database (per service)

| Variable | Service |
|----------|---------|
| `AUTH_DB_URL`, `AUTH_DB_USERNAME`, `AUTH_DB_PASSWORD` | auth-service |
| `USER_DB_URL`, ... | user-profile-service |
| `FILE_DB_URL`, ... | file-service |
| `CONTENT_DB_URL`, ... | content-service |
| `CAREER_DB_URL`, ... | career-service |
| `FINANCE_DB_URL`, ... | finance-service |
| `CHAT_DB_URL`, ... | chat-service |
| `NOTIFICATION_DB_URL`, ... | notification-service |
| `AI_DB_URL`, ... | ai-service |

## Infrastructure

| Variable | Default (local) | Purpose |
|----------|-----------------|---------|
| `RABBITMQ_HOST` | localhost | Event bus |
| `RABBITMQ_PORT` | 5672 | |
| `RABBITMQ_USERNAME` | guest | |
| `RABBITMQ_PASSWORD` | guest | |
| `REDIS_HOST` | localhost | Gateway rate limit, chat presence |
| `REDIS_PORT` | 6379 | |
| `MINIO_ENDPOINT` | http://localhost:9000 | file-service |
| `MINIO_ACCESS_KEY` | — | file-service |
| `MINIO_SECRET_KEY` | — | file-service |
| `VITHEY_EVENTS_EXCHANGE` | vithey.events | RabbitMQ exchange name |

## Gateway

| Variable | Default | Purpose |
|----------|---------|---------|
| `VITHEY_GATEWAY_RATE_LIMIT_REPLENISH` | 100 | Tokens per second |
| `VITHEY_GATEWAY_RATE_LIMIT_BURST` | 100 | Burst capacity |
| `VITHEY_GATEWAY_RATE_LIMIT_TOKENS` | 1 | Tokens per request |
| `VITHEY_CORS_ALLOWED_ORIGINS` | * | CORS (restrict in prod) |

## Optional integrations

| Variable | Service | Purpose |
|----------|---------|---------|
| `FCM_CREDENTIALS_PATH` | notification-service | Firebase push |
| `OPENAI_API_KEY` | ai-service | AI provider |
| `EUREKA_CLIENT_ENABLED` | all | `false` for standalone tests |

## Config Server

| Variable | Purpose |
|----------|---------|
| `CONFIG_REPO_LOCATION` | `file:/app/config-repo` in Docker |
| `SPRING_PROFILES_ACTIVE` | `dev` (optional config) / `prod` (required config) |

## Local vs production

| Concern | Local (`dev`) | Production (`prod`) |
|---------|---------------|---------------------|
| Config import | `optional:configserver:...` | `configserver:...` (required) |
| JWT secret | dev default allowed | **must** set `VITHEY_JWT_SECRET` |
| Metrics | `/actuator/prometheus` | scraped by Prometheus |

See `monitoring/` for observability stack and `backend/infrastructure/.env.example` for Docker infra.
