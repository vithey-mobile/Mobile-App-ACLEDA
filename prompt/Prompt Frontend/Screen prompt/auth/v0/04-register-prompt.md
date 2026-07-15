# 03B - Register / Create Account Screen Prompt

Build the **Register / Create Account screen** for the Vithey App in Flutter, matching the supplied reference image as closely as possible.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Register Screen.png`
- Reference canvas: approximately `305 × 656 px` (portrait mobile)
- Treat the image as the source of truth for composition, visible fields, spacing, colors, and visual hierarchy.
- Recreate the design responsively; do not hard-code the whole page to the reference dimensions.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03B` |
| Route | `Routes.REGISTER` |
| Sign-in route | `Routes.LOGIN` / `Routes.AUTH` |
| Flutter module | `lib/modules/auth/` |
| Backend service | `auth-service` |
| Auth required | No (public) |
| Primary feature | Email/password and Google registration |

## Goal

Allow a new user to create an account with their full name, email address, and password or continue with Google. Existing users can return to the Sign In screen.

## Screen composition

Build the screen from top to bottom in this order:

1. **Teal decorative header**
   - Occupies roughly the top `29%` of the reference screen.
   - Use a turquoise/teal background close to `#23C1BC`.
   - Center the Vithey logo inside a white circular container.
   - Logo circle is approximately `82 × 82 px` on the reference canvas.
   - Use `AppLogo` / `AppAssets.logoApp` from `assets/images/brand/logo_app.png` (source: `Prompt Frontend/screen image/auth/logo app.png`).
   - The lower edge contains two organic waves: a lighter aqua rear wave and a white foreground wave that blends into the content area.
   - Implement the curves with `CustomPainter`, `ClipPath`, or reusable vector assets. Do not replace them with a straight or diagonal edge.

2. **White content area**
   - Continues seamlessly from the white foreground wave.
   - Use horizontal padding of approximately `23–24 px` at the reference size.
   - Make the page vertically scrollable on short screens and when the keyboard is visible.

3. **Heading**
   - Centered text: **Create Account**.
   - Bold dark charcoal, approximately `24–25 px` in the reference.
   - Keep the title close to the wave while preserving comfortable whitespace above the form.

4. **Full name field**
   - Label: **Full Name**.
   - Placeholder: **Username** exactly as shown in the reference.
   - Leading outlined user/profile icon in muted gray.
   - Light-gray filled input with a subtle gray border, `6–8 px` corner radius, and compact visual height.
   - Use name capitalization and the appropriate autofill hint.

5. **Email field**
   - Label: **Email Address**.
   - Placeholder: **Email**.
   - Leading outlined envelope icon in muted gray.
   - Use the email keyboard and email autofill hint.
   - Match the name field's dimensions and styling.

6. **Password field**
   - Label: **Password**.
   - Placeholder: **Password**.
   - Leading lock icon in muted gray.
   - Mask the entered value and support a password visibility toggle without disrupting the reference layout.
   - Do not add a visible confirm-password field; it is not present in the supplied design.

7. **Primary action**
   - Full-width teal rounded button.
   - Show a small account/document-add style icon followed by **Sign Up**.
   - Prefer an appropriate Flutter/vector icon instead of a text glyph.
   - Use white medium/bold text and the app's teal color, close to `#08B9B3`.
   - The visual button is about `35 px` high with roughly `8 px` corner radius in the reference; preserve a minimum `44 × 44` logical-pixel tap target.

8. **Social divider**
   - Center label: **Sign in with**, matching the wording in the reference even though this is a registration screen.
   - Place thin muted-gray horizontal lines on both sides.
   - Use small dark-gray label text.

9. **Google registration button**
   - Full-width white button with a thin light-gray border and rounded corners.
   - Show the official multicolor Google `G` mark followed by **Continue with Google**.
   - Center the icon/text group and use dark-charcoal medium/bold text.

10. **Existing-account prompt**
    - Centered row near the bottom:
      - Muted-gray text: **Already have an account.**
      - Teal action text: **Sign In**
    - Preserve the period after “account” as shown in the image.
    - Tapping **Sign In** returns to `Routes.LOGIN` or `Routes.AUTH` without stacking duplicate auth screens.

## Visual style

| Token | Direction |
|---|---|
| Page background | White / very light neutral |
| Header teal | Approximately `#23C1BC` |
| Primary button/link | Approximately `#08B9B3` |
| Rear wave | Light aqua, approximately `#67D4D0` |
| Heading | Dark charcoal, approximately `#303236` |
| Labels/body | Dark gray |
| Placeholder/icons | Muted cool gray |
| Input fill | Very light gray, approximately `#F5F5F5` |
| Borders/divider | Light neutral gray |
| Font | App theme font with a clean sans-serif appearance |

Do not introduce UI not visible in the reference: no app bar, back button, Login/Register tabs, phone field, confirm-password field, terms checkbox, or generic social-provider list.

## Responsive behavior

- Preserve the compact reference proportions on narrow portrait phones while scaling naturally on larger devices.
- Use `SafeArea` where appropriate and constraints rather than fixed screen coordinates.
- Support text scaling without clipping labels or actions.
- Prevent overflow at `320 px` width and when the keyboard appears by allowing vertical scrolling.
- Keep the logo and layered header visually stable while allowing the form to use available space on short screens.
- Avoid large layout jumps when validation errors or loading indicators appear.

## Validation and interaction

- Validate through `validators.dart`.
- Full name is required, trimmed, and must meet the project's reasonable name-length rules.
- Email is required and must use a valid email format.
- Password is required and must satisfy the backend password policy.
- Display field-level validation errors clearly and accessibly.
- Disable duplicate submissions while registration is in progress.
- Keep the Sign Up button's size stable and show a compact loading indicator inside it.
- Show registration/API errors near the form in an accessible manner.
- On successful registration:
  1. Parse the returned user and tokens.
  2. Save `access_token` and `refresh_token` in secure storage.
  3. Navigate with `Get.offAllNamed(Routes.HOME)`.
- Google registration starts the configured Google OAuth/Auth0 flow, stores returned tokens, and navigates to Home.
- Mock registration may be enabled only through `USE_MOCK_AUTH=true` in development.

## Backend contract note

The current backend reference describes registration as:

```json
{
  "email": "student@aub.edu.kh",
  "phone": "+855123456789",
  "password": "SecurePass123!",
  "full_name": "Jane Doe",
  "role": "USER"
}
```

The supplied UI does **not** include a phone field. Do not add one to this screen merely to satisfy the older contract. Keep the UI image-faithful and resolve the integration explicitly by making `phone` optional, collecting it in a later profile step, or updating the product design. Never send a fabricated phone number. Set the default role in the repository/request mapper only if the backend contract requires it.

## Accessibility

- Add semantic labels for the logo, every input, password visibility control, Sign Up button, Google button, and Sign In link.
- Ensure interactive targets are at least `44 × 44 logical pixels`.
- Maintain sufficient contrast for text, icons, borders, and controls.
- Support keyboard traversal and submit the form from the password keyboard action.
- Announce validation and API errors to assistive technology.

## Architecture and reusable widgets

Use the existing auth structure:

```text
lib/modules/auth/
  auth_screen.dart
  login_screen.dart
  register_screen.dart
  auth_controller.dart
  auth_binding.dart
  widgets/
    auth_wave_header.dart
    register_form.dart
    oauth_button.dart

lib/data/models/user_model.dart
lib/data/services/auth_service.dart
lib/data/repositories/auth_repository.dart
```

- Reuse the same `AuthWaveHeader` used by the Sign In screen, allowing its height/wave parameters to match this reference.
- Use `CustomTextField` from `core/widgets/custom_text_field.dart`.
- Use `CustomButton` from `core/widgets/custom_button.dart`.
- Reuse `LoadingWidget`, `AppErrorWidget`, and `validators.dart` where appropriate.
- Do not use raw `TextField` or `ElevatedButton` inside the form unless a core widget cannot support a reference-specific requirement; extend the reusable widget instead.
- Keep business logic and network calls out of UI widgets.

## Controller behavior

- `register()` → validate → map `fullName`, `email`, and `password` to the API request → `AuthRepository.register` → save tokens → `Get.offAllNamed(Routes.HOME)`.
- `registerWithGoogle()` → OAuth/Auth0 flow → save tokens → Home.
- Expose reactive loading and error states, such as `RxBool isRegistering`, `RxBool isGoogleLoading`, and `RxString errorMessage`.
- Clear stale field/API errors when the user edits values or retries.
- Dispose all text controllers correctly.

## API endpoints

| Method | Path | Notes |
|---|---|---|
| `POST` | `/api/v1/auth/register` | Creates the user and returns user + tokens |
| `POST` | `/api/v1/auth/refresh` | Refresh-token exchange |

Use the exact request and response envelopes defined in `Prompt Frontend/api-intergration/integration-contract.md` and the auth-service contract.

## Navigation

| From | Action | To |
|---|---|---|
| Sign In | Tap **Sign Up** | Register |
| Register | Successful registration | Home |
| Register | Tap **Sign In** | Sign In |

## Testing and acceptance criteria

- The screen visually matches `Register Screen.png`, including header height, layered waves, logo, title, field order, CTA, divider, Google button, and footer link.
- Exactly three visible text fields render: Full Name, Email Address, and Password.
- Labels, placeholders, icons, and button wording match the reference.
- Name, email, and password validation behave correctly.
- Password masking and visibility control work.
- Loading, success, and error states do not cause overflow or significant layout jumps.
- Google registration is wired or cleanly isolated behind the configured OAuth adapter.
- **Sign In** returns to the existing login route without duplicating auth pages.
- Successful registration securely stores tokens and replaces the route stack with Home.
- Widget/controller tests cover rendering, validation, loading, API success/error, and navigation.
- The page does not overflow on common small and large phone sizes.

## Dependencies

- `00-foundation-prompt.md`
- `02-onboarding-prompt.md`
- `03-auth-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Prompt Backend/services/auth-service/SERVICE_PROMPT.md`

## Output

Deliver a polished, responsive Flutter registration screen that closely reproduces the supplied reference and includes controller/repository wiring ready for backend and Google authentication integration.
