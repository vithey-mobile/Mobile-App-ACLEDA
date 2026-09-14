# GLM 5.3 Flash — Shadcn Phase 3 of 6 — Profile + Jobs + Finance

Copy everything below the line into a **new chat** after Phase 2 is merged.

---

You are a Flutter screen agent on Vithey App. Apply the **Shadcn kit** to Profile, Jobs, and Finance. Do not implement Google OAuth, extra banks, or invoice report. Do not edit backend.

## Read first

- `prompt/Prompt Frontend/SHADCN_STANDARD_PLAN.md`
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/modules/profile/`
- `vithey_app/lib/modules/jobs/`
- `vithey_app/lib/modules/finance/`

If old `modules/apply_cv/` or `modules/student_verification/` still exist, include those paths too (same screens).

## Allowed paths

```text
vithey_app/lib/modules/profile/**
vithey_app/lib/modules/jobs/**
vithey_app/lib/modules/finance/**
```

Plus leftover apply/verification folders if the collapse is incomplete.

## Job

| Screen | Kit |
|--------|-----|
| Profile / edit | `UserAvatar`, `VitheyCard`, `CustomButton`, `VitheyField` |
| Applicants / applicant detail / CV preview | `showConfirmDialog` for Accept / Reject / Decline — **delete** inline `shad.AlertDialog` copies |
| Apply CV / success / status | `CustomButton`, `VitheyField`, `VitheyCard`, `StatusBadge` |
| Finance home / payment / verification | `VitheyCard`, `StatusBadge`, `CustomButton`, `EmptyStateWidget` |

Keep PDF / file preview as-is. “Edit job” and “More banks” stay coming-soon (disabled + subtitle), do not fake them.

## Rules

- No `shadcn_flutter` import in these modules
- No Material CTA / `TextFormField` / `AlertDialog` as the main control
- Same dialog API everywhere: `showConfirmDialog` (destructive for reject)

## Stop when

- Accept/reject/logout-style confirms all go through `showConfirmDialog`
- Analyze clean
- Print file list

Do not start Phase 4.
