# Wave shape source of truth (intro / auth)

Saved curve points for each intro screen’s wave style.  
Coordinates are **fractions of width / height** (0–1), left → right.

> **Do not change these casually.** Morph / redesign should reuse or explicitly version these shapes.  
> Code mirrors: see file paths under each section.

---

## 1. Select Language + Onboarding (shared painter)

**Widget:** `OnboardingBackground`  
**File:** `vithey_app/lib/modules/onboarding/widgets/onboarding_background.dart`

### Layers (bottom → top)
1. White / card surface (full rect)
2. Light-teal rear wave (“white-50%”)
3. Teal front wave (`AppColors.authHeaderTeal`)

### Height factors
| Screen | `waveHeightFactor` | Notes |
|--------|--------------------|--------|
| Select Language | `0.68` (`languageFactor`) | Taller white body |
| Onboarding | `1.0` (`onboardingFactor`) | Default full wave depth |

Same **curve shape** on both; only the vertical scale (`heightFactor`) changes.

### Teal edge (front)
```
X: [0.00, 0.20, 0.40, 0.50, 0.80, 1.00]
Y: [0.510, 0.528, 0.485, 0.485, 0.525, 0.460]
```

### Light / white-50% edge (rear)
```
X: [0.00, 0.20, 0.40, 0.60, 0.75, 0.95, 1.00]
Y: [0.535, 0.575, 0.570, 0.535, 0.535, 0.580, 0.580]
```

### Path math
- Point: `(width * x, height * y * heightFactor)` (`heightFactor` clamped 0.35–1.0)
- Fill: from top of screen down to the edge
- Edge smoothing: Catmull-style cubics with tension `/6`
- `authMorph` 0→1: lerps edge Y toward `1.0` (full teal) and fades the light layer

---

## 2. Auth v2 — moving sheet band (Sign In / Sign Up)

**Widget:** `AuthMovingWaveSheet`  
**File:** `vithey_app/lib/modules/auth/widgets/auth_moving_wave_sheet.dart`

### Structure
- Backdrop: solid teal (`AuthTealBackdrop` / morph via `OnboardingBackground.authMorph`) — **no curve** when settled
- Sheet: wave **band** (~`0.10` of screen height) + white body hugging form content

### Band Y meaning
Inside the band only: `0` = top of band, `1` = bottom of band (sheet).

### Light-teal upper edge (in band)
```
X: [0.00, 0.12, 0.28, 0.40, 0.55, 0.70, 0.85, 1.00]
Y: [0.00, 0.22, 0.45, 0.55, 0.28, 0.08, 0.22, 0.18]
```

### White sheet edge (in band)
```
X: [0.00, 0.12, 0.28, 0.40, 0.55, 0.70, 0.85, 1.00]
Y: [1.00, 0.78, 0.64, 0.76, 0.58, 0.46, 0.74, 0.66]
```

### Path math
- Light fill: between light edge and white edge
- White fill: from white edge down through sheet body
- Smoothing: softer Catmull with tension `/8`

**Not the same curves as Onboarding.** Same color family only.

---

## 3. Auth legacy — forgot-password style header

**Widget:** `AuthWaveHeader`  
**File:** `vithey_app/lib/modules/auth/widgets/auth_wave_header.dart`

Simple quadratic waves (older style), default header height ≈ `0.38` of screen:

### Rear wave
```
start: (0, 0.55h)
quad:  control (0.45w, 0.75h) → end (w, 0.50h)
then close down to bottom corners
```

### Front (white) wave
```
start: (0, 0.62h)
quad:  control (0.55w, 0.90h) → end (w, 0.68h)
then close down to bottom corners
```

---

## Quick comparison

| Screen | Painter | Same as Onboarding? |
|--------|---------|---------------------|
| Select Language | `OnboardingBackground` @ 0.68 | Yes (scaled) |
| Onboarding | `OnboardingBackground` @ 1.0 | Yes (canonical) |
| Auth Sign In / Up | `AuthMovingWaveSheet` + flat teal | **No** — different curves |
| Forgot password header | `AuthWaveHeader` | **No** — legacy quads |

---

## Morph implication (note)

Natural morph of **white + white-50%** only works while staying on `OnboardingBackground` (Language ↔ Onboarding, or wave→full teal).  
Auth’s white sheet uses a **different** curve set and layout model, so it cannot inherit Onboarding’s edge points 1:1 without redesigning Auth onto the same painter.
