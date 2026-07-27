# 02 - Onboarding Screen Prompt

Build the **Onboarding** module for Vithey App.

## Design reference (match this layout on every slide)

![Onboarding Screen — Slide 1](../../screen%20image/auth/Onboarding%20Screen.png)

> Asset path: `Prompt Frontend/screen image/auth/Onboarding Screen.png`  
> Same layout for all 3 slides — only illustration, title, description, and button label change.

---

## Product spec

### Quick info

| Field | Value |
|-------|-------|
| Screen ID | `02` |
| Route | `Routes.ONBOARDING` |
| Flutter module | `lib/modules/onboarding/` |
| Backend service(s) | — |
| Auth required | No |

### Purpose

Introduce Vithey features to **first-time users** with **3 slides**, then route to Auth.

### Open from

- Splash when `onboarding_completed` is false

### Main UI (match `Onboarding Screen.png`)

| Element | Description |
|---------|-------------|
| Top section (~55% height) | **Teal background** with **wavy bottom edge** into white area |
| Skip | Top-right, **white** text — visible on all slides |
| Illustration | Large **rounded rectangle** placeholder/image, centered in teal section (light grey fill until asset added) |
| Bottom section (~45%) | **White background** |
| Title | Bold, dark grey, centered |
| Description | Medium grey, centered, 2 lines max |
| Page indicator | **3 dots** — active = teal, inactive = light grey |
| CTA button | Full-width teal pill, white **→ Next** (slides 1–2) or **→ Get Started** (slide 3) |

### Slide content

| Slide | Title | Description | Illustration asset |
|-------|-------|-------------|-------------------|
| 1 | Student Community & Social Feed | Connect with peers, share updates, and stay informed about campus life. | `assets/images/onboarding/onboarding_1.png` |
| 2 | Jobs & Career Growth | Discover job posts, apply with your CV, and connect with opportunities on campus. | `assets/images/onboarding/onboarding_2.png` |
| 3 | Finance, Chat & AI Support | Track tuition payments, chat privately, and get AI help for study and career. | `assets/images/onboarding/onboarding_3.png` |

### User actions

| Action | Result |
|--------|--------|
| Swipe left / tap Next | Next slide (or finish on slide 3) |
| Skip (any slide) | Set `onboarding_completed` → Auth |
| Get Started (slide 3) | Set `onboarding_completed` → Auth |

### Logic & behavior

- Shown once per install (`onboarding_completed` in `shared_preferences`)
- `PageController` with **3** pages
- `PageView` horizontal swipe between slides
- Skip and Get Started both persist flag and `Get.offAllNamed(Routes.AUTH)`

### Navigation

| From | Action | To |
|------|--------|-----|
| Onboarding | Skip / Get Started | Auth |

### API endpoints

None.

### Status checklist

- [ ] UI matches `Onboarding Screen.png` layout
- [ ] 3 slides with correct copy
- [ ] Skip + Next + Get Started work
- [ ] Flag persisted
- [ ] Tested Android / iOS

---

## Goal

Pixel-close onboarding using the **split teal/white wave layout** from the reference image, 3 slides, persistence, then Auth.

## Depends On

- `00-foundation-prompt.md`, `01-splash-prompt.md`

## Reuse From Core

- `CustomButton` (style bottom CTA to match teal pill in mockup)
- `AppColors` — splash/onboarding teal palette

## Design system — colors (`app_colors.dart`)

| Token | Hex | Use |
|-------|-----|-----|
| `onboardingTeal` | `#00BFA5` | Top section, active dot, CTA button |
| `onboardingTealDark` | `#1A9B8E` | Wave shadow layer (optional) |
| `onboardingTitle` | `#37474F` | Slide title |
| `onboardingBody` | `#78909C` | Slide description |
| `onboardingDotActive` | `#00BFA5` | Active pagination dot |
| `onboardingDotInactive` | `#CFD8DC` | Inactive dots |
| `onboardingPlaceholder` | `#E0F2F1` | Illustration placeholder fill |
| `onboardingSkip` | `#FFFFFF` | Skip text |

## Layout structure (each slide)

```text
Scaffold
└── Stack
    ├── Column
    │   ├── Expanded(flex: 55) — OnboardingTopSection (teal + wave clip + illustration + Skip)
    │   └── Expanded(flex: 45) — OnboardingBottomSection (title, body, dots, CTA)
    └── Positioned top-right — Skip (or Skip inside top section)
```

**Wave divider:** `ClipPath` + `OnboardingWaveClipper` (custom painter) — smooth curve from teal into white, matching mockup.

**Illustration box:**
- `BorderRadius.circular(20)`
- `color: onboardingPlaceholder` until PNG/Lottie loaded
- Margin horizontal ~32, vertically centered in teal area
- `Image.asset` or `Lottie.asset` when files exist

**CTA button:**
```dart
// Full width, margin horizontal 24, bottom 24 + SafeArea
ElevatedButton / CustomButton:
  backgroundColor: onboardingTeal
  borderRadius: 28
  child: Row(mainAxisAlignment: center, children: [
    Icon(Icons.arrow_forward, color: white),
    SizedBox(width: 8),
    Text('Next' or 'Get Started', color: white, fontWeight: w600),
  ])
```

## Module files

```text
lib/modules/onboarding/
  onboarding_screen.dart
  onboarding_controller.dart
  onboarding_binding.dart
  widgets/
    onboarding_page_view.dart      # PageView wrapper
    onboarding_slide.dart          # Single slide layout (top+bottom)
    onboarding_top_section.dart    # Teal + wave + illustration slot
    onboarding_bottom_section.dart # Title, description, dots, CTA
    onboarding_wave_clipper.dart    # CustomClipper for wavy edge
    onboarding_page_indicator.dart # 3 dots

assets/images/onboarding/
  onboarding_1.png
  onboarding_2.png
  onboarding_3.png
```

**pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/images/onboarding/
```

Until illustration PNGs exist, use **rounded grey placeholder** `Container` (matches mockup).

## Controller logic

```dart
class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  static const totalPages = 3;

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    } else {
      finish();
    }
  }

  void skip() => finish();

  Future<void> finish() async {
    await localStorage.setOnboardingCompleted(true);
    Get.offAllNamed(Routes.AUTH);
  }
}
```

- Slide 1–2: CTA label **"Next"**
- Slide 3: CTA label **"Get Started"** (same button style)
- `Obx` rebuilds CTA text from `currentPage`

## UI requirements

- **Do not** use plain full-screen `PageView` with different layouts per slide — every slide shares the same `OnboardingSlide` template.
- Skip: `TextButton` top-right, white, no underline, padding 16.
- Pagination: 3 dots, diameter 8, spacing 8, active expands optional (keep simple dots per mockup).
- Smooth `PageView` physics: `BouncingScrollPhysics` on iOS feel.
- No app bar.

## Widget rules

- `onboarding_slide.dart` parameters: `imageAsset`, `title`, `description` — used 3 times.
- Wave clipper stays in module widgets (onboarding-specific).
- CTA uses `CustomButton` if it supports full-width teal + icon; else styled `ElevatedButton` in module.

## Route registration

```dart
GetPage(name: Routes.ONBOARDING, page: () => OnboardingScreen(), binding: OnboardingBinding())
```

## Testing

- Widget test: 3 dots visible, Skip visible, title matches slide 1 copy.
- Controller test: `finish()` sets flag and navigates to Auth.
- Swipe / next advances `currentPage`.

## Output

3-slide onboarding matching **`Onboarding Screen.png`** layout + persistence + navigation to Auth.
