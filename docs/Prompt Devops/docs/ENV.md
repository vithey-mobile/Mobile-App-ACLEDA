# Environment Variables

## Compose / start-all (root)

Written or read from `backend/.env` (Compose auto-loads it). `start-all.ps1` maintains `MINIO_PUBLIC_ENDPOINT`.

| Variable | Purpose |
| --- | --- |
| `MINIO_PUBLIC_ENDPOINT` | Browser/phone-reachable MinIO API base, e.g. `http://192.168.x.x:19000`. Must **not** be `localhost` when testing on a physical device. |
| `DEEPSEEK_API_KEY` | Optional; passed through to `ai_core` for live CV generation |
| `DEEPSEEK_BASE_URL` / `DEEPSEEK_MODEL` | Optional model overrides for `ai_core` |
| `VITHEY_JWT_SECRET` | Shared JWT secret (auth, gateway, ai_core) |
| `SERVICE_JAVA_OPTS` / `SERVICE_MEM_LIMIT` | Lean demo JVM caps (see `backend/.env.example`) |
| `COMPOSE_PROFILES` | e.g. `map` to include map-service |

## Auth Service

Defined in `backend/services/auth-service/.env.example`.

| Variable | Purpose |
| --- | --- |
| `SERVER_PORT` | Auth service HTTP port, default `8081`. |
| `SPRING_PROFILES_ACTIVE` | Use `docker` for Docker Compose. |
| `CONFIG_SERVER_URL` | Config Server URL inside Compose. |
| `EUREKA_CLIENT_ENABLED` | Enables Eureka registration in Docker. |
| `EUREKA_URL` | Eureka service URL. |
| `AUTH_DB_URL` | PostgreSQL JDBC URL. |
| `AUTH_DB_USERNAME` | PostgreSQL username. |
| `AUTH_DB_PASSWORD` | PostgreSQL password. |
| `RABBITMQ_HOST` | RabbitMQ hostname. |
| `RABBITMQ_PORT` | RabbitMQ AMQP port. |
| `RABBITMQ_USERNAME` | RabbitMQ username. |
| `RABBITMQ_PASSWORD` | RabbitMQ password. |
| `VITHEY_JWT_SECRET` | Shared JWT signing secret for auth and gateway. |
| `VITHEY_ACCESS_TOKEN_TTL` | Access token TTL, default `15m`. |
| `VITHEY_REFRESH_TOKEN_TTL` | Refresh token TTL, default `7d`. |
| `VITHEY_EVENTS_EXCHANGE` | RabbitMQ topic exchange name. |

## File Service (media URLs)

| Variable | Purpose |
| --- | --- |
| `MINIO_ENDPOINT` | Internal Docker URL, usually `http://minio:9000` |
| `MINIO_PUBLIC_ENDPOINT` | Overridden by Compose from `backend/.env` (LAN IP from `start-all.ps1`) |
| `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | Default local `minioadmin` / `minioadmin` |
| `MINIO_BUCKETS` | `avatars,cvs,posters,videos` |

## ai_core (Python)

Optional `ai_core/.env`:

| Variable | Purpose |
| --- | --- |
| `DEEPSEEK_API_KEY` | Required for live CV generate |
| `AI_CHAT_MODE` | Default `stub` (no GDCE) |
| `DATABASE_URL` | Postgres `ai_db` |
| `VITHEY_JWT_SECRET` | Must match auth/gateway |

## Flutter (`vithey_app/.env`)

Synced partially by `start-all.ps1` (`API_BASE_URL`, `WS_BASE_URL`).

| Variable | Purpose |
| --- | --- |
| `API_BASE_URL` | Gateway REST base, e.g. `http://<host>:8080/api/v1` |
| `WS_BASE_URL` | Gateway WS base, e.g. `ws://<host>:8080/ws` |
| `USE_MOCK_*` | Per-domain mocks — keep `false` for live Docker |
| `ENABLE_GOOGLE_AUTH` | Shows Google button; backend Google config may still be placeholder |
| `USE_AI_CV` / `USE_AI_FEED` / `USE_AI_SKILLS` / `USE_AI_JOB_MATCH` | Feature gates for AI surfaces |
| `FCM_ENABLED` | Push; local default `false` |

## Other services

Each service documents its variables in `backend/services/<service>/.env.example`.
