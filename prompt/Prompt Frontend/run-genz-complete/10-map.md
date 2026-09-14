# GLM 5.3 Flash — Prompt 10 — Map (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with other modules.

---

You are a Flutter UI agent. Restyle **map module chrome only** to GenZ smart screens. Keep `GoogleMap` working.

## Own only

```text
vithey_app/lib/modules/map/**
```

## Requirements

1. Search → `VitheySearchPill`.
2. Category / filters → `VitheyFilterChips` + sheet radius 24.
3. FABs / locate / favorite icons → circular 48 chrome.
4. Place bottom sheet: card radius 24, rounder action icons.
5. Add Place form: kit fields/buttons.
6. Do not break PlaceRepository / mock / Google map gestures.
7. No `Colors.teal` / random map hex — use tokens.

## Stop when

Map chrome GenZ-consistent; map still runs; analyze clean.
