# GLM 5.3 Flash — Shadcn Phase 6 — Finish leftovers

Copy everything below the line into a **new chat**. Phases 0–4 are already done on the live 10 modules. **Do not rebuild the kit. Do not restyle screens from scratch.**

---

You are a Flutter cleanup agent on Vithey App. Close the last Shadcn-standard gaps. Do not edit backend. Do not move the 10 module folders. Do not invent a new palette.

## Already done (do not redo)

- Kit in `vithey_app/lib/core/widgets/` (`CustomButton` ghost/destructive, `VitheySwitch`, `VitheyListTile`, `VitheyActionSheet`, `VitheyTextArea`, `showConfirmDialog` → shad)
- Live routes use only: `auth`, `home`, `profile`, `jobs`, `finance`, `chat`, `chatbot`, `search`, `settings`, `map`
- Those modules no longer import `shadcn_flutter`

## Read first

- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md`
- `vithey_app/lib/routes/app_pages.dart` (source of truth for live paths)

## 1. Allowed GetX snackbar exception (keep, polish)

`Get.snackbar(..., mainButton:)` is typed as Material `TextButton?`. These two are **allowed**:

- `vithey_app/lib/modules/map/map_controller.dart`
- `vithey_app/lib/modules/settings/notification_preferences/notification_preferences_controller.dart`

If `VitheyTextLink` works as `mainButton`, use it. If GetX still requires `TextButton`, keep it and leave the comment. Do not invent a fake snackbar API.

## 2. Two custom dialogs still use Material `Dialog` chrome

They already use `CustomButton` / `VitheyField`. Either:

- Add `VitheyDialog` in `core/widgets` (themed shell: `cardSurface`, radius 24, padding) and use it here, **or**
- Convert to `showConfirmDialog` / `shad.AlertDialog` via the existing confirm helper if it fits

Files:

- `vithey_app/lib/modules/jobs/widgets/application_success_dialog.dart` (success + Done)
- `vithey_app/lib/modules/chat/widgets/chat_folders_sheet.dart` (`_promptFolderName` rename/create)

Do not change folder-rename logic.

## 3. Sweep live modules only

Search **only** `vithey_app/lib/modules/{auth,home,profile,jobs,finance,chat,chatbot,search,settings,map}/`:

| Find | Do |
|------|-----|
| `import 'package:shadcn_flutter` | Must be **zero** |
| `ElevatedButton` / `OutlinedButton` / `TextFormField` / `SwitchListTile` / Material `AlertDialog(` | Replace with kit |
| `Colors.teal` / `0xFF00BFA5` | `AppColors.primary` / `context.appColors` |

Ignore stale index hits under `apply_cv/`, `onboarding/`, `startup/`, `add_place/`, `student_verification/` if those folders **do not exist** on disk.

## 4. Docs

Update:

- `prompt/Prompt Frontend/COMPONENT_KIT.md` → Phase 0–5 done; list the GetX snackbar exception
- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md` → status: complete except documented leftovers
- `prompt/Prompt Frontend/COMMON_CONTEXT.md` if it still says screens may import shadcn directly — screens import `core/widgets/widgets.dart` only

## Stop when

```text
cd vithey_app
dart analyze lib/modules lib/core/widgets
```

Print:

- Files changed
- Any remaining Material CTA (only snackbar `TextButton` is OK)
- Confirm 10 module folders only

Do not start a new visual redesign.
