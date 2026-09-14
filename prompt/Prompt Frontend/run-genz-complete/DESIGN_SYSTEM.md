# Vithey GenZ Design System (Flutter)

Use this as the single visual contract for `run-genz-complete`. Keep product brand; upgrade **shape language** and consistency.

## Brand (do not replace)

| Token | Value |
|-------|--------|
| Primary | `#03B4AC` (`AppColors.primary`) |
| Secondary | `#03B03C` |
| Error | `#E42407` |
| Surfaces | `context.appColors.cardSurface` / `inputFill` / `border` / `heading` / `muted` |

Forbidden: purple gradients, cream newspaper looks, random hex teal (`0xFF00BFA5`), `Colors.teal`.

## GenZ smart-screen principles

1. **One job per screen** — clear hierarchy: title → primary action → content.
2. **Airy, not empty** — consistent padding `16–20` horizontal; section gaps `12–16`.
3. **Soft geometry** — larger radii than old 8–12 everywhere.
4. **Icon-first chrome** — circular / squircle icon buttons with soft primary wash.
5. **Motion light** — keep existing animations; do not add noisy parallax.
6. **States complete** — loading / empty / error / disabled / success use kit widgets (`LoadingWidget`, `EmptyStateWidget`, `AppErrorWidget`, disabled `CustomButton`).
7. **Dark mode equal** — every surface you touch must look intentional in dark.

## Radii (target)

| Element | Radius |
|---------|--------|
| Icon button chrome (squircle) | **16–20** (was often 8–12) |
| Circular icon button | full circle, min size **44–48** |
| Cards / list rows | **16–20** |
| Sheets / dialogs | **24** |
| Search pills / chips | **24** (pill) |
| Primary CTA (`CustomButton`) | follow kit / theme radius (~20–24) |
| Text fields | **16** radius, text **16**, padding ~14 vertical |
| Images / media thumbs | **12–16** |
| Avatars | keep circular |

Prompt **00** should centralize these as `VitheyRadii` (and optionally `VitheyIconChrome` widget).

## Icon chrome (required pattern)

Replace one-off `Container` + `Icon` with a shared pattern:

```text
┌──────────────┐
│  soft fill   │  radius 16–20 OR Circle
│   ┌────┐     │  size ≥ 44
│   │icon│     │  icon size 20–22
│   └────┘     │  color: primary or heading
└──────────────┘
```

- Default fill: `AppColors.primary.withValues(alpha: 0.12)` on light; slightly stronger on dark.
- Destructive actions: error wash, not random red boxes.
- App bar actions: same chrome, aligned, 48 min tap.

## Typography

- Headings: `context.appColors.heading`, w600–w700
- Body / captions: `context.appColors.muted`
- Do not introduce new font families in this pack unless already in theme

## Component kit (mandatory)

See [`../COMPONENT_KIT.md`](../COMPONENT_KIT.md). Prefer:

- `CustomButton` (primary / outline / ghost / destructive)
- `VitheyField` / `VitheySearchPill` / `VitheyFilterChips`
- `VitheyCard` / `VitheyListTile` / `VitheySwitch`
- `VitheyDialog` / `showConfirmDialog` / `showVitheyActionSheet`
- `UserAvatar` / `StatusBadge` / `EmptyStateWidget`

## Per-module “smart screen” checklist

Every screen touched must have:

- [ ] Consistent padding
- [ ] Kit CTAs only
- [ ] Rounder icon chrome
- [ ] Empty + error + loading handled
- [ ] Dark mode check
- [ ] No raw `ElevatedButton` / `TextButton` / `FilterChip` / `Card`

## Out of scope

- New color brand / logo redesign
- Backend or AI model wiring
- Rewriting GetX architecture
- Pixel-clone of TikTok/IG — stay Vithey teal career social
