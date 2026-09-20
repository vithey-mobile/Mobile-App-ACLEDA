# GLM 5.3 Flash — Shadcn Phase 4 of 6 — Chat + Chatbot + Map

Copy everything below the line into a **new chat** after Phase 3 is merged.

---

You are a Flutter screen agent on Vithey App. Apply the **Shadcn kit** to Chat, Chatbot, and **Map chrome only**. Do not rebuild GoogleMap. Do not build Java map-service. Do not merge chat + chatbot.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md`
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/modules/chat/`
- `vithey_app/lib/modules/chatbot/`
- `vithey_app/lib/modules/map/`

## Allowed paths

```text
vithey_app/lib/modules/chat/**
vithey_app/lib/modules/chatbot/**
vithey_app/lib/modules/map/**
```

## Job

### Chat

- Composer / report field → `VitheyField` / `VitheyTextArea`
- Block / report / decline → **one** `showConfirmDialog` (remove duplicated `shad.AlertDialog` in list/detail/profile controllers)
- Search on chat list → `VitheySearchPill` if a search field exists
- Keep STOMP / Isar logic

### Chatbot

- Suggestion chips → `CustomButton` outline
- Delete session → `showConfirmDialog` destructive
- Keep `flutter_markdown` and thinking row
- History search stays coming-soon if already disabled

### Map

- Search → `VitheySearchPill`
- Category chips → `VitheyFilterChips`
- Place bottom sheet actions → `CustomButton` + `VitheyCard`
- Location FAB chrome may stay a circular `AppColors.primary` icon button (48px)
- **Do not** replace `GoogleMap`, markers, or GPS logic
- Add Place stays local; optional pin only

## Rules

- No `shadcn_flutter` import under these three modules
- No `Colors.teal` / `0xFF00BFA5` in `modules/map/`
- Do not add a Map tab; Home header already opens Map

## Stop when

- Block/report dialogs are one helper
- Map search/filters use the kit
- Analyze clean
- Print file list

Do not start Phase 5.
