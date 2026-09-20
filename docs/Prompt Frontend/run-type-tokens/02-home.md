# GLM 5.3 Flash — Prompt 02 — Home (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01, 03–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **home module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/home/**
```

Includes: home feed, shell, reels, create post, post detail, notifications.

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md (`15/w600` → `titleSmall`, `13` muted → `bodySmall`, `16` → `titleMedium` or `bodyLarge`, `22` → `headlineSmall`, etc.).
3. Do **not** sprinkle `VitheyType` + `VitheyWeight` into new 5-line `TextStyle` blobs — prefer theme roles.
4. Replace leftover surface `Color(0xFF…)`, `Colors.teal`, panel `Colors.white`/`Colors.black` with `AppColors` / `context.appColors` / `scheme`.
5. **Keep** white/black on reels / media fullscreen / photo overlays (ink on video). Those are not theme surfaces.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or business logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/home
rg "FontWeight\." vithey_app/lib/modules/home
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/home
```

Near-zero leftovers except justified one-offs / overlay ink. `dart analyze` clean on owned files.

## Stop when

Home uses `context.text` for repeated type; no UI change; short summary + intentional leftovers (e.g. reels overlay).
