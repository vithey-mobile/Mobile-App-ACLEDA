# GLM 5.3 Flash — Prompt 09 — Settings (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–08, 10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **settings module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/settings/**
```

Includes: settings home, account, security, privacy, notifications prefs, about, help, change password, language sheet.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md (`15/w600` rows → `titleSmall`, `13` muted → `bodySmall`, `22` sheet titles → `headlineSmall`).
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / `Colors.white` card panels with `context.appColors.cardSurface` (or existing semantic). Keep avatar camera badge white-on-primary as `scheme.onPrimary` if identical.
5. Do not hardcode light-only white cards — dark mode must stay intentional.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or settings logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/settings
rg "FontWeight\." vithey_app/lib/modules/settings
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/settings
```

Near-zero leftovers except justified one-offs. `dart analyze` clean on owned files.

## Stop when

Settings uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
