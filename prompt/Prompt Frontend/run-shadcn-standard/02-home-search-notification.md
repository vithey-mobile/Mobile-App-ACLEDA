# GLM 5.3 Flash — Shadcn Phase 2 of 6 — Home + Search + Notification

Copy everything below the line into a **new chat** after Phase 1 is merged.

---

You are a Flutter screen agent on Vithey App. Apply the **Shadcn kit** to Home, Search, and Notifications. Do not redesign post cards or Reels video. Do not edit Settings/Auth again. Do not edit backend.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md`
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/core/widgets/widgets.dart`
- `vithey_app/lib/modules/home/`
- `vithey_app/lib/modules/search/`

## Allowed paths

```text
vithey_app/lib/modules/home/**
vithey_app/lib/modules/search/**
```

## Job

Swap chrome only (buttons, fields, sheets, empty/error):

| Area | Use |
|------|-----|
| Home header actions | existing icons + `AppColors.primary` (do not add a 6th tab) |
| Create post | `VitheyField` / `VitheyTextArea`, `CustomButton` |
| Post detail comments | `VitheyField`, `CustomButton` |
| Post / notification menus | `showVitheyActionSheet` |
| Notification filters / delete | `VitheyFilterChips`, `showConfirmDialog` |
| Search bar | `VitheySearchPill` (remove local `shad.TextField` in `search_app_bar.dart`) |
| Search sections | `SectionHeader`, `UserAvatar`, `EmptyStateWidget` / shimmer |

Keep `video_player` / reels page / mixed feed **layout**. Do not rewrite `PostCard` visuals from scratch — only replace Material/shad buttons inside if present.

## Rules

- No `shadcn_flutter` import under `modules/home` or `modules/search`
- No Material `ElevatedButton` / `TextFormField` / `AlertDialog` as primary controls
- Do not collapse folders. Do not touch Map.

## Stop when

- Search bar and notification sheets use the kit
- Analyze clean on touched files
- Print file list

Do not start Phase 3.
