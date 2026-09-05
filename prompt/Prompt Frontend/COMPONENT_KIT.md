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

## Status

**Phases 0–6 complete** on the live 10 modules. Screens must not import `shadcn_flutter`. Only `lib/core/widgets/` wraps Shadcn.
