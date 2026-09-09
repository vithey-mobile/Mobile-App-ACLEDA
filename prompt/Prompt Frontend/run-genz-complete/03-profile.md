# GLM 5.3 Flash — Prompt 03 — Profile (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with other modules.

---

You are a Flutter UI agent. Restyle **profile module only** to GenZ smart screens.

## Own only

```text
vithey_app/lib/modules/profile/**
```

## Screens

Profile home / tabs (All, Jobs, Reels, Applied), Edit Profile, Job Applicants, Applicant Detail, CV preview screens, Scan QR, section sheets.

## Requirements

1. Edit / Verify / icon actions → rounder icon chrome (48 tap).
2. Tab chips / filters → `VitheyFilterChips` or pill radius 24.
3. Job / applied / reel grids: card radius ≥ 16; Create reel tile matches.
4. Applicants list: soft cards, StatusBadge, AI match badge chrome if present stays readable.
5. Sheets/dialogs → Vithey dialogs / action sheets.
6. Empty Applied Jobs / empty applicants → `EmptyStateWidget`.
7. Dark mode surfaces via `context.appColors` only.
8. Keep GetX navigation and mock data wiring.

## Stop when

Profile family GenZ-consistent; analyze clean.
