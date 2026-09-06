# GLM 5.3 Flash — Prompt 03 — Profile (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–02, 04–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **profile module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/profile/**
```

Includes: profile home, edit, CV, reels grid, applicants, analytics, QR, section sheets.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md. Keep rare sizes (`11.5`, `28`, etc.) as `copyWith(fontSize: …)` — do not invent tokens.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / `Colors.teal` / panel white-black with `AppColors` / `context.appColors` / `scheme`. Keep cover/photo overlay ink if intentional.
5. Leave PDF builders alone if present under this tree.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or business logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/profile
rg "FontWeight\." vithey_app/lib/modules/profile
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/profile
```

Near-zero leftovers except justified one-offs / overlays / PDF. `dart analyze` clean on owned files.

## Stop when

Profile uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
