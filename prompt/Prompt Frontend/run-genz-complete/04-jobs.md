# GLM 5.3 Flash — Prompt 04 — Jobs / Apply (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with other modules.

---

You are a Flutter UI agent. Restyle **jobs module only** (Apply Job + AI CV) to GenZ smart screens.

## Own only

```text
vithey_app/lib/modules/jobs/**
```

## Screens

Apply upload / review / success / status, AI Create CV wizard, job widgets (upload zone, stepper, review cards).

## Requirements

1. Stepper + CTAs: `CustomButton`; continue/submit full-width, radius per kit.
2. Upload zone: dashed border radius ≥ 16; icon in soft primary circle.
3. **Create CV with AI** outline button keeps clear hierarchy under manual upload.
4. AI CV editor fields → `VitheyField`; section cards radius 18.
5. Match score card (if present): soft card + StatusBadge; disclaimer muted.
6. Success / status timelines: rounder markers, kit buttons.
7. All loading/error/disabled states intact.
8. Do not break AI confirm → return to same job / submit logic.

## Stop when

Jobs/Apply/AI CV GenZ-consistent; analyze clean.
