# GLM 5.3 Flash — Prompt 10 — Map (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–09.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **map module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/map/**
```

Includes: map screen, add place. Do **not** change `GoogleMap` / platform marker APIs — only Flutter `Text` / surface colors around them.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes). Prefer `Theme.of(context).textTheme` / `context.text` over `Get.textTheme` when touching a style (same roles).
2. Map sizes via DESIGN.md.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / panel white-black with `AppColors` / `context.appColors` / `scheme`.
5. Leave Google Maps platform views and native marker styling alone.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, map controller business logic, or API keys
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/map
rg "FontWeight\." vithey_app/lib/modules/map
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/map
```

Near-zero leftovers except justified one-offs / platform. `dart analyze` clean on owned files.

## Stop when

Map Flutter chrome uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
