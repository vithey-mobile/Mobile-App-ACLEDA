# Prompt 1 of 3 — Create map-service

Copy everything below the line into a **new chat**. Do not start Prompt 2 until this is merged.

---

You are a Spring Boot backend agent in the Vithey repo. **Create the missing `map-service`.** Do not rewrite existing services. Do not write Flutter. Do not implement Google OAuth.

## Why this service exists

Flutter Map needs nearby shops around a search center (GPS or a picked place). Today the app calls Photon/Komoot from the phone. Vithey must proxy **Google Places API (New)** on the server so the Google key never ships in the APK.

## Read first (in this order)

1. `prompt/Prompt Backend/LEARNING.md`
2. `prompt/Prompt Backend/COMMON_CONTEXT.md`
3. `prompt/Prompt Backend/SERVICE_BLUEPRINT.md`
4. `prompt/Prompt Frontend/api-intergration/integration-contract.md`
5. `prompt/_shared/SERVICE_REGISTRY.md`
6. `prompt/Prompt Backend/_shared/ENV_VARS.md`
7. Then every file in `prompt/Prompt Backend/services/map-service/` in this order:
   - `KICKOFF_PROMPT.md`
   - `COMMON_CONTEXT.md`
   - `API_ENDPOINTS.md`
   - `FOLDER_STRUCTURE.md`
   - `SERVICE_LOGIC.md`
   - `DB_SCHEMA.md`
   - `SERVICE_PROMPT.md` (**authoritative**)

Copy patterns from an existing complete service (prefer `file-service` or `user-profile-service`): `pom.xml`, `SecurityConfig`, `JacksonConfig` snake_case, `GlobalExceptionHandler`, `ApiResponseWrapper`, `CurrentUser` / `X-User-Id` filter, `Dockerfile`, `docker-compose.yml`, `.env.example`.

## Identity (do not invent others)

| Item | Value |
|------|-------|
| Path | `backend/services/map-service/` |
| Port | `8090` |
| Eureka | `map-service` |
| DB | `map_db` |
| Package | `com.vithey.map` |
| Gateway | `/api/v1/places/**` → `lb://map-service` |

## Implement (all of this)

### 1. Java module

Create `backend/services/map-service/` exactly as `FOLDER_STRUCTURE.md` + `SERVICE_PROMPT.md`.

Must include:

- `MapServiceApplication` with `@EnableDiscoveryClient`
- Security that permits `/actuator/**`, `/swagger-ui/**`, `/v3/api-docs/**`; all `/api/v1/**` require `X-User-Id` (same pattern as other domain services)
- Flyway `V1__init_map_schema.sql` from `DB_SCHEMA.md`
- Redis cache: nearby/search 5 min, detail 24 h; round lat/lng to 4 decimals in cache keys
- `GooglePlacesClient` via WebClient → Places API **New** (`places.googleapis.com`)
- Resilience4j circuit breaker on Google calls → `UPSTREAM_ERROR` 502/503
- Haversine `distance_m`, category map, filters (`open_now`, `min_rating`, `price_level`)
- Favorites unique `(user_id, google_place_id)`; history trim to 20
- OpenAPI title `Vithey Map API`, `bearerAuth`, Swagger at `/swagger-ui.html`
- Tests listed in `SERVICE_PROMPT.md` (mock WebClient; do not call real Google in CI)

**v1 do not build:** photo proxy, RabbitMQ, OpenFeign peers, `place_snapshots` table, Add Place backend.

### 2. Wire the monorepo so it can boot

| File | Change |
|------|--------|
| `backend/pom.xml` | Add `<module>services/map-service</module>` |
| `backend/infrastructure/scripts/init-databases.sql` | `CREATE DATABASE map_db;` |
| `backend/infrastructure/config-repo/map-service.yml` | port 8090, `map_db`, Redis, `GOOGLE_PLACES_API_KEY` placeholder |
| `backend/infrastructure/config-repo/api-gateway.yml` | Order 0: `/api/v1/places/**` → `lb://map-service` |
| `backend/services/api-gateway/src/main/resources/application.yml` | Same places route (keep in sync with config-repo) |

Rate limits (if the gateway already supports per-route limits): nearby/search 30/min per user, autocomplete 60/min. If not already supported, document in comments and use the global limiter.

Env: `GOOGLE_PLACES_API_KEY` (already in `_shared/ENV_VARS.md`). Add it to `backend/services/map-service/.env.example`. Never commit a real key.

### 3. Compose (service-local only)

`docker-compose.yml` + `Dockerfile` like other services:

- Containers: `map-service` + `map-postgres` only
- Join external network `vithey-network`
- Shared infra: Redis, Eureka, Config Server — **do not** start those again

### 4. Docs you may touch

Update only if the Java paths differ from the spec (they should not):

- Keep `prompt/Prompt Backend/services/map-service/*` as the spec
- Do **not** edit Flutter in this chat
- Integration-contract + DevOps index are **Prompt 3**

## API you must ship (all JWT)

| Method | Path |
|--------|------|
| GET | `/api/v1/places/nearby?lat=&lng=&radius_m=&category=&open_now=&min_rating=&price_level=&page_token=&limit=` |
| GET | `/api/v1/places/search?query=&lat=&lng=&…` |
| GET | `/api/v1/places/autocomplete?input=&lat=&lng=` |
| GET | `/api/v1/places/{googlePlaceId}` |
| GET/POST | `/api/v1/places/favorites` |
| DELETE | `/api/v1/places/favorites/{googlePlaceId}` |
| GET/DELETE | `/api/v1/places/history` |

JSON shapes: `SERVICE_PROMPT.md` (nearby envelope with `places[]`, detail, autocomplete). Envelope + snake_case like every other service.

Without a Google key, nearby/search/detail/autocomplete return `UPSTREAM_ERROR` 502 (or empty + documented mock **only** if `vithey.map.use-stub=true` in `dev`). Prefer real client + mock in tests.

## Stop when

- `mvn -pl services/map-service -am clean verify` passes
- Module is in parent POM; `map_db` is in init SQL; config-repo + gateway have the places route
- Swagger: `http://localhost:8090/swagger-ui.html`
- Print a short file list and how to start infra + this service

Do not upgrade auth/content/notification. That is Prompt 2.
