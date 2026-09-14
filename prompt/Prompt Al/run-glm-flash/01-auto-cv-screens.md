# GLM 5.3 Flash — Prompt 01 — Auto Create CV screens

Copy everything below the line into a **new** GLM chat. Run **after** Prompt 00. Parallel OK with 02–05.

---

You are a Flutter UI agent. Implement **Block 1 — Auto Create CV** screens with **mock data only**.

## Read first

- `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
- Block 1 in `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (AI-CV-01…08)
- Existing: `vithey_app/lib/modules/jobs/ai_cv/**`, `apply_cv_screen.dart`, `apply_cv_controller.dart`

## Own only

```text
vithey_app/lib/modules/jobs/ai_cv/**
vithey_app/lib/modules/jobs/apply_cv_*.dart
vithey_app/lib/modules/jobs/widgets/**   # only CV/upload related widgets you need
vithey_app/lib/modules/profile/**        # ONLY a “Generate with AI” entry on CV / About — do not restyle whole profile
vithey_app/lib/routes/app_pages.dart     # only if route missing
vithey_app/lib/core/constants/app_routes.dart  # only if route constant missing
```

Do not edit Home feed, chatbot, or applicant match UI (those are prompts 02/04/05).

## Goal

1. **Apply Step 1** keeps Manual upload/update **and** **Create CV with AI**.
2. AI wizard: generating → editable draft → confirm → return to **same job** with CV selected → Review → Submit.
3. **Profile** entry: Generate with AI (can open same wizard with `returnToApply: false` or save-only).
4. Empty/incomplete profile → clear message (AI-CV-09), no invented employers/degrees.

## Must preserve

- Route `/apply-cv/ai-create`
- `ApplyCvArgs.preferredCvFileId` + `openOnReview`
- Manual path (picker + saved CV) never blocked by AI

## Polish / complete

- Primary confirm: **Use for this job & continue** (open Review for that `jobPostId`)
- Secondary: **Save CV only**
- Optional: “Regenerate summary” (mock: reshuffle fixture wording, still profile-only facts)
- Use Vithey kit buttons/fields — no module `shadcn_flutter` imports

## Stop when

- Apply → Create with AI → confirm → Review → Submit works on mock jobs (`post-10` / `post-19` / `post-20`)
- Profile has a Generate with AI entry that saves mock CV
- `dart analyze` clean on owned files
