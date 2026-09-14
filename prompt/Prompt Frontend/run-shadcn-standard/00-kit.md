# GLM 5.3 Flash — Shadcn Phase 0 of 6 — Kit

Copy everything below the line into a **new chat**. Do not edit `lib/modules/` in this chat.

---

You are a Flutter UI-kit agent on Vithey App. **Build the reusable Shadcn adapters only.** Do not restyle screens. Do not edit backend. Do not move module folders.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md`
- `prompt/Prompt Frontend/COMMON_CONTEXT.md` (UI component system)
- `vithey_app/lib/core/widgets/` (especially `custom_button.dart`, `vithey_field.dart`, `vithey_card.dart`, `confirm_dialog.dart`, `vithey_filter_chips.dart`, `widgets.dart`)
- `vithey_app/lib/app.dart` (shad theme already injected)
- `vithey_app/lib/core/theme/app_semantic_colors.dart`

## Allowed paths

```text
vithey_app/lib/core/widgets/**
prompt/Prompt Frontend/COMPONENT_KIT.md
prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md   # mark Phase 0 done if you touch it
```

## Rules

- Only `core/widgets` may `import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;`
- Keep GetX. Keep existing widget **names** (`CustomButton`, `CustomTextField`, `showConfirmDialog`) so call sites do not break
- Tokens: `context.appColors`, `AppColors.primary` (`#03B4AC`). No `Colors.teal`, no `0xFF00BFA5`
- Tap targets ≥ 48. Radius 12–24. Light + dark.

## Build

1. **`CustomButton`** — add enum values `ghost` and `destructive` mapping to `shad.Button.ghost` / `shad.Button.destructive`. Keep primary / secondary / outline.
2. **`VitheySwitch`** — wrap `shad.Switch`. Props: `value`, `onChanged`, optional `enabled`.
3. **`VitheyListTile`** — settings row: icon, title, optional subtitle, trailing (chevron or switch slot), `onTap`, uses `VitheyCard` or same surface tokens.
4. **`VitheyActionSheet`** — helper `showVitheyActionSheet` with title + list of `{ label, icon?, onTap, isDestructive }`. Theme with `appColors`. Use Shadcn dialog/sheet if it fits mobile; otherwise a themed modal bottom sheet. 48px rows.
5. **`showConfirmDialog`** — keep `Future<bool?>` API and `ConfirmDialogVariant`. Implement with `shad.AlertDialog` + `CustomButton` (ghost cancel, primary or destructive confirm). Do not break existing callers.
6. **`VitheyFilterChips`** — stop looking like default Material; use brand tokens / Shadcn chip style. Same constructor API.
7. **`VitheyTextArea`** — thin alias: `VitheyField` with `maxLines` ≥ 3.
8. Export all new files from `widgets.dart`.
9. Write `prompt/Prompt Frontend/COMPONENT_KIT.md`: table of widget → when to use → do not use raw X.

## Do not

- Edit any file under `lib/modules/`
- Add `VitheyButton` (extend `CustomButton` only)
- Change `app.dart` theme unless analyze fails
- Rewrite `UserAvatar`, `AppAppBar`, `StatusBadge`, empty/error/loading unless a compile break

## Stop when

- `dart analyze` on `vithey_app/lib/core/widgets/` is clean
- `COMPONENT_KIT.md` exists
- Print the new/changed widget list

Do not start Phase 1 in this chat.
