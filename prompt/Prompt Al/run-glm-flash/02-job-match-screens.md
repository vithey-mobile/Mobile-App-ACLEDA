# GLM 5.3 Flash — Prompt 02 — Job Apply Match Score screens

Copy everything below the line into a **new** GLM chat. Run **after** Prompt 00. Parallel OK with 01, 03–05.

---

You are a Flutter UI agent. Implement **Block 5 — Job Apply Match Score** with **mock data only**.

## Read first

- `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
- Block 5 in `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (AI-JOB-01…13)
- `AiRepository.matchJob` + `ai_job_match_fixtures.dart` from Prompt 00
- Apply review: `vithey_app/lib/modules/jobs/apply_cv_screen.dart` (`_ReviewStep`)
- Poster: `job_applicants_screen.dart`, `applicant_detail_screen.dart`

## Own only

```text
vithey_app/lib/modules/jobs/apply_cv_controller.dart   # load match on review only
vithey_app/lib/modules/jobs/apply_cv_screen.dart       # Review match card only (coordinate carefully — prefer new widget file)
vithey_app/lib/modules/jobs/widgets/job_match_*.dart   # NEW widgets preferred
vithey_app/lib/modules/profile/job_applicants_screen.dart
vithey_app/lib/modules/profile/applicant_detail_screen.dart
vithey_app/lib/modules/profile/widgets/**              # AI score badge / panel only
vithey_app/lib/data/fixtures/ai_job_match_fixtures.dart  # append only if needed
```

If you must touch `apply_cv_screen.dart`, add a single child widget call — do not rewrite upload/AI CV CTAs (Prompt 01).

## Goal

1. **Apply Review step**: card with score 0–100, label, matched skills, gaps, 3–5 reasons, disclaimer (“AI assist only — not a hiring decision”).
2. Gate with `FeatureFlags` / `USE_AI_JOB_MATCH`.
3. Call `AiRepository.matchJob(jobPostId: …)` when entering Review (mock delay OK).
4. **Poster applicants list**: AI match badge; sort highest score first (mock).
5. **Applicant detail**: certify panel (score + gaps + reasons + disclaimer).
6. CTA **Improve match** → `Get.toNamed(AppRoutes.chatbot, …)` or suggestion topic JOB (deep-link args if pattern exists; else snackbar + navigate chatbot).

## UX rules

- One card, not a dashboard.
- Use `StatusBadge` / Vithey kit.
- Low score when skills empty — copy: add skills to improve (AI-JOB acceptance).

## Stop when

- Review shows mock match for apply-eligible jobs
- Poster list shows badges + sort
- Disclaimer always visible
- `dart analyze` clean on owned files
