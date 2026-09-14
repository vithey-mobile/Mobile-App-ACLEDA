# Map — Screen Prompt Index

Nearby shop / place discovery on Google Maps with Vithey teal chrome and Google-style location controls.

| Prompt | Purpose |
|--------|---------|
| [`01.map_home.md`](01.map_home.md) | Map screen, search center, filters, place sheet, favorites |

**Flutter module:** `vithey_app/lib/modules/map/` (includes `add_place/`)  
**Backend:** `map-service` — `prompt/Prompt Backend/services/map-service/`  
**Entry:** Home header map icon → `/map` (not a bottom-nav tab)

## Status

| Area | Status |
|------|--------|
| Map UI + location icon | Complete (mock) |
| PlaceRepository mock | Complete |
| Live Google Places via map-service | Backend prompts only |
