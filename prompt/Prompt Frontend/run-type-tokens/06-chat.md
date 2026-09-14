# GLM 5.3 Flash — Prompt 06 — Chat (type + color tokens)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01–05, 07–10.

---

You are a Flutter refactor agent. Extract **hardcoded font size / weight / leftover surface colors** in the **chat module only**. Do not restyle. Same pixels as today. Less `TextStyle`, not more widgets.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`

## Own only

```text
vithey_app/lib/modules/chat/**
```

Includes: chat list, detail, composer, folders, call sheet, shared content. **Not** chatbot (separate module).

## Requirements

1. Replace repeated `TextStyle(fontSize:, fontWeight:, color:)` with `context.text.*` (+ `copyWith` only for color / overflow / rare one-off sizes).
2. Map sizes via DESIGN.md. Rare sizes (`9` on badges, etc.) stay `copyWith(fontSize: …)`.
3. Prefer theme roles over raw `VitheyType` / `VitheyWeight` at every call site.
4. Replace leftover surface hex / `Colors.teal` / panel white-black with `AppColors` / `context.appColors` / `scheme`.
5. Keep white/black on media/video overlays inside shared content when that is ink on a thumbnail.

## Do not

- Create text wrapper widgets
- Change padding, radii, layout, routes, STOMP, or message logic
- Normalize sizes
- Edit `modules/chatbot/**` or other modules / `core/`

## Verify

```text
rg "fontSize:" vithey_app/lib/modules/chat
rg "FontWeight\." vithey_app/lib/modules/chat
rg "Color\(0x|Colors\.(teal|white|black)" vithey_app/lib/modules/chat
```

Near-zero leftovers except justified one-offs / overlays. `dart analyze` clean on owned files.

## Stop when

Chat uses `context.text` for repeated type; no UI change; short summary + intentional leftovers.
