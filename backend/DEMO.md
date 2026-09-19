# Vithey Demo Stack (Profile M) — local PC
#
# Prerequisites:
#   1. Docker Desktop running
#   2. Copy ai_core/.env.example → ai_core/.env and set DEEPSEEK_API_KEY
#   3. Optional: set GOOGLE_PLACES_API_KEY in services/map-service/.env.example (or a real .env)
#
# Start (from backend/):
#   .\scripts\docker-up-demo.ps1
#
# Or:
#   docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build
#
# Stop:
#   .\scripts\docker-down-demo.ps1
#
# Or:
#   docker compose -f docker-compose.yml -f docker-compose.demo.yml down
#
# Notes:
#   - All Vithey Java services + map + ai_core
#   - NO GDCE / general-service (Vithey AI chat = stub)
#   - Memory caps applied via docker-compose.demo.yml
#   - ai-service talks to ai-core at http://ai-core:8100 (override with host.docker.internal if ai_core runs on the host)
#   - Flutter: API_BASE_URL=http://10.0.2.2:8080/api/v1 (emulator) or http://<LAN-IP>:8080/api/v1
#   - Set USE_MOCK_AI=false after stack is healthy to use live CV generate + stub chat

## Health checks

| Service | URL |
|---------|-----|
| Gateway | http://localhost:8080/actuator/health |
| ai-service | http://localhost:8089/actuator/health |
| map-service | http://localhost:8090/actuator/health |
| ai_core | http://localhost:8100/health |
| Eureka | http://localhost:8761 |

## Full API smoke (recommended)

From `backend/`:

```powershell
.\scripts\smoke-api.ps1
```

Covers auth, profile, posts, AI chat/CV, student verify + fees/payments, peer chat request/accept, notifications, logout. Map history is optional until `map-service` is up.

## Flyway recovery

If `content-service` or `finance-service` fail to start with a Flyway **checksum mismatch**, the applied migration files were edited after they ran on your volume. Prefer adding a new migration version next time — do not edit applied ones.

Recovery options:

1. **Wipe local DBs** (destroys data):

```powershell
.\scripts\docker-down-demo.ps1 -v
.\scripts\docker-up-demo.ps1
```

2. **Repair checksum** in the affected database (`content_db`, `finance_db`, …) via `flyway_schema_history`, then restart the service.

## CV generate (after login)

```http
POST http://localhost:8080/api/v1/ai/cv/generate
Authorization: Bearer <access_token>
Content-Type: application/json

{ "target_role": "Software Engineer Intern", "language": "en" }
```
