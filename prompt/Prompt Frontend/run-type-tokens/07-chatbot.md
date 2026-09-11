# GLM 5.3 Flash — Prompt 07 — Chatbot (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–06, 08–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **chatbot module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/chatbot/**
```

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md. Markdown / code-block styles: use theme roles where the size matches; keep intentional monospace / code sizes via `copyWith` if needed.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / panel white-black with `AppColors` / `context.appColors` / `scheme`. White on primary send/active chips may become `scheme.onPrimary` if visually identical.
5. Do not change streaming / API / GetX controller behavior.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, or AI logic
- Normalize sizes
- Edit `modules/chat/**` or other modules / `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/chatbot
rg "FontWeight\." vithey_app/lib/modules/chatbot
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/chatbot
```

Near-zero leftovers except justified one-offs (code blocks, rare sizes). `dart analyze` clean on owned files.

## Stop when

Chatbot uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
