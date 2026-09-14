# GLM 5.3 Flash — Prompt 01 — Auth (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 02–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **auth module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/auth/**
```

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md (`15/w600` → `titleSmall`, `13` muted → `bodySmall`, `16` → `titleMedium` or `bodyLarge`, `22` → `headlineSmall`, etc.).
3. Do **not** sprinkle `VitheyType` + `VitheyWeight` into new 5-line `TextStyle` blobs — prefer theme roles.
4. Replace leftover surface `Color(0xFF…)`, `Colors.teal`, panel `Colors.white`/`Colors.black` with `AppColors` / `context.appColors` / `scheme`. Keep overlay ink on photos/videos if any.
5. Import theme via existing patterns (`app_semantic_colors.dart` for `context.text` / `context.appColors`).

## Do not

- Create text wrapper widgets (`VitheyTitle`, `AppText`, …)
- Change padding, radii, layout, routes, auth flows, or business logic
- Normalize sizes (13 stays 13)
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/auth
rg "FontWeight\." vithey_app/lib/modules/auth
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/auth
```

Near-zero leftovers except justified one-offs (rare sizes, overlay ink). `dart analyze` clean on owned files.

## Stop when

Auth uses `context.text` for repeated type; no UI change; short summary of files touched + intentional leftovers.
