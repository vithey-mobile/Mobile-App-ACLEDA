# GLM 5.3 Flash — Prompt 00 (TOKENS + KIT — RUN FIRST)

Copy everything below the line into a **new** GLM chat. Finish before 01–10.

---

You are a Flutter design-system agent for Vithey. Implement **shared GenZ tokens + icon chrome only**. Do not restyle feature modules yet.

## Read

- `prompt/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/core/theme/`, `vithey_app/lib/core/widgets/`, `vithey_app/lib/app.dart`

## Own only

```text
vithey_app/lib/core/theme/**
vithey_app/lib/core/widgets/**
vithey_app/lib/app.dart   # only if Theme radius / shad radius need bump
vithey_app/.env.example   # do not touch unless documenting nothing
```

## Do this

### 1) `VitheyRadii` (new file under theme or widgets)

Export constants matching DESIGN_SYSTEM:

- `iconSquircle` 18
- `iconButton` 48 (min size)
- `card` 18
- `sheet` 24
- `pill` 24
- `field` 16
- `media` 14

### 2) `VitheyIconButton` or `VitheyIconChrome`

Reusable circular/squircle icon button:

- min 48×48 tap
- soft primary wash fill
- icon 20–22
- variants: `neutral`, `primary`, `destructive`
- used by AppBars later

Export from `widgets.dart`.

### 3) Align kit radii

Update existing widgets to use `VitheyRadii` where they hardcode 8/12:

- `CustomButton` / theme radius (already ~1.0 shad — keep pill-ish CTAs)
- `VitheyCard`, `VitheySearchPill`, `VitheyDialog`, `VitheyField` borders
- `UserAvatar` unchanged (circle)

### 4) Semantic colors

Do **not** change primary hex. Ensure dark `cardSurface` / `border` remain readable.

### 5) Document

Add a short section to `COMPONENT_KIT.md`: GenZ radii + `VitheyIconButton` when to use.

## Stop when

- Tokens + icon chrome compile and are exported
- Kit cards/pills/dialogs use larger radii
- `dart analyze` clean on `core/`
- Print list of new symbols

Do **not** edit `modules/**` in this chat.
