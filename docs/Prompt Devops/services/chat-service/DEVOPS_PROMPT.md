# Chat Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `chat-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/chat-service` |
| Port | `8087` |
| Image | `ghcr.io/<owner>/vithey-chat-service` |
| Database | `chat_db` |

## Docker Compose Output

```text
backend/services/chat-service/docker-compose.yml
backend/services/chat-service/.env.example
```

**Service compose containers only:**

- `chat-service`
- `chat-postgres`

**Shared infra:** `redis`, `rabbitmq`, `eureka-server`, `config-server`

Expose REST on port `8087`. WebSocket STOMP at `/ws/chat` (clients use gateway `ws://localhost:8080/ws`).

**Redis is required** for presence, typing, and message hot cache — not optional.

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/chat-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8087/actuator/health
docker compose down
```

## GitHub Actions Output

```text
.github/workflows/chat-service-ci.yml
```

CI: Maven test, Docker build `SERVICE_PORT=8087`, validate compose file.
