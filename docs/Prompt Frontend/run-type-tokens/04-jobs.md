# GLM 5.3 Flash — Prompt 04 — Jobs (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–03, 05–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **jobs module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/jobs/**
```

Includes: apply CV, application status, AI CV screens, job match widgets. **Skip** PDF builders (`**/cv_pdf_builder.dart` and similar) — leave their hex/type alone.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md. Keep w800 only where it already exists.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / `Colors.teal` / panel white-black with `AppColors` / `context.appColors` / `scheme`.
5. Do not touch fixture hex under `lib/data/`.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or apply/AI business logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/jobs
rg "FontWeight\." vithey_app/lib/modules/jobs
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/jobs
```

Near-zero leftovers except PDF / justified one-offs. `dart analyze` clean on owned files.

## Stop when

Jobs uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
