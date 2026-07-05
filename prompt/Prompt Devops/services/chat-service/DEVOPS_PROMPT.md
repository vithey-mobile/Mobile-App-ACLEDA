# Chat Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `chat-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/chat-service` |
| Port | `8087` |
| Image | `ghcr.io/<owner>/vithey-chat-service` |
| Database | `chat_db` |

## Docker Compose Output

Create:

```text
vithey-backend/services/chat-service/docker-compose.yml
vithey-backend/services/chat-service/.env.example
```

Required containers:

- `chat-service`
- `chat-postgres`
- `chat-redis`
- `chat-rabbitmq`
- `chat-eureka-server`
- `chat-config-server`

Expose WebSocket endpoint `/ws/chat` on port `8087`.

Verification:

```bash
cd vithey-backend/services/chat-service
docker compose up -d --build
curl http://localhost:8087/actuator/health
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/chat-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8087`, and validate `services/chat-service/docker-compose.yml`.

