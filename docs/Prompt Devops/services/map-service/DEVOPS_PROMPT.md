# Map Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `map-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`  
**Backend spec:** `Prompt Backend/services/map-service/`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/map-service` |
| Port | `8090` |
| Image | `ghcr.io/<owner>/vithey-map-service` |
| Database | `map_db` |

## Docker Compose Output

```text
backend/services/map-service/docker-compose.yml
backend/services/map-service/.env.example
```

**Service compose containers only:** `map-service`, `map-postgres`  
**Shared infra:** `redis`, `eureka-server`, `config-server`

## Extra env

| Variable | Purpose |
| --- | --- |
| `GOOGLE_PLACES_API_KEY` | Server-restricted Places API (New) key — never bake into the image |
| `MAP_DB_URL` / username / password | PostgreSQL |
| `REDIS_HOST` / `REDIS_PORT` | Nearby/search cache |

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/map-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8090/actuator/health
```

Gateway check (after api-gateway is up): `GET http://localhost:8080/api/v1/places/nearby?lat=11.5564&lng=104.9282` with Bearer token.

## GitHub Actions

`.github/workflows/map-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8090` (same style as other service workflows).
