# GLM 5.3 Flash — Terminal 10 / 10 — map-service (CREATE)

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. You are the **only** chat allowed to touch shared wiring files.

---

You are GLM 5.3 Flash on Vithey App. **Create `map-service`.** There is no Java folder yet. Do not rewrite other domain services. Do not write Flutter.

## Read first (in order)

1. `prompt/Prompt Backend/LEARNING.md`
2. `prompt/Prompt Backend/COMMON_CONTEXT.md`
3. `prompt/Prompt Backend/SERVICE_BLUEPRINT.md`
4. `prompt/Prompt Backend/services/map-service/KICKOFF_PROMPT.md`
5. `prompt/Prompt Backend/services/map-service/COMMON_CONTEXT.md`
6. `prompt/Prompt Backend/services/map-service/API_ENDPOINTS.md`
7. `prompt/Prompt Backend/services/map-service/FOLDER_STRUCTURE.md`
8. `prompt/Prompt Backend/services/map-service/SERVICE_LOGIC.md`
9. `prompt/Prompt Backend/services/map-service/DB_SCHEMA.md`
10. `prompt/Prompt Backend/services/map-service/SERVICE_PROMPT.md` (**authoritative**)

Copy patterns from `backend/services/file-service/` or `user-profile-service/` (`pom.xml`, Security, Jackson snake_case, `ApiResponseWrapper`, `X-User-Id` filter, Dockerfile, compose).

## Identity

Port **8090** · Eureka `map-service` · DB `map_db` · package `com.vithey.map`  
Gateway prefix: `/api/v1/places/**`

## Allowed paths (this terminal only)

```text
backend/services/map-service/**
prompt/Prompt Backend/services/map-service/**
backend/pom.xml                          # add <module>services/map-service</module> only
backend/infrastructure/scripts/init-databases.sql   # CREATE DATABASE map_db; only
backend/infrastructure/config-repo/map-service.yml  # new file
backend/infrastructure/config-repo/api-gateway.yml  # add /api/v1/places/** → lb://map-service
backend/services/api-gateway/src/main/resources/application.yml  # same places route only
```

Do **not** edit other services’ Java. Do **not** edit `integration-contract.md` (later pass). Do **not** implement Google OAuth or Add Place backend.

## Implement

1. Full module per `FOLDER_STRUCTURE.md` + `SERVICE_PROMPT.md`
2. Flyway `V1__init_map_schema.sql`
3. WebClient → Google Places API **New**; key `GOOGLE_PLACES_API_KEY`; never log the key
4. Redis cache: nearby/search 5 min, detail 24 h
5. Resilience4j on Google → `UPSTREAM_ERROR` 502/503
6. Favorites + history (trim 20)
7. Dockerfile + `docker-compose.yml` (`map-service` + `map-postgres` only, network `vithey-network`)
8. `.env.example` with `GOOGLE_PLACES_API_KEY=`

Endpoints (all JWT): nearby, search, autocomplete, `GET /places/{id}`, favorites CRUD, history GET/DELETE. JSON shapes in `SERVICE_PROMPT.md`.

v1 skip: photo proxy, RabbitMQ, OpenFeign, `place_snapshots`.

## Verify

`mvn -pl services/map-service -am clean verify` from `backend/`

Print files changed + how to start on 8090. Stop.
