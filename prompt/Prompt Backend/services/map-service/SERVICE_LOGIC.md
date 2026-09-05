# Map Service — Service Logic

## Ownership

Owns:

- Proxy + normalize Google Places nearby / text / autocomplete / detail
- Server-side filter application and distance sorting
- Redis response caching
- Per-user favorites and recent search history

Does not own:

- Google Maps camera / markers UI (Flutter)
- Profile location text field (user-profile-service)
- Job workplace strings (content-service)

## Core flows

| Flow | Logic |
| --- | --- |
| Nearby search | Validate coords + filters → Redis get-or-load → Google Nearby Search (New) with `includedTypes` from `category` → compute `distance_m` (Haversine) → apply `open_now` / `min_rating` / `price_level` if not fully handled by Google → sort by distance → mark favorites → optionally write history when `query` or `category` present |
| Text search | Require `query` ≥ 2 → location bias (`lat`/`lng`/`radius_m`) → Google Text Search → same normalize / filter / cache / favorite flags |
| Autocomplete | Validate `input` → Google Autocomplete with location bias → return compact suggestions (no heavy Place Details) |
| Place detail | Redis detail cache → Google Place Details field mask → set `is_favorite` for caller |
| Save favorite | Upsert by (`user_id`, `google_place_id`); store coordinate snapshot for offline map pins |
| Remove favorite | Delete only if owned by caller |
| History list | Last 20 by `created_at DESC` |
| Clear history | Delete all rows for caller |
| History trim | After insert, if count &gt; 20 delete oldest |

## Filter application order

1. Google request constraints (`includedTypes`, `locationRestriction` / bias, `openNow` when supported)
2. Server post-filter: `min_rating`, `price_level`, category alias cleanup
3. Sort: `distance_m` ascending (nulls last)
4. Truncate to `limit`

## Distance

Haversine meters between user (`lat`,`lng`) and place location. Round to integer meters in responses.

## Caching policy

| Operation | Cache | On miss |
| --- | --- | --- |
| Nearby / search | Redis 5 min | Call Google, store normalized JSON |
| Detail | Redis 24 h | Call Google Place Details |
| Favorites / history | DB only | — |

Bypass cache only via internal profile flag (not public query param in v1).

## Google error mapping

| Google / HTTP | Vithey |
| --- | --- |
| 400 INVALID_ARGUMENT | `VALIDATION_ERROR` 400 |
| 403 / 429 quota | `UPSTREAM_ERROR` 502 |
| 404 NOT_FOUND | `NOT_FOUND` 404 |
| 5xx / timeout | `UPSTREAM_ERROR` 502 |
| Circuit breaker open | `UPSTREAM_ERROR` 503 |

## Security

- API key only in server env / Config Server
- Auth required on every Places proxy endpoint
- Gateway rate limits (see `SERVICE_PROMPT.md`)
- Do not persist raw Google responses longer than cache TTL unless favorited (snapshot fields only)

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Invalid lat/lng/radius/filter | `VALIDATION_ERROR` | 400 |
| Search query too short | `VALIDATION_ERROR` | 400 |
| Unauthorized | `UNAUTHORIZED` | 401 |
| Favorite / place missing | `NOT_FOUND` | 404 |
| Google failure / quota | `UPSTREAM_ERROR` | 502 |

## Frontend alignment (expected)

- Map screen: request nearby on camera idle / “Search this area”
- Filter chip row: category + open_now + radius + min_rating
- List sheet under map shares same `places[]` payload
- Pin tap → `GET /places/{id}`
- Heart → favorites endpoints

## Deferred (v1.1+)

- Photo proxy endpoint
- Vithey company / shop profiles linked to `google_place_id`
- Offline tile packs
- Admin curated shop categories beyond Google types
