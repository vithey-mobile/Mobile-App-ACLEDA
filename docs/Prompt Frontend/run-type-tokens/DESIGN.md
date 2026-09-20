# Vithey Type + Color Tokens (extract only)

Use this as the **typography + leftover-color** contract for `run-type-tokens`.

This pack is **not** a GenZ restyle. Goal: one reusable place for font size, font weight, and surface colors — **same pixels as today**, less inline `TextStyle`, no new text widgets.

## Existing tokens (do not reinvent)

| Layer | Source | Use for |
|-------|--------|---------|
| Brand / status hex | `AppColors` (`lib/core/constants/app_colors.dart`) | Primary `#03B4AC`, secondary, error, success, paid/pending, light/dark text pairs |
| Semantic surfaces | `context.appColors` (`AppSemanticColors`) | `heading`, `muted`, `cardSurface`, `inputFill`, `border`, `bodyBackground`, `dangerSurface` |
| Radii | `VitheyRadii` | Cards, pills, fields, sheets, icon chrome |
| Icon chrome | `VitheyIconButton` / `VitheyIcon` | App bar + list actions |

Forbidden: purple gradients, `Colors.teal`, random primary hex (`0xFF00BFA5`), new font families.

## Typography sizes (`VitheyType`)

Sizes come from **current call sites**, not Material defaults. Do not snap nearby values.

| Token | px | Typical use |
|-------|-----|-------------|
| `micro` | 10 | Nav badge, tiny labels |
| `caption` | 11 | Timestamps, micro meta |
| `meta` | 12 | Secondary meta |
| `subtitle` | 13 | List subtitles (very common) |
| `body` | 14 | Body copy |
| `titleSm` | 15 | `VitheyListTile` titles |
| `title` | 16 | Fields, composers, section titles |
| `titleLg` | 18 | Emphasized section titles |
| `headline` | 20 | Screen / sheet titles |
| `display` | 22 | Large screen titles |

**One-offs stay one-offs.** Do not invent tokens for rare sizes: `9`, `11.5`, `17`, `24`, `28`. Keep them as `context.text.*.copyWith(fontSize: …)`.

## Font weights (`VitheyWeight`)

| Token | Value | Notes |
|-------|--------|-------|
| `regular` | `FontWeight.w400` | Body |
| `medium` | `FontWeight.w500` | Labels / soft emphasis |
| `semibold` | `FontWeight.w600` | Titles, list rows |
| `bold` | `FontWeight.w700` | Headlines; map `FontWeight.bold` → this |

Keep `FontWeight.w800` only where it already exists (few display titles). Do not upgrade w700 → w800.

## `textTheme` roles (wire in light + dark)

Colors from semantic tokens: heading text → `appColors.heading`, muted → `appColors.muted`.

| `TextTheme` role | Size | Weight | Color |
|------------------|------|--------|-------|
| `headlineSmall` | 22 (`display`) | bold | heading |
| `titleLarge` | 18 (`titleLg`) | bold | heading |
| `titleMedium` | 16 (`title`) | semibold | heading |
| `titleSmall` | 15 (`titleSm`) | semibold | heading |
| `bodyLarge` | 16 (`title`) | regular | heading |
| `bodyMedium` | 14 (`body`) | regular | heading |
| `bodySmall` | 13 (`subtitle`) | regular | muted |
| `labelLarge` | 14 (`body`) | semibold | heading |
| `labelMedium` | 12 (`meta`) | medium | muted |
| `labelSmall` | 11 (`caption`) | medium | muted |

Access via existing extension: `context.text` (`AppThemeContext` in `app_semantic_colors.dart`).

### Call-site target (less code)

```dart
// before
Text(
  title,
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: titleColor,
  ),
)

// after
Text(title, style: context.text.titleSmall?.copyWith(color: titleColor))
```

Prefer `context.text.*` over sprinkling `VitheyType.titleSm` + `VitheyWeight.semibold` into a new 5-line `TextStyle`. Constants exist so themes stay the single source of truth.

## Colors (no new palette)

Replace leftover:

- `Color(0xFF…)` that duplicates brand / surface / text
- `Colors.teal` / random teal hex
- Surface `Colors.white` / `Colors.black` / `Colors.grey` on cards, scaffolds, panels

With:

- `AppColors.*`
- `context.appColors.*`
- `context.scheme.*` (e.g. `onPrimary` on filled primary buttons)

**Keep** white/black when it is ink on a photo/video overlay (reels, media fullscreen, dark scrims). Those are not theme surfaces.

## Leave alone

- PDF builders (`cv_pdf_builder.dart` and similar)
- Fixture / mock hex in `lib/data/fixtures/**`
- `GoogleMap` / platform views
- Generated `*.g.dart`
- Business logic, routes, GetX structure, padding, radii, layout

## Hard rules (every prompt in this pack)

1. **Same pixels** — do not normalize 13→12 or restyle screens.
2. **Less code** — delete duplicate `TextStyle` blobs; do not add `VitheyTitle` / `AppText` widgets.
3. **Tokens only** for shared design values — one place to change type globally later.
4. Light + dark both still work.
5. Kit first (Prompt 00), then modules in parallel, then sweep.
