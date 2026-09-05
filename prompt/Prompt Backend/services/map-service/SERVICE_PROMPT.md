# Map Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`, `integration-contract.md`.  
> **Scope:** Backend REST API only — nearby shop/place search via Google Places + filters + favorites.  
> **No Flutter Map UI** in this service.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/map-service/` |
| Port | 8090 |
| Eureka | `map-service` |
| Database | `map_db` |
| Cache | Redis |
| Package | `com.vithey.map` |
| Swagger | `http://localhost:8090/swagger-ui.html` |

## Spring Cloud + tools

Eureka, Config, Redis, JPA, Flyway, MapStruct, springdoc, WebClient (Google Places HTTP), Resilience4j circuit breaker on Google calls. No RabbitMQ for v1. No OpenFeign peers required for v1.

## Folder structure

```text
services/map-service/
└── src/main/java/com/vithey/map/
    ├── MapServiceApplication.java
    ├── config/
    │   ├── SecurityConfig.java
    │   ├── RedisConfig.java
    │   ├── OpenApiConfig.java
    │   └── GooglePlacesConfig.java
    ├── controller/
    │   ├── PlaceSearchController.java
    │   ├── PlaceDetailController.java
    │   ├── PlaceFavoriteController.java
    │   └── PlaceHistoryController.java
    ├── service/
    │   ├── NearbySearchService.java
    │   ├── TextSearchService.java
    │   ├── PlaceDetailService.java
    │   ├── AutocompleteService.java
    │   ├── PlaceFavoriteService.java
    │   ├── PlaceHistoryService.java
    │   └── PlaceCacheService.java
    ├── client/
    │   └── GooglePlacesClient.java          # WebClient → Places API (New)
    ├── repository/
    │   ├── PlaceFavoriteRepository.java
    │   └── PlaceSearchHistoryRepository.java
    ├── entity/PlaceFavorite.java, PlaceSearchHistory.java
    ├── dto/request/NearbySearchRequest.java, TextSearchRequest.java, SaveFavoriteRequest.java
    ├── dto/response/PlaceCardResponse.java, PlaceDetailResponse.java, PlaceMarkerResponse.java
    ├── mapper/PlaceMapper.java
    ├── filter/PlaceFilterSpec.java          # category, radius, open_now, min_rating, price
    └── exception/GlobalExceptionHandler.java
```

See `FOLDER_STRUCTURE.md`.

## Database entities

**PlaceFavorite:** `id`, `user_id`, `google_place_id`, `name`, `address`, `latitude`, `longitude`, `category`, `photo_url`, `created_at` — unique(`user_id`, `google_place_id`)

**PlaceSearchHistory:** `id`, `user_id`, `query`, `category`, `latitude`, `longitude`, `radius_m`, `created_at`

## Filters (shared query params)

Used by nearby + text search:

| Param | Type | Required | Default | Rules |
|-------|------|----------|---------|-------|
| `lat` | double | **yes** (nearby) / yes with bias (text) | — | WGS84, -90..90 |
| `lng` | double | **yes** | — | WGS84, -180..180 |
| `radius_m` | int | no | `1500` | 100–20000 |
| `query` | string | no | — | keyword, max 100 (required for text search) |
| `category` | string | no | all | see category enum below |
| `open_now` | boolean | no | — | if `true`, only currently open |
| `min_rating` | double | no | — | 1.0–5.0 |
| `price_level` | int | no | — | 0–4 (Google price levels) |
| `page_token` | string | no | — | Google pagination token |
| `limit` | int | no | `20` | 1–40 |

### Category enum (map to Google `includedTypes` / type filters)

| Vithey `category` | Google type examples |
|-------------------|----------------------|
| `restaurant` | `restaurant` |
| `cafe` | `cafe`, `coffee_shop` |
| `convenience_store` | `convenience_store` |
| `supermarket` | `supermarket`, `grocery_store` |
| `pharmacy` | `pharmacy` |
| `atm` | `atm` |
| `bank` | `bank` |
| `gas_station` | `gas_station` |
| `shopping_mall` | `shopping_mall` |
| `lodging` | `lodging` |
| `hospital` | `hospital` |
| `university` | `university` |
| `other` | omit type filter; rely on `query` |

## Complete API (all JWT)

### Search & map

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| GET | `/api/v1/places/nearby` | Shops/places around lat/lng + filters | 200 |
| GET | `/api/v1/places/search` | Text keyword search biased to lat/lng + filters | 200 |
| GET | `/api/v1/places/autocomplete` | Typeahead suggestions | 200 |
| GET | `/api/v1/places/{googlePlaceId}` | Place detail for bottom sheet / pin tap | 200 |

### User data

| Method | Path | Description | HTTP |
|--------|------|-------------|------|
| GET | `/api/v1/places/favorites` | My saved places | 200 |
| POST | `/api/v1/places/favorites` | Save place | 201 |
| DELETE | `/api/v1/places/favorites/{googlePlaceId}` | Remove favorite | 204 |
| GET | `/api/v1/places/history` | Recent searches (max 20) | 200 |
| DELETE | `/api/v1/places/history` | Clear history | 204 |

### Nearby example

`GET /api/v1/places/nearby?lat=11.5564&lng=104.9282&radius_m=2000&category=cafe&open_now=true&min_rating=4.0`

**List + markers response:**
```json
{
  "data": {
    "center": { "lat": 11.5564, "lng": 104.9282 },
    "radius_m": 2000,
    "places": [
      {
        "google_place_id": "ChIJ...",
        "name": "Brown Coffee AEON",
        "address": "Aeon Mall Phnom Penh",
        "category": "cafe",
        "latitude": 11.5501,
        "longitude": 104.9312,
        "rating": 4.5,
        "user_rating_count": 320,
        "price_level": 2,
        "open_now": true,
        "distance_m": 850,
        "photo_url": "https://...",
        "is_favorite": false
      }
    ],
    "next_page_token": null
  },
  "meta": null,
  "error": null
}
```

Flutter uses `places[]` for both **map markers** (`latitude`/`longitude`) and the **result list**.

### Text search example

`GET /api/v1/places/search?query=phone%20shop&lat=11.5564&lng=104.9282&radius_m=3000&category=other`

### Autocomplete

`GET /api/v1/places/autocomplete?input=brown&lat=11.5564&lng=104.9282`

```json
{
  "data": [
    {
      "google_place_id": "ChIJ...",
      "primary_text": "Brown Coffee",
      "secondary_text": "Aeon Mall, Phnom Penh",
      "distance_m": 850
    }
  ]
}
```

### Place detail

```json
{
  "data": {
    "google_place_id": "ChIJ...",
    "name": "Brown Coffee AEON",
    "address": "Aeon Mall Phnom Penh",
    "category": "cafe",
    "latitude": 11.5501,
    "longitude": 104.9312,
    "rating": 4.5,
    "user_rating_count": 320,
    "price_level": 2,
    "open_now": true,
    "opening_hours": ["Mon–Fri 08:00–21:00", "Sat–Sun 08:00–22:00"],
    "phone": "+855...",
    "website": "https://...",
    "google_maps_uri": "https://maps.google.com/?cid=...",
    "photo_urls": ["https://..."],
    "is_favorite": true
  }
}
```

### Save favorite

```json
{
  "google_place_id": "ChIJ...",
  "name": "Brown Coffee AEON",
  "address": "Aeon Mall Phnom Penh",
  "latitude": 11.5501,
  "longitude": 104.9312,
  "category": "cafe",
  "photo_url": "https://..."
}
```

## Business logic

| Flow | Steps |
|------|-------|
| Nearby | Validate lat/lng/filters → build Redis cache key → on miss call Google Nearby Search → normalize → apply server-side filters Google cannot do → sort by `distance_m` ASC → optionally append history → return |
| Text search | Require `query` (≥2 chars) → location bias → Google Text Search → same normalize/filter/cache |
| Autocomplete | Require `input` ≥1 → Google Autocomplete (session token optional) → return suggestions |
| Detail | Cache by `google_place_id` (TTL longer) → Google Place Details → mark `is_favorite` for current user |
| Favorite | Upsert snapshot; idempotent on unique pair |
| History | Insert row; trim to 20 per user |

### Caching

| Key pattern | TTL | Notes |
|-------------|-----|-------|
| `places:nearby:{hash}` | 5 min | hash of lat(rounded), lng, radius, category, filters |
| `places:search:{hash}` | 5 min | include query |
| `places:detail:{placeId}` | 24 h | detail payload |

Round lat/lng to **~4 decimal places** (~11 m) in cache keys to improve hit rate.

### Rate limits (gateway)

| Endpoint | Limit |
|----------|-------|
| `GET /places/nearby`, `/places/search` | 30 req/min per `X-User-Id` |
| `GET /places/autocomplete` | 60 req/min per `X-User-Id` |

### Google client rules

- Use Places API **New** REST (`places.googleapis.com`)
- Field masks: request only needed fields (cost control)
- Map circuit breaker → `UPSTREAM_ERROR` 502 when Google is down
- Never log full API key; redact in errors
- Photo: either return Google photo name for client Maps SDK, or proxy via short-lived signed URL endpoint (optional v1.1: `GET /api/v1/places/{id}/photo`)

## Errors

| Case | Code | HTTP |
|------|------|------|
| Missing/invalid lat/lng, bad filter | `VALIDATION_ERROR` | 400 |
| Query &lt; 2 chars on `/search` | `VALIDATION_ERROR` | 400 |
| Missing JWT | `UNAUTHORIZED` | 401 |
| Favorite not found | `NOT_FOUND` | 404 |
| Place not found at Google | `NOT_FOUND` | 404 |
| Google quota / upstream failure | `UPSTREAM_ERROR` | 502 |
| Circuit open | `UPSTREAM_ERROR` | 503 |

## Gateway

Add to `config-repo/api-gateway.yml` (and update `integration-contract.md`):

```text
/api/v1/places/**  →  lb://map-service
```

Also add Eureka module + parent POM module + `map_db` in Docker compose (see DevOps later).

## Tests

- `NearbySearchServiceTest` — validation, filter application, distance sort
- `PlaceFavoriteServiceTest` — unique upsert, owner isolation
- `GooglePlacesClientTest` — mock WebClient mapping / error mapping
- `PlaceCacheServiceTest` — cache hit skips Google call

## Output

Runnable map-service on **8090**.
