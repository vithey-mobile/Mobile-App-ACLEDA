# 02 — Select Language

Build the **Select Language** screen for Vithey App in Flutter.

This screen appears **immediately after Splash** on first launch (before Onboarding / Auth), so the user can choose the app language.


## Design references

| Asset | Path | Use |
| --- | --- | --- |
| **Full layout** | [`../../screen image/auth/Select Language Screen.png`](../../screen%20image/auth/Select%20Language%20Screen.png) | Composition, wave header, list, dots, CTA |
| **English flag** | [`../../screen image/auth/english_language.png`](../../screen%20image/auth/english_language.png) | Circular flag for English (US) |
| **Khmer flag** | [`../../screen image/auth/khmer_language.png`](../../screen%20image/auth/khmer_language.png) | Circular flag for Khmer |

![Select Language Screen](../../screen%20image/auth/Select%20Language%20Screen.png)

### Flutter asset copy

| Prompt / design file | App asset | Constant |
| --- | --- | --- |
| `english_language.png` | `assets/images/locale/english_language.png` | `AppAssets.englishLanguage` |
| `khmer_language.png` | `assets/images/locale/khmer_language.png` | `AppAssets.khmerLanguage` |

Register folder (or files) under `pubspec.yaml` → `flutter.assets`.

Do **not** redraw flags — use the provided PNGs, clipped to a circle in UI.

---

## Quick info

| Field | Value |
| --- | --- |
| Screen ID | `02` |
| Route | `AppRoutes.selectLanguage` (suggested: `/select-language`) |
| Flutter module | `lib/modules/locale/` or `lib/modules/select_language/` |
| Entry | Splash → when language not yet chosen (first launch) |
| Next | Onboarding (first launch) or Auth (if onboarding already done) |
| Backend | — (local preference only) |
| Auth required | No |
| Visual | `screen image/auth/Select Language Screen.png` |
| Prompt | `Screen prompt/auth/02-select-language-prompt.md` |

---

## Goal

Let the user pick **English (US)** or **Khmer**, persist the choice locally, apply app locale, then continue the existing post-Splash flow (Onboarding → Auth, or Auth if onboarding is complete).

---

## Placement in flow

`text
App launch
    → Splash
    → Select Language   â† this screen (once / until language saved)
    → Onboarding (first time) or Auth (returning)
    → ...
`

| From | Condition | To |
| --- | --- | --- |
| Splash | No saved language preference | Select Language |
| Splash | Language already saved | Existing Splash rules (Onboarding / Auth / Home) |
| Select Language | Skip or Apply | Onboarding if not completed; else Auth |
| Select Language | Skip | Keep default locale (**English**), mark language step done |

Persist a flag such as `language_selected` (or store non-null `app_locale`) in `LocalStorageService` / `SharedPreferences` so Splash does not show this screen again.

---

## Layout (match mock)

`
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Skip                          →    â”‚  Top-right, on teal header
â”‚         [ teal wave header ]        â”‚  Organic waves into white body
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚         Select Language             â”‚  Bold, centered, dark
â”‚  Choose your preferred language     â”‚  Muted secondary, centered
â”‚         for the app.                â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚ ðŸ‡ºðŸ‡¸ English (US)          âœ“  â”‚  â”‚  Selected: teal check
â”‚  â”‚    English                    â”‚  â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚
â”‚  â”‚ ðŸ‡°ðŸ‡­ Khmer                    â”‚  â”‚
â”‚  â”‚    áž—áž¶ážŸáž¶ážáŸ’áž˜áŸ‚ážš                 â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚            â— â—‹ â—‹ â—‹                  â”‚  4 dots; first active (teal)
â”‚                                     â”‚
â”‚      [ ðŸŒ Apply Language ]          â”‚  Primary teal CTA + globe icon
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
`

### Header

| Spec | Value |
| --- | --- |
| Background | Teal / cyan brand block with **organic wave** transition into white body (same family as Onboarding / auth teal wave) |
| Skip | Top-**right**, white text on teal; generous tap target |
| Safe area | Respect status bar inset |

Reuse existing wave/header widgets where possible (`AuthWaveHeader`, onboarding background patterns) rather than inventing a new wave style.

### Title block

| Element | Copy / style |
| --- | --- |
| Title | **Select Language** — bold, dark heading, centered, ~22–24sp |
| Subtitle | **Choose your preferred language for the app.** — secondary grey, centered, ~14sp |

> Mock typo: image may show “fot” — ship correct English **for**.

### Language list card

| Spec | Value |
| --- | --- |
| Container | White / scaffold surface, thin grey border, rounded corners (~12–16) |
| Horizontal pad | ~20–24px page margin |
| Rows | Exactly **two** options (English, Khmer) |
| Divider | Hairline between rows |
| Row layout | Circular flag (left) Â· title + native subtitle (center) Â· trailing check if selected (right) |

#### Options

| Code | Title | Subtitle | Flag asset | Default |
| --- | --- | --- | --- | --- |
| `en` | English (US) | English | `english_language.png` | **Yes** (initial selection) |
| `km` | Khmer | áž—áž¶ážŸáž¶ážáŸ’áž˜áŸ‚ážš | `khmer_language.png` | No |

#### Flag presentation

- Clip asset to a **circle** (~40–44px diameter)
- `BoxFit.cover`
- Optional thin light border if needed for contrast on white

#### Selection

- Single-select; tapping a row updates selection immediately
- Selected row shows a **teal check** (`Icons.check` or equivalent) on the trailing side
- Unselected row: no check (empty trailing space to keep alignment)
- Title: bold dark; subtitle: secondary grey (readable, not too light)

### Page indicators

| Spec | Value |
| --- | --- |
| Count | **4** dots |
| Active | Index **0** (this screen) — teal filled |
| Inactive | Light grey |
| Meaning | Step 1 of intro sequence: Language → Onboarding slides 1–3 |

Keep dots centered below the card. Do not make dots tappable unless product later unifies Language + Onboarding into one pager.

### Primary CTA

| Spec | Value |
| --- | --- |
| Label | **Apply Language** |
| Icon | Globe (`Icons.language` / `Icons.public`) leading, white |
| Style | Full-width primary teal fill, white bold text, ~48 height, ~12 radius |
| Margins | ~20–24px horizontal; comfortable bottom safe inset |

---

## User actions

| Action | Result |
| --- | --- |
| Tap **English (US)** | Select `en` (show check) |
| Tap **Khmer** | Select `km` (show check) |
| Tap **Apply Language** | Persist locale + `language_selected`; apply `Get.updateLocale` / app locale; navigate next |
| Tap **Skip** | Persist default `en` (or leave default), mark language step done; navigate next **without** requiring Apply |

Navigation after Apply / Skip uses the same post-Splash rules as today (minus this gate): Onboarding if incomplete, else Auth.

---

## Locale behavior

- Supported locales: `Locale('en', 'US')`, `Locale('km', 'KH')` (or `Locale('km')` if KH country unused)
- Persist chosen language code in local storage
- On Apply: update GetX / Flutter locale so subsequent Onboarding / Auth strings resolve correctly
- If app i18n strings for Khmer are incomplete, still store preference and fall back gracefully — do not block navigation

---

## Visual style

| Token | Direction |
| --- | --- |
| Header | Brand teal / cyan + wave into white |
| Body | White / `bodyBackground` |
| Primary / active | Vithey teal (~`AppColors.primary`) |
| Heading | Dark charcoal |
| Secondary | Darker muted grey (readable light + dark) |
| Card border | Cool light grey |
| Light / dark | Support both; header may stay branded teal in dark mode if Onboarding does |

Do not add search, more languages, or a back chevron (Skip is the escape).

---

## Responsive

- `SafeArea` top and bottom
- Center content on tall phones; scroll if text scale / small height requires it
- Keep CTA reachable above home indicator
- Limit card width on tablets (~420 max)

---

## Architecture (suggested)

`text
lib/modules/select_language/
  select_language_screen.dart
  select_language_controller.dart
  select_language_binding.dart

lib/core/constants/app_assets.dart   # englishLanguage, khmerLanguage
lib/core/services/...                  # locale / local storage helpers
`

- Controller holds `selectedLocale` (`en` | `km`)
- `applyLanguage()` / `skip()` write storage then navigate
- Splash reads storage before routing

---

## Splash change (required companion)

Update Splash routing:

1. Branding delay + token check (unchanged)
2. If **no language preference** → `Select Language` (even before onboarding check)
3. Else existing logic: token → Home; else onboarding / Auth

Do not show Select Language again once preference is saved (unless Settings later adds “Change language”).

---

## Accessibility

- Semantic labels for Skip, each language row (title + selected state), Apply Language
- Min ~44×44 tap targets for rows, Skip, CTA
- Sufficient contrast for subtitle and unselected rows

---

## Testing / acceptance

- [ ] Matches `Select Language Screen.png`: teal wave header, Skip, title/subtitle, bordered two-row card, circular flags, check on selected, 4 dots (first active), Apply Language + globe
- [ ] Uses `english_language.png` and `khmer_language.png` (not redrawn flags)
- [ ] Default selection English (US)
- [ ] Apply persists locale and continues flow
- [ ] Skip continues with default and does not re-prompt next cold start
- [ ] Light and dark mode readable
- [ ] Splash → Language → Onboarding path works on first install

---

## Out of scope

- Implementing full Khmer translation files (wire locale; translations can land separately)
- Settings “change language” screen (can reuse assets later)
- Changing Auth0 / Google auth flows
- Editing other auth screens beyond Splash routing to insert this gate

---

## Dependencies

- `01-splash-prompt.md` (routing update)
- `03-onboarding-prompt.md` (next first-launch screen)
- `AppColors` / existing teal wave widgets
- `LocalStorageService` / `SharedPreferences`
