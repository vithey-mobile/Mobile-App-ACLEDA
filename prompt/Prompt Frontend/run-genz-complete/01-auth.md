# GLM 5.3 Flash — Prompt 01 — Auth (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 02–10.

---

You are a Flutter UI agent. Restyle **auth module only** to GenZ smart screens.

## Read

`prompt/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`

## Own only

```text
vithey_app/lib/modules/auth/**
```

## Screens

Splash, Select Language, Onboarding, Login, Register, Forgot Password, Google chooser/confirm, Startup (skills / interests / discovery).

## Requirements

1. Kit CTAs/fields only (`CustomButton`, `VitheyField`).
2. App bar / skip / back icons → `VitheyIconButton` (or same chrome pattern).
3. Cards / language tiles / interest cards → radius ≥ `VitheyRadii.card`.
4. Onboarding CTA pill stays centered icon+label group.
5. Loading / validation / error states keep working; improve visual only.
6. Dark mode: no white hardcoded panels.
7. Coming-soon / disabled stays honest if present.

## Do not

- Change auth flows, tokens, mock auth behavior
- Edit other modules

## Stop when

Auth looks GenZ-consistent; `dart analyze` clean on owned files.
