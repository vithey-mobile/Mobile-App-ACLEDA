# GLM 5.3 Flash — Prompt 11 — Sweep + completion (LAST)

Copy everything below `---` into a **new** chat **after** 01–10 are merged.

---

You are a Flutter completion agent. Make the **type + color token** pass actually complete across the app. Do not restyle. Same pixels. Less leftover hardcoding.

## Read

`prompt/Prompt Frontend/run-type-tokens/DESIGN.md`  
`prompt/Prompt Frontend/COMPONENT_KIT.md`

## Own

Any leftover under:

```text
vithey_app/lib/modules/**
vithey_app/lib/core/widgets/**
vithey_app/lib/core/alerts/**
vithey_app/lib/core/theme/**
```

Tiny kit/theme fixes only if modules need a missing export or a role that Prompt 00 missed. Do not invent new text widgets.

## Do this

### 1) Kill type leftovers

Search and fix repeated inline styles still using raw:

- `fontSize: <number>`
- `FontWeight.w400|w500|w600|w700|bold`

Prefer `context.text.*` (+ `copyWith` for color / rare sizes). Do **not** normalize sizes. Do **not** add tokens for 9 / 11.5 / 17 / 24 / 28.

### 2) Kill surface color leftovers

Search and fix (when they are theme surfaces, not media overlays):

- `Colors.teal` / `0xFF00BFA5` / random primary hex
- Panel `Colors.white` / `Colors.black` / `Colors.grey` that should be `AppColors` / `context.appColors`
- Duplicate `Color(0xFF…)` that already exists on `AppColors`

**Keep intentional exceptions:**

- Reels / media fullscreen / photo overlay ink
- PDF builders
- `lib/data/fixtures/**` hex
- `GoogleMap` / platform views
- Generated files

### 3) Docs

Update `prompt/Prompt Frontend/run-type-tokens/README.md` status table: mark 00–11 **Done** with date when finished.

Ensure `COMPONENT_KIT.md` still has the Typography tokens section (add if Prompt 00 missed it).

### 4) Verify

```text
rg "fontSize:" vithey_app/lib/modules vithey_app/lib/core/widgets vithey_app/lib/core/alerts
rg "FontWeight\." vithey_app/lib/modules vithey_app/lib/core/widgets vithey_app/lib/core/alerts
rg "Colors\.teal|0xFF00BFA5" vithey_app/lib
dart analyze   # on touched paths; clean errors you introduced
```

List remaining intentional exceptions with reason.

## Stop when

- Near-zero repeated inline type in modules + kit
- README status complete
- Short summary of modules cleaned + known exceptions
- No UI visual redesign
