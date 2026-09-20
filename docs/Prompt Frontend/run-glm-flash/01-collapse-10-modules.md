# GLM 5.3 Flash — Prompt 1 of 3

Copy everything below the line into a new chat. Run this **first**. Do not start Prompt 2 until this is done.

---

You are a Flutter refactor agent in the Vithey repo. Do **only** a folder move. Do not restyle UI. Do not add Map API. Do not edit backend.

## Goal

Collapse `vithey_app/lib/modules/` from ~21 folders to **exactly 10**. Routes, GetX class names, and `AppRoutes` constants stay the same. Only paths and imports change. Leave `lib/data/` and `lib/core/` in place.

## Target (only these 10 top-level folders)

```text
vithey_app/lib/modules/
├── auth/
├── home/
├── profile/
├── jobs/
├── finance/
├── chat/
├── chatbot/
├── search/
├── settings/
└── map/
```

## Exact moves (`git mv`)

| From | To |
|------|-----|
| `modules/splash/` | `modules/auth/splash/` |
| `modules/select_language/` | `modules/auth/language/` |
| `modules/onboarding/` | `modules/auth/onboarding/` |
| `modules/startup/` | `modules/auth/startup/` |
| existing `modules/auth/*` files | stay in `modules/auth/` (do not nest login/register) |
| `modules/shell/` | `modules/home/shell/` |
| `modules/reels/` | `modules/home/reels/` |
| `modules/create_post/` | `modules/home/create_post/` |
| `modules/post_detail/` | `modules/home/post_detail/` |
| `modules/notification/` | `modules/home/notification/` |
| existing `modules/home/*` | stay in `modules/home/` |
| `modules/apply_cv/` | `modules/jobs/` (rename folder to `jobs`; keep file names) |
| `modules/student_verification/` | `modules/finance/verification/` |
| existing `modules/finance/*` | stay in `modules/finance/` |
| `modules/add_place/` | `modules/map/add_place/` |
| existing `modules/map/*` | stay in `modules/map/` |
| `profile/`, `chat/`, `chatbot/`, `search/`, `settings/` | do not move |

Rules:

- Do **not** merge chat + chatbot.
- Do **not** move `settings/notification_preferences/` (prefs stay in settings).
- Do **not** move `job_applicants_screen` / `applicant_detail_screen` out of profile.
- Do **not** change strings in `vithey_app/lib/core/constants/app_routes.dart`.
- After moves, delete empty old folders so only the 10 remain.

## Then fix imports

Update every Dart import that pointed at old paths. Main files:

- `vithey_app/lib/routes/app_pages.dart`
- any `package:aub_connect_app/modules/...` import in `lib/`

Package name is `aub_connect_app`.

## Stop when

- `vithey_app/lib/modules/` has exactly 10 directories
- `dart analyze` on changed files has no import errors you introduced
- You print a short list of old → new paths

Do not continue to Map UI or GenZ restyle.
