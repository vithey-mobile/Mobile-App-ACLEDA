# GLM 5.3 Flash — Shadcn Phase 5 of 6 — Sweep

Copy everything below the line into a **new chat** after Phase 4 is merged.

---

You are a Flutter cleanup agent on Vithey App. **Enforce the kit.** Do not add features. Do not edit backend.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md` §5 Phase 5 + §8
- `prompt/Prompt Frontend/COMPONENT_KIT.md`

## Search and fix leftovers

From `vithey_app/lib/modules/`:

1. `import 'package:shadcn_flutter` → **zero** files. Move any remaining wrap into `core/widgets` or replace with kit.
2. `ElevatedButton` / `TextButton` / `OutlinedButton` / `TextFormField` / `SwitchListTile` used as primary controls → replace with kit.
3. Material `AlertDialog(` / `showDialog` confirm copies → `showConfirmDialog`.
4. `Colors.teal` / `0xFF00BFA5` → `AppColors.primary` / `context.appColors`.

**Allowed exceptions (document in COMPONENT_KIT.md if you keep them):**

- `GoogleMap`, `VideoPlayer`, PDF viewer, Lottie
- `Scaffold` / `ListView` / `Text` / `Icon`
- InkWell on a card that already uses `VitheyCard`

## Docs

- Update `prompt/Prompt Frontend/COMMON_CONTEXT.md` UI rules: “screens import `core/widgets/widgets.dart`; never `shadcn_flutter`.”
- Update `SHADCN_STANDARD_PLAN.md` status to: Phase 0–5 done (or list leftovers honestly).

## Verify

```text
cd vithey_app
dart analyze lib/modules lib/core/widgets
```

Print:

- Remaining `shadcn_flutter` imports (should be none under modules)
- Remaining Material CTA hits (should be none or listed exceptions)
- Files you changed

Do not restyle from scratch. Do not open new product scope.
