# Map Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> map-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

Location-aware **shop / place discovery** for Vithey users:

- Search places **near the user’s GPS coordinates**
- Support **text keyword search** with location bias
- Apply **filters** (category, radius, open now, rating, price level)
- Return map-friendly markers + list cards
- Optional: **favorites** and **recent searches** per user

Integrates with **Google Places API (New)** server-side. The Flutter app only talks to Vithey APIs and renders Google Maps UI with the returned coordinates.

## Identity

| Item         | Value                    |
| ------------ | ------------------------ |
| Eureka name  | `map-service`            |
| Port         | 8090                     |
| Database     | `map_db` (PostgreSQL 16) |
| Cache        | Redis (nearby/search TTL cache) |
| Base package | `com.vithey.map`         |

## External dependency

| Provider | Purpose |
| -------- | ------- |
| Google Places API (New) | Nearby Search, Text Search, Place Details, Autocomplete |
| Google Maps (client-only) | Flutter Map widget — **not** owned by this service |

Env: `GOOGLE_PLACES_API_KEY` (see `_shared/ENV_VARS.md`). Prefer a **server-restricted** key (IP / VPC), separate from any Android/iOS Maps SDK key.

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `PlaceFavorite`

| Field         | Type      | Notes                                      |
| ------------- | --------- | ------------------------------------------ |
| `id`          | UUID      | PK                                         |
| `userId`      | UUID      | owner (`X-User-Id`)                        |
| `googlePlaceId` | String  | Google `places/{place_id}` or raw place id |
| `name`        | String    | snapshot at save time                      |
| `address`     | String    | nullable snapshot                          |
| `latitude`    | DOUBLE    | snapshot                                   |
| `longitude`   | DOUBLE    | snapshot                                   |
| `category`    | String    | nullable (e.g. `cafe`, `restaurant`)       |
| `photoUrl`    | String    | nullable (proxy or Google photo ref)       |
| `createdAt`   | timestamp |                                            |

> Unique (`userId`, `googlePlaceId`).

### `PlaceSearchHistory`

| Field       | Type      | Notes                                      |
| ----------- | --------- | ------------------------------------------ |
| `id`        | UUID      | PK                                         |
| `userId`    | UUID      | owner                                      |
| `query`     | String    | free-text keyword (nullable if filter-only)|
| `category`  | String    | nullable filter used                       |
| `latitude`  | DOUBLE    | search center                              |
| `longitude` | DOUBLE    | search center                              |
| `radiusM`   | INT       | radius in meters                           |
| `createdAt` | timestamp |                                            |

Keep last **N=20** per user (delete oldest on insert).

### `PlaceSnapshot` (optional cache table — v1 may use Redis only)

| Field           | Type      | Notes                          |
| --------------- | --------- | ------------------------------ |
| `googlePlaceId` | String    | PK                             |
| `payloadJson`   | jsonb     | normalized PlaceResponse       |
| `fetchedAt`     | timestamp |                                |
| `expiresAt`     | timestamp |                                |

## Events

No RabbitMQ events required for v1. Optional audit log only (no PII of query text in prod).

## Inter-Service Dependencies

| Client | Used for |
| ------ | -------- |
| —      | None for v1 (standalone). Future: UserProfileClient for “shop owned by Vithey company” enrichment |

## API Prefix (owned by this service)

`/api/v1/places/**`

## Authorization

- All endpoints require JWT (`USER` / `STUDENT` / `COMPANY` / `ADMIN`)
- Favorites and search history are **owner-only** (`X-User-Id`)
- No public anonymous Places proxy (prevents key abuse)

## Does NOT Own

- Google Maps SDK rendering → **Flutter**
- User profile `location` string → **user-profile-service**
- Job post workplace text → **content-service**
- Push notifications → **notification-service**
