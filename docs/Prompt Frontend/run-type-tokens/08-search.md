# GLM 5.3 Flash — Prompt 08 — Search (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–07, 09–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **search module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/search/**
```

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes / highlight spans).
2. Map sizes via DESIGN.md for person/job/post/video tiles and section headers.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / panel white-black with `AppColors` / `context.appColors` / `scheme`. Keep white/black on video thumbnail overlays if ink-on-media.
5. Highlight text: keep highlight color on `AppColors.primary` (or existing semantic); do not invent new highlight hex.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or search logic
- Normalize sizes
- Edit other modules or `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/search
rg "FontWeight\." vithey_app/lib/modules/search
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/search
```

Near-zero leftovers except justified one-offs / overlays. `dart analyze` clean on owned files.

## Stop when

Search uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
