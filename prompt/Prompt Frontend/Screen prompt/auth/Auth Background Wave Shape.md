# Auth Background Wave Shape

**Source of truth** for the continuous intro/auth wave ribbon (save 4, finalized).  
**Preview SVG:** [`auth_background_wave_shape.svg`](./auth_background_wave_shape.svg)  
**Builder:** [`_build_auth_background_wave_shape.py`](./_build_auth_background_wave_shape.py)

Coordinates are **fractions of screen width / height** (0–1), left → right, **per screen cut**.  
Y = teal / light **wave-edge depth** from the top (fill from top down to the edge).  
Adjacent screens **share seam endpoints** so L↔R morph stays continuous.

**Canvas reference:** iPhone 16 Pro Max logical · each cut `440×956` · ribbon `2640×956`.

**Smoothing:** Catmull-style cubics, tension `/6` (same as `OnboardingBackground`).

**Do not change casually.** App morph / redesign should reuse or explicitly version these shapes.

---

## Shared seams (cut boundaries)

| Seam | Between | Teal Y | Light Y |
|------|---------|--------|---------|
| Start | Language left | `0.360` | `0.410` |
| 1 → 2 | Language → Onboarding_1 | `0.400` | `0.460` |
| 2 → 3 | Onboarding_1 → Onboarding_2 | `0.500` | `0.560` |
| 3 → 4 | Onboarding_2 → Onboarding_3 | `0.500` | `0.538` |
| 4 → 5 | Onboarding_3 → Sign In | `0.400` | `0.455` |
| 5 → 6 | Sign In → Sign Up | `0.240` | `0.300` |
| End | Sign Up right | `0.200` | `0.270` |

Teal seam chain: `0.360 → 0.400 → 0.500 → 0.500 → 0.400 → 0.240 → 0.200`  
Light seam chain: `0.410 → 0.460 → 0.560 → 0.538 → 0.455 → 0.300 → 0.270`

---

## 1 · Language

2 waves · teal band ~36% → ~40%

| | values |
|---|---|
| **Teal X** | `0.00, 0.18, 0.38, 0.62, 0.82, 1.00` |
| **Teal Y** | `0.360, 0.390, 0.335, 0.415, 0.375, 0.400` |
| **Light X** | `0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00` |
| **Light Y** | `0.410, 0.435, 0.380, 0.465, 0.420, 0.450, 0.460` |

**Teal pairs:**  
`(0.00, 0.360) (0.18, 0.390) (0.38, 0.335) (0.62, 0.415) (0.82, 0.375) (1.00, 0.400)`

**Light pairs:**  
`(0.00, 0.410) (0.16, 0.435) (0.36, 0.380) (0.56, 0.465) (0.76, 0.420) (0.90, 0.450) (1.00, 0.460)`

---

## 2 · Onboarding_1

2 waves · teal band ~40% → ~50%

| | values |
|---|---|
| **Teal X** | `0.00, 0.18, 0.38, 0.62, 0.82, 1.00` |
| **Teal Y** | `0.400, 0.385, 0.430, 0.415, 0.470, 0.500` |
| **Light X** | `0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00` |
| **Light Y** | `0.460, 0.430, 0.480, 0.460, 0.520, 0.545, 0.560` |

**Teal pairs:**  
`(0.00, 0.400) (0.18, 0.385) (0.38, 0.430) (0.62, 0.415) (0.82, 0.470) (1.00, 0.500)`

**Light pairs:**  
`(0.00, 0.460) (0.16, 0.430) (0.36, 0.480) (0.56, 0.460) (0.76, 0.520) (0.90, 0.545) (1.00, 0.560)`

---

## 3 · Onboarding_2

2 waves · teal ~50% band

| | values |
|---|---|
| **Teal X** | `0.00, 0.18, 0.38, 0.62, 0.82, 1.00` |
| **Teal Y** | `0.500, 0.480, 0.520, 0.485, 0.510, 0.500` |
| **Light X** | `0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00` |
| **Light Y** | `0.560, 0.535, 0.575, 0.540, 0.560, 0.555, 0.538` |

**Teal pairs:**  
`(0.00, 0.500) (0.18, 0.480) (0.38, 0.520) (0.62, 0.485) (0.82, 0.510) (1.00, 0.500)`

**Light pairs:**  
`(0.00, 0.560) (0.16, 0.535) (0.36, 0.575) (0.56, 0.540) (0.76, 0.560) (0.90, 0.555) (1.00, 0.538)`

---

## 4 · Onboarding_3

1 wave · teal ~50% → ~40% (softer mid rise at x≈50%)

| | values |
|---|---|
| **Teal X** | `0.00, 0.25, 0.50, 0.75, 1.00` |
| **Teal Y** | `0.500, 0.515, 0.428, 0.420, 0.400` |
| **Light X** | `0.00, 0.20, 0.50, 0.72, 0.88, 1.00` |
| **Light Y** | `0.538, 0.570, 0.480, 0.475, 0.460, 0.455` |

**Teal pairs:**  
`(0.00, 0.500) (0.25, 0.515) (0.50, 0.428) (0.75, 0.420) (1.00, 0.400)`

**Light pairs:**  
`(0.00, 0.538) (0.20, 0.570) (0.50, 0.480) (0.72, 0.475) (0.88, 0.460) (1.00, 0.455)`

---

## 5 · Sign In

2 waves · teal ~40% → ~24%

| | values |
|---|---|
| **Teal X** | `0.00, 0.18, 0.38, 0.62, 0.82, 1.00` |
| **Teal Y** | `0.400, 0.340, 0.290, 0.325, 0.265, 0.240` |
| **Light X** | `0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00` |
| **Light Y** | `0.455, 0.400, 0.350, 0.385, 0.320, 0.295, 0.300` |

**Teal pairs:**  
`(0.00, 0.400) (0.18, 0.340) (0.38, 0.290) (0.62, 0.325) (0.82, 0.265) (1.00, 0.240)`

**Light pairs:**  
`(0.00, 0.455) (0.16, 0.400) (0.36, 0.350) (0.56, 0.385) (0.76, 0.320) (0.90, 0.295) (1.00, 0.300)`

---

## 6 · Sign Up

2 waves · teal ~24% → ~20%

| | values |
|---|---|
| **Teal X** | `0.00, 0.18, 0.38, 0.62, 0.82, 1.00` |
| **Teal Y** | `0.240, 0.215, 0.255, 0.205, 0.230, 0.200` |
| **Light X** | `0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00` |
| **Light Y** | `0.300, 0.265, 0.310, 0.250, 0.285, 0.255, 0.270` |

**Teal pairs:**  
`(0.00, 0.240) (0.18, 0.215) (0.38, 0.255) (0.62, 0.205) (0.82, 0.230) (1.00, 0.200)`

**Light pairs:**  
`(0.00, 0.300) (0.16, 0.265) (0.36, 0.310) (0.56, 0.250) (0.76, 0.285) (0.90, 0.255) (1.00, 0.270)`

---

## Wave counts (summary)

| # | Screen | Waves |
|---|--------|-------|
| 1 | Language | 2 |
| 2 | Onboarding_1 | 2 |
| 3 | Onboarding_2 | 2 |
| 4 | Onboarding_3 | 1 |
| 5 | Sign In | 2 |
| 6 | Sign Up | 2 |

---

## App mapping (implementation note)

| Screen / state | Use profile |
|----------------|-------------|
| Select Language | §1 Language |
| Onboarding page 0 | §2 Onboarding_1 |
| Onboarding page 1 | §3 Onboarding_2 |
| Onboarding page 2 | §4 Onboarding_3 |
| Auth Sign In | §5 Sign In |
| Auth Sign Up | §6 Sign Up |

Morph between neighbors by lerping teal/light X/Y (pad shorter lists).  
Y values are **absolute screen fractions** — not scaled by the old single `waveHeightFactor` curve.

See also (legacy / other painters): [`WAVE_SHAPES.md`](./WAVE_SHAPES.md).
