# GLM 5.3 Flash — Prompt 3 of 3

Copy everything below the line into a **new chat** after Prompt 1 and Prompt 2 are done.

---

You are a Flutter + docs agent on Vithey App. Finish glue, honest dead-ends, a light GenZ token pass, and missing screen prompts. Do not rebuild Map. Do not move module folders. Do not implement 2FA, biometric, extra banks, invoice report, or real Google OAuth.

## 1. Happy-path glue

- Home header: Search, Chat, and Map icons are all visible and use `AppColors.primary`
- Chat stays a header entry (not a 6th tab). Chatbot stays tab 3
- Search: optional **Places** group that opens Map with that query / place id if `PlaceRepository` exists; if too large, add a “Places on map” row that `Get.toNamed('/map')` with the query argument
- Set `FORCE_DEV_FUNNEL` default in `.env.example` to `false` and add a one-line comment: turn on only when testing Splash → Auth

## 2. Honest “coming soon”

Do not fake features. Hide the control **or** disable it with helper text (no snackbar-only dead buttons on the main path):

- Profile `editJobPost` — hide “Edit job” or disable with “Coming soon”
- Settings 2FA / biometric — disable tiles, subtitle “Coming soon”
- Finance “More banks” / “Report an issue” — disable, same
- Chatbot history search — disable field, “Coming soon”
- Remove stale `chatbotAttachComingSoon` usage if attach already works

## 3. GenZ token pass (existing brand only)

Do **not** invent a new palette. Use `AppColors` (`primary` `#03B4AC`) and `context.appColors`.

Replace in feature modules (skip `core/` theme files unless needed):

- `Colors.teal`
- one-off map/home hex `0xFF00BFA5`

Prefer `CustomButton` / `CustomTextField` when you already touch a screen. Do not rewrite every `TextField` in the repo.

If missing, add small shared widgets under `lib/core/widgets/`:

- `VitheySearchPill`
- `VitheyFilterChips`

Use them on Map (if Prompt 2 did not) and Search.

Dark mode: no hardcoded `Colors.white` on surfaces you touch.

## 4. Missing prompts + stale links

Write short prompts (use `prompt/Prompt Frontend/Screen prompt/_SCREEN-TEMPLATE.md`):

- Forgot password — screen already at `modules/auth/forgot_password_screen.dart`
- Applicant list — `modules/profile/job_applicants_screen.dart` (file was missing as `poster_job/02.list_cv_apply_job.md`)
- Preview own CV — `modules/profile/cv_screens.dart`
- Search see-all — optional short file if `02.search_results.md` is not enough

Fix broken `v0/` / `v1/` links in:

- `prompt/Prompt Frontend/Screen prompt/README.md` (paths are flat, not `auth/v1/`)
- `search/README.md`, `job_apply/README.md`, `upload_cv/README.md`

Add a Map row to the Screen prompt README status table if Prompt 2 missed it.

## 5. Out of scope

- Java `map-service`
- Production FCM / Google billing
- Full redesign of every screen
- Implementing edit-job, 2FA, more banks

## Stop when

- Main happy path has no snackbar-only dead actions
- No `Colors.teal` in `vithey_app/lib/modules/`
- Missing prompt files exist and README links work
- You list files changed (keep the list short)
