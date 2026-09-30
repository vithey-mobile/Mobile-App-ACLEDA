# 10 — Map Service Integration Contract

> **Target Service:** `map-service`  
> **Direct Port:** `8090` | **Gateway Base URL:** `http://localhost:8080/api/v1/places`  
> **Database:** `map_db` | **Cache:** Redis | **Naming Convention:** `snake_case`

---

## 1. Places Discovery & Search

### 1.1 Nearby Places (Map Pins & Bottom Sheet)
Searches points of interest (cafes, study spots, ATMs, restaurants, book stores) around the user's GPS coordinates.

- **Method / Path:** `GET /api/v1/places/nearby`
- **Auth:** Bearer JWT (or optional public fallback)

#### Query Parameters
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `lat` | `double` | Yes | - | Latitude (`-90.0` to `90.0`) |
| `lng` | `double` | Yes | - | Longitude (`-180.0` to `180.0`) |
| `radius_m` | `integer` | No | 1500 | Search radius in meters (100 to 20000) |
| `category` | `string` | No | - | Filter e.g. `"cafe"`, `"restaurant"`, `"library"`, `"atm"` |
| `open_now` | `boolean` | No | - | Only currently open places |
| `min_rating` | `double` | No | - | Minimum rating (`1.0` to `5.0`) |
| `price_level`| `integer` | No | - | Price tier (`0` to `4`) |
| `limit` | `integer` | No | 20 | Results limit (1 to 40) |
| `page_token` | `string` | No | - | Next page token from previous response |

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "center": {
      "lat": 11.5564,
      "lng": 104.9282
    },
    "radius_m": 1500,
    "places": [
      {
        "google_place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
        "name": "Brown Coffee Roasters - AUB Campus",
        "address": "Street 2004, Phnom Penh",
        "category": "cafe",
        "latitude": 11.5580,
        "longitude": 104.9290,
        "rating": 4.6,
        "user_rating_count": 328,
        "price_level": 2,
        "open_now": true,
        "distance_m": 240,
        "photo_url": "https://maps.googleapis.com/maps/api/place/photo?...",
        "is_favorite": true
      }
    ],
    "next_page_token": "CqQGegEAAO..."
  }
}
```

---

### 1.2 Keyword Place Search
Text search with location biasing.

- **Method / Path:** `GET /api/v1/places/search`
- **Auth:** Bearer JWT

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `query` | `string` | Yes | Search query (e.g. `"quiet cafe to study"`) |
| `lat` | `double` | No | User's current latitude for proximity ranking |
| `lng` | `double` | No | User's current longitude |
| `radius_m` | `integer` | No (default: 5000)| Bias radius |
| `open_now` | `boolean` | No | Filter open places |
| `min_rating`| `double` | No | Minimum rating filter |

Returns `PlaceSearchResultResponse` with `{ "data": { ... } }`.

---

### 1.3 Place Autocomplete / Typeahead
Fast suggestions for the search bar as the user types.

- **Method / Path:** `GET /api/v1/places/autocomplete?input=Brown&lat=11.5564&lng=104.9282`
- **Auth:** Bearer JWT

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "google_place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
      "primary_text": "Brown Coffee Roasters",
      "secondary_text": "Street 2004, Phnom Penh",
      "distance_m": 240
    },
    {
      "google_place_id": "ChIJ2eUgeAK6EmsRo61ivEEg35U",
      "primary_text": "Brown Coffee & Bakery TK",
      "secondary_text": "Toul Kork, Phnom Penh",
      "distance_m": 2800
    }
  ]
}
```

---

### 1.4 Place Detail (Pin Tap / Bottom Sheet)
- **Method / Path:** `GET /api/v1/places/{googlePlaceId}`
- **Auth:** Bearer JWT

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "google_place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
    "name": "Brown Coffee Roasters - AUB Campus",
    "address": "Street 2004, Phnom Penh",
    "category": "cafe",
    "latitude": 11.5580,
    "longitude": 104.9290,
    "rating": 4.6,
    "user_rating_count": 328,
    "price_level": 2,
    "open_now": true,
    "opening_hours": [
      "Monday: 6:30 AM – 9:00 PM",
      "Tuesday: 6:30 AM – 9:00 PM",
      "Wednesday: 6:30 AM – 9:00 PM",
      "Thursday: 6:30 AM – 9:00 PM",
      "Friday: 6:30 AM – 9:00 PM",
      "Saturday: 7:00 AM – 9:30 PM",
      "Sunday: 7:00 AM – 9:30 PM"
    ],
    "phone": "+855 23 999 888",
    "website": "https://browncoffee.com.kh",
    "google_maps_uri": "https://maps.google.com/?cid=...",
    "photo_urls": [
      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=...",
      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=..."
    ],
    "is_favorite": true
  }
}
```

---

## 2. Saved / Favorite Places

### 2.1 List My Favorites
- **Method / Path:** `GET /api/v1/places/favorites`
- **Auth:** Bearer JWT required

Returns `List<PlaceCardResponse>` in `{ "data": [ ... ] }`.

---

### 2.2 Save Place to Favorites
- **Method / Path:** `POST /api/v1/places/favorites`
- **Auth:** Bearer JWT required

#### Request Schema
```json
{
  "google_place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
  "name": "Brown Coffee Roasters - AUB Campus",
  "address": "Street 2004, Phnom Penh",
  "latitude": 11.5580,
  "longitude": 104.9290,
  "category": "cafe",
  "photo_url": "https://maps.googleapis.com/maps/api/place/photo?..."
}
```

#### Response Schema (`201 Created`)
Returns saved `PlaceCardResponse` with `is_favorite: true`.

---

### 2.3 Remove Favorite
- **Method / Path:** `DELETE /api/v1/places/favorites/{googlePlaceId}`
- **Auth:** Bearer JWT required

**Response:** `204 No Content`

---

## 3. Place Search History

### 3.1 List Recent Searches
- **Method / Path:** `GET /api/v1/places/history`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "query": "study cafe",
      "category": "cafe",
      "latitude": 11.5564,
      "longitude": 104.9282,
      "radius_m": 1500,
      "created_at": "2026-09-14T08:10:00Z"
    }
  ]
}
```

### 3.2 Clear Search History
- **Method / Path:** `DELETE /api/v1/places/history`
- **Auth:** Bearer JWT required

**Response:** `204 No Content`
