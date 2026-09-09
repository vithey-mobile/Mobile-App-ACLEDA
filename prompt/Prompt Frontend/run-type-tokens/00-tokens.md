# GLM 5.3 Flash — Prompt 00 (TYPE + COLOR TOKENS — RUN FIRST)

Copy everything below the line into a **new** GLM chat. Finish before 01–10.

---

You are a Flutter design-system agent for Vithey. Implement **shared typography tokens + theme `textTheme` + leftover surface colors in kit/alerts only**. Do not restyle feature modules yet. Do not change how anything looks.

## Read

- `prompt/Prompt Frontend/run-type-tokens/DESIGN.md`
- `prompt/Prompt Frontend/COMPONENT_KIT.md`
- `vithey_app/lib/core/theme/`
- `vithey_app/lib/core/widgets/`
- `vithey_app/lib/core/alerts/`
- `vithey_app/lib/core/constants/app_colors.dart`

## Own only

```text
vithey_app/lib/core/theme/**
vithey_app/lib/core/widgets/**
vithey_app/lib/core/alerts/**
prompt/Prompt Frontend/COMPONENT_KIT.md   # short Typography section only
```

Do **not** edit `vithey_app/lib/modules/**` in this chat.

## Hard rules

- **Same pixels as today.** Do not snap font sizes. Do not change padding, radii, layout, routes, or business logic.
- **Less code, not more.** Do **not** create `VitheyTitle`, `AppText`, or any text widget wrappers.
- Prefer `context.text.*` at call sites over new 5-line `TextStyle(fontSize: VitheyType…)` blobs.
- Colors: no new palette. Use existing `AppColors` + `context.appColors`.

## Do this

### 1) Create `vithey_type.dart` under `lib/core/theme/`

```dart
/// Typography size tokens — matches current Vithey call sites (DESIGN.md).
abstract final class VitheyType {
  static const double micro = 10;
  static const double caption = 11;
  static const double meta = 12;
  static const double subtitle = 13;
  static const double body = 14;
  static const double titleSm = 15;
  static const double title = 16;
  static const double titleLg = 18;
  static const double headline = 20;
  static const double display = 22;
}

/// Font weight tokens.
abstract final class VitheyWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
```

Import `package:flutter/material.dart`. Keep names exactly as above.

### 2) Wire `textTheme` in light + dark themes

In `light_theme.dart` and `dark_theme.dart`, set `textTheme` using `VitheyType` + `VitheyWeight` and semantic colors:

| Role | Size | Weight | Color |
|------|------|--------|-------|
| `headlineSmall` | display 22 | bold | heading |
| `titleLarge` | titleLg 18 | bold | heading |
| `titleMedium` | title 16 | semibold | heading |
| `titleSmall` | titleSm 15 | semibold | heading |
| `bodyLarge` | title 16 | regular | heading |
| `bodyMedium` | body 14 | regular | heading |
| `bodySmall` | subtitle 13 | regular | muted |
| `labelLarge` | body 14 | semibold | heading |
| `labelMedium` | meta 12 | medium | muted |
| `labelSmall` | caption 11 | medium | muted |

Also replace any hardcoded `fontSize: 16` in `InputDecorationTheme.hintStyle` with `VitheyType.title` (same px). Replace sheet top radius `24` with `VitheyRadii.sheet` if still literal.

Keep brand primary hex unchanged. Ensure dark `cardSurface` / `border` stay readable.

### 3) Update kit + alerts to use `context.text`

Under `lib/core/widgets/**` and `lib/core/alerts/**`, replace repeated:

```dart
TextStyle(fontSize: …, fontWeight: …, color: …)
```

with:

```dart
context.text.titleSmall?.copyWith(color: …)  // etc.
```

Match the DESIGN.md size → role table. Examples:

- List tile title (~15 / w600) → `context.text.titleSmall`
- List tile subtitle (~13 / muted) → `context.text.bodySmall`
- Field / composer body (~16) → `context.text.bodyLarge` or `titleMedium` as appropriate
- Meta / caption (~11–12) → `labelSmall` / `labelMedium`

Also replace leftover surface `Colors.white` / `Colors.black` / random hex in kit/alerts with `AppColors` / `context.appColors` / `scheme` **except** intentional overlay ink (scrims, white on media).

Do **not** invent tokens for rare sizes (9, 11.5, 17, 24, 28) — use `copyWith(fontSize: …)`.

### 4) Document

Add a short **Typography tokens** section to `prompt/Prompt Frontend/COMPONENT_KIT.md`:

- Prefer `context.text.*` over inline `TextStyle(fontSize:, fontWeight:)`
- Sizes live in `VitheyType`; weights in `VitheyWeight`; themes wire them
- Do not add text wrapper widgets
- Link to `run-type-tokens/DESIGN.md`

## Stop when

- `VitheyType` + `VitheyWeight` exist and compile
- Light + dark `textTheme` wired
- Kit widgets + alerts use `context.text` for repeated styles
- `COMPONENT_KIT.md` has Typography section
- `dart analyze` clean on owned paths
- Print list of new symbols + files touched

Do **not** edit `modules/**` in this chat.
