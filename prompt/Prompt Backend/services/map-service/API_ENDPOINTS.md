# Map Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT. User identity from gateway headers / JWT (`X-User-Id`).

## Search & map

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/places/nearby?lat=&lng=&radius_m=&category=&open_now=&min_rating=&price_level=&page_token=&limit=` | Nearby shops/places + filters |
| GET | `/places/search?query=&lat=&lng=&radius_m=&category=&open_now=&min_rating=&price_level=&page_token=&limit=` | Keyword search near user |
| GET | `/places/autocomplete?input=&lat=&lng=` | Typeahead place suggestions |
| GET | `/places/{google_place_id}` | Place detail (pin / list tap) |

## Favorites & history

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/places/favorites` | List my favorites |
| POST | `/places/favorites` | Save a place |
| DELETE | `/places/favorites/{google_place_id}` | Remove favorite |
| GET | `/places/history` | Recent searches (max 20) |
| DELETE | `/places/history` | Clear my search history |

## Filter params (nearby + search)

| Param | Required | Default | Notes |
| --- | --- | --- | --- |
| `lat` | yes | — | User latitude |
| `lng` | yes | — | User longitude |
| `radius_m` | no | `1500` | 100–20000 meters |
| `query` | search only | — | min 2 chars |
| `category` | no | all | `restaurant`, `cafe`, `convenience_store`, `supermarket`, `pharmacy`, `atm`, `bank`, `gas_station`, `shopping_mall`, `lodging`, `hospital`, `university`, `other` |
| `open_now` | no | — | `true` → open places only |
| `min_rating` | no | — | 1.0–5.0 |
| `price_level` | no | — | 0–4 |
| `page_token` | no | — | Google next page |
| `limit` | no | `20` | 1–40 |

## Place card (list + marker)

```json
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
```

## Nearby / search envelope

```json
{
  "data": {
    "center": { "lat": 11.5564, "lng": 104.9282 },
    "radius_m": 2000,
    "places": [],
    "next_page_token": null
  },
  "meta": null,
  "error": null
}
```

## Access rules

- Any authenticated role may search.
- Favorites and history are scoped to the current user only.
- Do not expose Google API keys to clients.
