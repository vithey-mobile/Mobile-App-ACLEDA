# Vithey Component Kit — Shadcn Adapters

Phase 0 of the Shadcn standard. **Screens must compose these adapters; never import
`shadcn_flutter` or use raw Material controls directly.**

Only `lib/core/widgets/` may import `package:shadcn_flutter/shadcn_flutter.dart` as `shad`.
Import everything from the barrel: `lib/core/widgets/widgets.dart`.

## Rules

- Tokens only: `context.appColors.*` + `AppColors.primary` (`#03B4AC`). No `Colors.teal`, no `0xFF00BFA5`.
- Tap targets ≥ 48px, radius 12–24, light + dark must both work.
- Keep GetX; do not replace routing/state.

## Widget → when to use → do NOT use raw X

| Widget | When to use | Do not use raw X |
|---|---|---|
| `CustomButton` (primary / secondary / outline / **ghost** / **destructive**) | Every submit, CTA, skip, cancel, delete | `ElevatedButton`, `TextButton`, `OutlinedButton`, raw `shad.Button` |
| `CustomTextField` → `VitheyField` | All single-line inputs (login, comment, search fields) | `TextFormField`, `TextField`, raw `shad.TextField` |
| `VitheyTextArea` | Multi-line input (create post, report reason, chatbot prompt) — `VitheyField` alias with `maxLines >= 3` | `TextFormField(maxLines: n)` |
| `VitheySearchPill` | Search bars on Home, Search, Map, Chat | Raw `shad.TextField` pill copies |
| `VitheyCard` / `VitheyInfoCard` | Settings groups, info panels, form shells | `Card`, custom `Container` surface copies |
| `VitheySwitch` | Settings toggles (privacy, notifications) | `Switch`, `SwitchListTile`, raw `shad.Switch` |
| `VitheyListTile` | Settings/help/about rows: icon + title (+ subtitle) + chevron or switch slot | `ListTile`, `SwitchListTile`, hand-built rows |
| `showConfirmDialog` / `ConfirmDialog` | Any yes/no confirmation (logout, delete, block, accept/reject) | Material `AlertDialog`, raw `shad.AlertDialog` |
| `showVitheyDialog` / `VitheyDialog` | Custom dialog bodies (success panels, rename prompts) | Raw Material `Dialog(` chrome copies |
| `showVitheyActionSheet` (+ `VitheyActionSheetItem` callback style, `VitheyActionSheetAction` value style) | Row menus: post options, notification actions, search-result actions | Material `showModalBottomSheet` copies, raw `shad` sheets |
| `VitheyFilterChips` | Horizontal filter rows (Map, Search, Home, Finance) | Material `FilterChip`, `ChoiceChip` |
| `VitheyTextLink` | Inline text links ("Forgot password?", "Sign up", "See all"); **also** `Get.snackbar(mainButton:)` (extends `TextButton`) | Raw `TextButton` inline / snackbar copies |
| `UserAvatar`, `AppAppBar`, `StatusBadge`, `EmptyStateWidget`, `AppErrorWidget`, `LoadingWidget`, `ShimmerListTile`, `SectionHeader`, `OfflineBanner`, `AppLogo` | Keep as-is; icon actions inside bars use `CustomButton.ghost` | Recreating per screen |

## API notes

- `showConfirmDialog(...)` → `Future<bool?>` (`true` / `false` / `null` on dismiss). `ConfirmDialogVariant.neutral` = teal confirm, `.destructive` = red confirm.
- `showVitheyDialog(...)` → `Future<T?>` for custom content shells (cardSurface, radius 24). Prefer `showConfirmDialog` for yes/no.
- `showVitheyActionSheet(...)`:
  - callback style: `VitheyActionSheetItem(label:, icon:, onTap:, isDestructive:)` — sheet closes then `onTap` fires; `onTap: null` = disabled row.
  - value style: `showVitheyActionSheet<T>(actions: [VitheyActionSheetAction(value:, ...)])` — resolves to the tapped value or `null`.
- `CustomButton` guarantees a 48px minimum tap target in all variants.
- GetX snackbar: use `VitheyTextLink` as `mainButton` (it extends `TextButton`).

## GenZ radii tokens + icon chrome

All corner radii come from `VitheyRadii` (`lib/core/theme/vithey_radii.dart`) — never hardcode 8/12:

| Token | Value | Use for |
|---|---|---|
| `VitheyRadii.iconSquircle` | 18 | icon chrome containers, app bar actions |
| `VitheyRadii.iconButton` | 48 | minimum icon button tap target |
| `VitheyRadii.card` | 18 | `VitheyCard` / list rows / info panels |
| `VitheyRadii.sheet` | 24 | `VitheyDialog`, bottom sheets |
| `VitheyRadii.pill` | 24 | `VitheySearchPill`, chips, pill CTAs |
| `VitheyRadii.field` | 14 | `VitheyField` / inputs |
| `VitheyRadii.media` | 14 | image thumbnails, media containers |

### `VitheyIconButton` — when to use

Replace one-off `Container` + `Icon` chrome with `VitheyIconButton` (`lib/core/widgets/vithey_icon_button.dart`):

- **App bar actions** — always; 48px min tap, squircle by default, `circle: true` for round chrome.
- **List-row leads / inline actions** — icon + soft wash fills instead of bare icons.
- **Destructive actions** — `variant: VitheyIconButtonVariant.destructive` (error wash, never a raw red box).
- Variants: `primary` (teal wash, stronger on dark), `neutral` (input-fill wash + heading icon), `destructive`.
- `onTap: null` renders disabled automatically; pass `tooltip:` for a11y.
- `UserAvatar` stays circular and unchanged.

## Icons — Lucide only, bold stroke

- UI glyphs = `LucideIcons` via `core/icons/vithey_icons.dart` (re-exported from `core/widgets/widgets.dart`).
- Feature modules must not import `shadcn_flutter` — import the core barrel instead.
- Do not use Material `Icons.*` for chrome (app bars, tiles, buttons, inputs, dialogs).
- Render icons with `VitheyIcon` (`core/icons/vithey_icon.dart`), **not** plain `Icon` — the bundled Lucide font is single-weight, so `VitheyIcon` dilates the glyph to a bold stroke (≈ Lucide `stroke-width: 3`). Drop-in API: `VitheyIcon(LucideIcons.bell, size: 24, color: c)`.
- Tune global boldness with `VitheyIcon.strokeBoost` / `VitheyIcon.minBoost` if needed.

## Typography tokens

Font sizes and weights live in one place — same idea as `VitheyRadii`. See [`run-type-tokens/DESIGN.md`](run-type-tokens/DESIGN.md).

| Source | Use for |
|---|---|
| `VitheyType` (`lib/core/theme/vithey_type.dart`) | Size constants: micro 10 → display 22 (current call-site values) |
| `VitheyWeight` (same file) | `regular` w400, `medium` w500, `semibold` w600, `bold` w700 |
| `context.text` (`TextTheme` from light/dark) | Prefer this at call sites — themes wire sizes + weights + heading/muted colors |

**Do:**

```dart
Text(title, style: context.text.titleSmall?.copyWith(color: titleColor))
```

**Do not:**

- Inline `TextStyle(fontSize: 15, fontWeight: FontWeight.w600, …)` for shared roles
- Create text wrapper widgets (`VitheyTitle`, `AppText`, …)
- Snap nearby sizes (13 stays 13); rare sizes (9, 11.5, 17, 24, 28) stay `copyWith(fontSize: …)`
- Replace brand colors — keep `AppColors` + `context.appColors`

Colors stay on `AppColors` / `context.appColors`. No new palette in the type-token pass.

## Status

**Phases 0–6 complete** on the live 10 modules. Screens must not import `shadcn_flutter`. Only `lib/core/widgets/` wraps Shadcn.
