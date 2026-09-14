# GLM 5.3 Flash — Prompt 2 of 3

Copy everything below the line into a **new chat** after Prompt 1 is merged. Read current files; modules are already the 10-folder layout.

---

You are a Flutter agent on Vithey App. Implement **Map only** (plus tiny Home entry). Do not collapse folders again. Do not GenZ-sweep the whole app. Do not build Java map-service.

## Read first

- `vithey_app/lib/modules/map/` (map + `add_place/`)
- `vithey_app/lib/modules/home/` (header + shell — remove Material map FAB)
- `prompt/Prompt Backend/services/map-service/API_ENDPOINTS.md`
- `vithey_app/lib/core/constants/app_colors.dart`
- `vithey_app/lib/core/config/feature_flags.dart`
- `vithey_app/lib/core/widgets/` (`CustomButton`, `CustomTextField`, search-style pills if any)

## Product

Users find shops near **a search center**. The center is GPS **or** another place they pick (Google Maps style).

### Location icon (required)

Bottom-right teal circle (`AppColors.primary`, not `Colors.teal`, not `0xFF00BFA5`):

- `Icons.my_location` / `Icons.gps_fixed` when camera follows GPS
- `Icons.gps_not_fixed` when the user panned away or set another place
- Tap: request permission if needed; recenter on GPS; set `searchCenter = gps`; run nearby
- Long-press: reset to GPS (“Back to me”)
- If permission denied: snackbar + open app settings
- Keep Google default my-location button **off**; this custom icon is the control

### Set location to another place

1. Pill search + autocomplete: picking a suggestion moves camera, drops a “Search from here” marker, sets `searchCenter`, runs nearby
2. Long-press map: drop pin → sheet **Search around here** → confirm sets `searchCenter`
3. After pan/zoom away from center: show pill **Search this area** (camera center → `searchCenter`)

`MapController` state:

- `gpsLatLng`
- `searchCenter` (origin for all nearby/search API calls as `lat`/`lng`)
- `isFollowingGps`

### Data

Stop calling Photon/Komoot from the controller.

Add:

- `USE_MOCK_MAP` in `feature_flags.dart` (fallback to `useMockApi`)
- `PlaceRepository` + Phnom Penh mock places
- Dio paths relative to `API_BASE_URL`: `/places/nearby`, `/places/search`, `/places/autocomplete`, `/places/{id}`, `/places/favorites`, `/places/history`
- JSON snake_case matching `prompt/Prompt Backend/services/map-service/API_ENDPOINTS.md`

Filters: `category`, `radius_m`, `open_now`, `min_rating`, `price_level`. Category chips + filter sheet. Pin tap → place bottom sheet (name, rating, distance, favorite, directions).

Add Place stays local-only (optional pin). Do not invent a backend for it.

### UI (this screen only)

- `AppColors` / `context.appColors` only
- Pill search (radius 24), chip filters, 16 radius sheet
- Remove Home Material FAB; put a map icon on the Home header next to chat/search
- Keep 5 bottom tabs; do not add a Map tab

### Docs (map only)

Create `prompt/Prompt Frontend/Screen prompt/map/README.md` + one screen prompt for map + location icon.

Add to `prompt/Prompt Frontend/api-intergration/integration-contract.md`:

- gateway `/api/v1/places/**` → `map-service`
- screen row: Map → map-service + those endpoints

Add Map to `prompt/Prompt Frontend/COMMON_CONTEXT.md` feature list and `prompt/Prompt Frontend/Screen prompt/README.md` status table.

## Stop when

- Map uses repository (mock works with `USE_MOCK_API=true`)
- Location icon + pick-another-place + search-this-area + long-press work
- Home opens Map from header, not FAB
- No `Colors.teal` left in `modules/map/`

Do not restyle auth/chat/finance/settings in this chat.
