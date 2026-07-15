# 01 - Splash Screen Prompt

Build the **Splash** module for Vithey App.

## Design references

| Asset                  | Path                                                                                         | Use                                                           |
| ---------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Full splash layout** | [`../../screen image/auth/Splash Screen.png`](../../screen%20image/auth/Splash%20Screen.png) | Background, spacing, "Vithey" text position                   |
| **Official app logo**  | [`../../screen image/auth/logo app.png`](../../screen%20image/auth/logo%20app.png)           | V icon inside white circle — **use this file, do not redraw** |

![Vithey Splash Screen](../../screen%20image/auth/Splash%20Screen.png)

![Vithey App Logo](../../screen%20image/auth/logo%20app.png)

> **Copy into Flutter project:**  
> `Prompt Frontend/screen image/auth/logo app.png` → `assets/images/brand/logo_app.png`  
> Constant: `AppAssets.logoApp` (see `COMMON_CONTEXT.md` + `00-foundation-prompt.md`)

---

## Product spec

### Quick info

| Field               | Value                 |
| ------------------- | --------------------- |
| Screen ID           | `01`                  |
| Route               | `Routes.SPLASH`       |
| Flutter module      | `lib/modules/splash/` |
| Backend service(s)  | —                     |
| Auth required       | No                    |
| Competition feature | No (entry)            |

### Purpose

Show Vithey branding while checking login token, then route to Home, Onboarding, or Auth.

### Open from

- App launch (`initialRoute`)

### Main UI (match `Splash Screen.png`)

| Element     | Description                                                                              |
| ----------- | ---------------------------------------------------------------------------------------- |
| Background  | Teal base with **organic wavy shapes** — darker teal top-left, lighter cyan bottom-right |
| Center logo | **White circle** with **`logo_app.png`** centered inside (green/cyan V ribbon + dot)     |
| App name    | **"Vithey"** — white, bold sans-serif, **bottom center**                                 |
| Loading     | **No visible spinner** (token check in background; min 1.5s branding delay)              |

### User actions

| Action | Result                                       |
| ------ | -------------------------------------------- |
| None   | Auto-navigate after token + onboarding check |

### Logic & behavior

- Minimum display **1.5 seconds**
- Read `access_token` from `SecureStorageService`
- Read `onboarding_completed` from `LocalStorageService`
- Valid token → `Get.offAllNamed(Routes.HOME)`
- No token + first launch → `Routes.ONBOARDING`
- No token + onboarding done → `Routes.AUTH`
- `PopScope(canPop: false)` — block back

### Navigation

| From   | Condition            | To         |
| ------ | -------------------- | ---------- |
| Splash | Valid token          | Home       |
| Splash | No token, first time | Onboarding |
| Splash | No token, returning  | Auth       |

### API endpoints

None.

### Status checklist

- [ ] UI matches `Splash Screen.png`
- [ ] Logo uses `logo_app.png` (not custom-drawn V)
- [ ] Navigation logic works
- [ ] Tested Android / iOS

---

## Goal

Pixel-close splash matching the reference screen, using the **official logo asset**, with working auth routing.

## Depends On

- `00-foundation-prompt.md` — includes `AppAssets.logoApp` + optional `AppLogo` widget

## Reuse From Core

- `AppAssets.logoApp` / `AppLogo` from `core/widgets/app_logo.dart`
- `AppColors` splash palette
- `SecureStorageService`, `LocalStorageService`

## Design system — colors (`app_colors.dart`)

| Token               | Hex       | Use               |
| ------------------- | --------- | ----------------- |
| `splashBaseTeal`    | `#1A9B8E` | Main background   |
| `splashWaveDark`    | `#0D7A70` | Top-left wave     |
| `splashWaveLight`   | `#2EC4B6` | Bottom-right wave |
| `splashTextWhite`   | `#FFFFFF` | "Vithey" label    |
| `splashCircleWhite` | `#FFFFFF` | Logo circle fill  |

Logo colors come from **`logo_app.png`** — do not recreate gradients in code.

## Layout structure

```text
Scaffold (no app bar)
└── Stack (fit: expand)
    ├── Layer 1: SplashBackground — teal wavy shapes at the edge (top left and bottom right)
    ├── Layer 2: Center — white circle + Image.asset(AppAssets.logoApp)
    └── Layer 3: Bottom — "Vithey" text (SafeArea, bottom ~40px)
```

**Proportions:**

- Logo circle: ~40% screen width; logo image ~80% of circle with `BoxFit.contain`
- "Vithey": `fontSize` 28–32, `fontWeight` w600

## Module files

```text
lib/modules/splash/
  splash_screen.dart
  splash_controller.dart
  splash_binding.dart
  widgets/
    splash_background.dart
    splash_logo.dart            # white circle + AppAssets.logoApp
    splash_brand_title.dart

assets/images/brand/
  logo_app.png                  # copied from screen image/auth/logo app.png

assets/images/splash/           # optional
  splash_waves_bg.png           # pre-rendered waves only
```

**pubspec.yaml:**

```yaml
flutter:
  assets:
    - assets/images/brand/
    - assets/images/splash/
```

## UI implementation

### `splash_logo.dart` (required)

```dart
// White circle + official logo — NO CustomPaint for the V
Container(
  width: circleSize,
  height: circleSize,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.splashCircleWhite,
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
  ),
  padding: EdgeInsets.all(circleSize * 0.18),
  child: Image.asset(AppAssets.logoApp, fit: BoxFit.contain),
)
```

Or use `AppLogo(size: circleSize, onWhiteCircle: true)` from foundation.

- Optional animation: scale `0.92 → 1.0`, 600ms, `Curves.easeOut`

### `splash_background.dart`

- Base teal + wavy shapes (`CustomPainter` or `splash_waves_bg.png`)
- Match `Splash Screen.png` — darker wave top-left, lighter bottom-right

### `splash_brand_title.dart`

- `Text('Vithey', ...)` white, bottom center

### Do NOT

- Draw the V with `CustomPaint` or SVG — use **`logo_app.png` only**
- Show `CircularProgressIndicator` on this screen

### Dark mode

- Fixed splash brand colors (same in light/dark app theme)

## Controller logic

```dart
1. Record start time
2. Read access_token + onboarding_completed in parallel
3. Wait until min 1.5s elapsed
4. Navigate: Home | Onboarding | Auth (Get.offAllNamed)
```

## Route registration

`initialRoute: Routes.SPLASH` in `GetMaterialApp`

## Testing

- Widget test: `Image` with `AppAssets.logoApp`, "Vithey" text, no spinner
- Controller test: mock storage → correct route

## Output

Splash matching `Splash Screen.png` with **official `logo_app.png`** + navigation logic.
