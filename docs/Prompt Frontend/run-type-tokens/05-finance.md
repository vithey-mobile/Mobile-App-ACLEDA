# GLM 5.3 Flash — Prompt 05 — Finance (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–04, 06–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **finance module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/finance/**
```

Includes: finance home, payment, invoices, student verification.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md (`22` titles → `headlineSmall`, `12` meta → `labelMedium`, etc.).
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Status colors stay on `AppColors` (`paid`, `unpaid`, `pending`, `error`, `success`) — do not invent new status hex.
5. Replace leftover surface hex / panel white-black with `AppColors` / `context.appColors` / `scheme`.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or payment/verification logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/finance
rg "FontWeight\." vithey_app/lib/modules/finance
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/finance
```

Near-zero leftovers except justified one-offs. `dart analyze` clean on owned files.

## Stop when

Finance uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
