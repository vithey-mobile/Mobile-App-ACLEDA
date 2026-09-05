# 03 - Auth / Sign In Screen Prompt

Build the **Auth / Sign In screen** for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Auth Screen.png`
- Reference canvas: approximately `303 × 658 px` (portrait mobile)
- Treat the image as the source of truth for composition, spacing, colors, and visual hierarchy.
- Recreate the UI responsively; do not hard-code the entire screen to the reference dimensions.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03` |
| Primary route | `Routes.AUTH` / `Routes.LOGIN` |
| Sign-up route | `Routes.REGISTER` |
| Flutter module | `lib/modules/auth/` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Email/password and Google sign-in |

## Goal

Allow a returning user to sign in with an email address and password or continue with Google. New users can open the separate registration screen through the **Sign Up** link.

## Screen composition

Build the screen from top to bottom in this order:

1. **Teal decorative header**
   - Occupies roughly the top `38%` of the reference screen.
   - Use a turquoise/teal background close to `#2FC5C1`.
   - Center the Vithey app logo inside a white circular container in the upper-middle area.
   - Logo circle is approximately `82 × 82 px` on the reference canvas.
   - Use `AppLogo` / `AppAssets.logoApp` from `assets/images/brand/logo_app.png` (source asset: `Prompt Frontend/screen image/auth/logo app.png`).
   - The bottom edge is an organic layered wave: a lighter aqua wave behind and a white foreground wave that blends into the page body.
   - Implement the waves with `CustomPainter`, `ClipPath`, or reusable vector assets. Do not substitute a straight or diagonal edge.

2. **White content area**
   - Continues seamlessly from the white foreground wave.
   - Use safe-area-aware responsive spacing and a vertically scrollable layout for small screens or when the keyboard is open.
   - Horizontal page padding is approximately `24 px` at the reference size.

3. **Heading**
   - Centered text: **Welcome Back**.
   - Bold, dark charcoal, approximately `25–26 px` in the reference.
   - Leave clear space between the wave and the title, then between the title and the form.

4. **Email field**
   - Label: **Email Address**.
   - Placeholder: **Email**.
   - Leading outlined envelope icon in muted gray.
   - Light gray filled input with a subtle gray border, `6–8 px` corner radius, and compact height of about `36 px` in the reference.
   - Use an email keyboard and appropriate autofill hints.

5. **Password field**
   - Label: **Password**.
   - Placeholder: **Password**.
   - Leading lock icon in muted gray.
   - Mask the entered value and support a password visibility toggle without changing the reference layout.
   - Match the email field's dimensions and styling.

6. **Primary action**
   - Full-width teal rounded button.
   - Text: **↻ Sign In** visually represented with a small sign-in/refresh-style icon followed by **Sign In**. Prefer an appropriate Flutter icon rather than a text glyph.
   - White medium/bold text, approximately `14 px`.
   - Button height is about `35 px` on the reference canvas with `8 px` corner radius.
   - Use the app's teal brand color, close to `#08B9B3`.

7. **Social divider**
   - Center label: **Sign in with**.
   - Thin muted-gray horizontal lines on both sides.
   - Keep the label small and dark gray.

8. **Google sign-in button**
   - Full-width white button with a thin light-gray border and rounded corners.
   - Show the official multicolor Google `G` mark followed by **Continue with Google**.
   - Center the icon/text group and use dark charcoal medium/bold text.
   - Match the primary button's width and approximate height.

9. **Registration prompt**
   - Centered row near the bottom of the content:
     - Muted-gray text: **Don’t have an account?**
     - Teal action text: **Sign Up**
   - Tapping **Sign Up** navigates to `Routes.REGISTER`.

## Visual style

| Token | Direction |
|---|---|
| Page background | White / very light neutral |
| Header teal | Approximately `#2FC5C1` |
| Primary button/link | Approximately `#08B9B3` |
| Rear wave | Light aqua, approximately `#6AD6D2` |
| Heading | Dark charcoal, approximately `#303236` |
| Labels/body | Dark gray |
| Placeholder/icons | Muted cool gray |
| Input fill | Very light gray, approximately `#F5F5F5` |
| Borders/divider | Light neutral gray |
| Font | App theme font; use a clean sans-serif appearance |

Avoid extra elements that are not visible in the reference: no tab bar, no Register toggle, no generic OAuth list, no app bar, no back button, and no “Forgot password?” link on this screen.

## Responsive behavior

- Preserve the reference proportions on narrow portrait phones while scaling naturally on larger devices.
- Wrap the content in `SafeArea` where appropriate.
- Use `LayoutBuilder`/constraints rather than fixed screen coordinates.
- Keep the form readable when text scaling is enabled.
- The content must not overflow at `320 px` width or when the keyboard appears; allow vertical scrolling.
- Keep the logo and wave header visually stable while giving the form enough room on short screens.

## Interaction and validation

- Validate the form through `validators.dart`.
- Email is required and must use a valid email format.
- Password is required; apply the project's configured minimum length.
- Display validation messages inline without shifting or breaking the overall composition excessively.
- Disable duplicate submissions while a request is in progress.
- On submit, show a compact loading indicator inside the primary button while retaining its size.
- Show authentication/API errors near the form in an accessible, readable manner.
- On successful sign-in:
  1. Save `access_token` and `refresh_token` in secure storage.
  2. Navigate with `Get.offAllNamed(Routes.HOME)`.
- Google button starts the Google OAuth/Auth0 flow, then stores tokens and navigates to Home.
- Mock authentication may be enabled only through `USE_MOCK_AUTH=true` for development.

## Accessibility

- Provide semantic labels for the logo, fields, password visibility control, sign-in button, Google button, and Sign Up link.
- Ensure every interactive target is at least `44 × 44 logical pixels`, even when the visible button in the reference appears shorter.
- Maintain sufficient contrast for text, borders, and controls.
- Support keyboard traversal and form submission from the password field.

## Architecture and reusable widgets

Use the existing project structure and core components:

```text
lib/modules/auth/
  auth_screen.dart
  login_screen.dart
  register_screen.dart
  auth_controller.dart
  auth_binding.dart
  widgets/
    auth_wave_header.dart
    login_form.dart
    oauth_button.dart

lib/data/models/user_model.dart
lib/data/services/auth_service.dart
lib/data/repositories/auth_repository.dart
```

- Use `CustomTextField` from `core/widgets/custom_text_field.dart`.
- Use `CustomButton` from `core/widgets/custom_button.dart`.
- Reuse `LoadingWidget`, `AppErrorWidget`, and `validators.dart` where appropriate.
- Do not use raw `TextField` or `ElevatedButton` inside the form unless a core component cannot support a reference-specific requirement; extend the reusable component instead.
- Keep wave-header rendering in a dedicated reusable widget/painter.
- Keep business logic out of UI widgets.

## Controller behavior

- `login()` → validate → `AuthRepository.login` → save tokens → `Get.offAllNamed(Routes.HOME)`.
- `loginWithGoogle()` → OAuth/Auth0 flow → save tokens → Home.
- Loading and error states use reactive controller state such as `RxBool isLoading` and `RxString errorMessage`.
- Expose a separate loading state for Google sign-in if required.
- Clear stale errors when the user edits the relevant field or retries.

## API endpoints

| Method | Path | Notes |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Email and password; returns user and tokens |
| `POST` | `/api/v1/auth/register` | Used by the separate registration screen |
| `POST` | `/api/v1/auth/refresh` | Refresh-token exchange |

Use the exact paths defined by the project's integration contract if they differ from the aliases above.

## Navigation

| From | Action | To |
|---|---|---|
| Onboarding/Splash | Open auth | Sign In |
| Sign In | Successful authentication | Home |
| Sign In | Tap **Sign Up** | Register |
| Register | Existing-user action | Sign In |

## Testing and acceptance criteria

- The implementation visually matches `Auth Screen.png`, including the layered curved header, logo placement, title hierarchy, form spacing, buttons, divider, and footer link.
- Login form renders the email and password fields with the correct labels, placeholders, and icons.
- Invalid input displays field-level errors.
- Password masking/visibility works.
- Sign In loading, success, and error states work without layout jumps.
- Google sign-in action is wired or clearly isolated behind the configured OAuth adapter.
- **Sign Up** navigates to `Routes.REGISTER`.
- Successful authentication stores tokens securely and replaces the route stack with Home.
- Widget tests cover rendering, validation, loading, and navigation.
- The screen has no overflow on common small and large phone sizes.

## Dependencies

- `00-foundation-prompt.md`
- `02-onboarding-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`

## Output

Deliver a polished, responsive Flutter sign-in screen that closely reproduces the supplied reference image and includes controller/repository wiring ready for backend and Google authentication integration.
