# 03C - Google Authentication Account Chooser Prompt

Implement the **Google authentication account-chooser step** for the Vithey App in Flutter, using the supplied image as the visual and interaction reference.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Auth Google Screen 1.png`
- Reference canvas: approximately `302 × 656 px` (portrait mobile)
- The image represents the first Google authentication step after the user taps **Continue with Google** on Sign In or Register.
- Match the composition when rendering an app-owned pre-chooser or development mock, while following the production OAuth security rules below.

## Important implementation rule

In production, Google/Auth0 should own the secure account-selection and consent UI. Launch the official Google Sign-In, Auth0, or browser-based OAuth SDK and allow its native/provider screen to vary by platform, OS version, installed accounts, locale, and SDK version.

Do **not** build a fake Google login form, request a Google password, scrape device accounts, embed Google credentials in the app, or claim that a pixel-identical custom screen is Google's secure UI. If the product retains this app-owned screen before the provider handoff, show only identities previously authorized and safely cached by Vithey; selecting any row must still launch or resume the official provider flow.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03C` |
| Suggested route | `Routes.GOOGLE_ACCOUNT_CHOOSER` |
| Entry point | `loginWithGoogle()` / `registerWithGoogle()` |
| Back destination | `Routes.LOGIN` / `Routes.AUTH` |
| Flutter module | `lib/modules/auth/` |
| Provider | Google through the configured Google Sign-In/Auth0 adapter |
| Auth required | No (public OAuth flow) |

## Goal

Let the user choose an available Google identity or add another account, complete authentication through the official provider, exchange the verified provider result for Vithey tokens, and continue to Home.

## Screen composition

Build the reference layout from top to bottom:

1. **System status-bar area**
   - White or very light background with dark status-bar icons.
   - Respect `SafeArea`; do not manually draw fake time, signal, Wi-Fi, or battery icons in the app UI.

2. **Brand logo**
   - Center the Vithey logo near the upper portion of the page.
   - Place it inside a subtle white circular surface approximately `68–70 px` across in the reference.
   - Use `AppLogo` / `AppAssets.logoApp` from `assets/images/brand/logo_app.png`.
   - Keep generous whitespace around it.

3. **Title and subtitle**
   - Centered title: **Sign in with Google**.
   - Bold dark charcoal, approximately `23–24 px` in the reference.
   - Centered subtitle: **To continue to Vithey**.
   - Use small muted-gray text and comfortable spacing below the title.

4. **Account chooser card**
   - Position a full-width card inside approximately `24 px` horizontal page margins.
   - Use a white/light-neutral surface, thin cool-gray border, and `7–8 px` outer corner radius.
   - The card contains dynamic account rows separated by thin gray dividers.
   - Only the first and last rows inherit the card's outer rounded corners.

5. **Known-account rows**
   - Each available account row shows:
     - A circular light-gray avatar placeholder or the provider-returned profile image.
     - The account display name in medium/bold dark text.
     - The email address below in smaller dark-gray text.
   - The reference contains example identities **Molika Khorn / molika.ops@aub.edu.kh** and **Username / email@edu.kh**. Treat these as design fixtures only; do not hard-code them in production.
   - Populate production rows only from safe, previously authorized session/account metadata made available through the configured auth adapter.
   - Tapping a row starts/resumes the official OAuth flow with an account hint where the provider supports it.

6. **Add-another-account row**
   - Show an outlined circular plus icon followed by **Add another account**.
   - Align it consistently with the avatar and text positions above.
   - Tapping it launches the official provider flow without an account hint, allowing Google to handle account addition and credential entry.

7. **Back action**
   - Center a compact inline row below the card:
     - Muted-gray text: **Back to**
     - Teal link: **Sign In**
   - Tapping **Sign In** cancels the current chooser state and returns to the existing login screen without creating duplicate routes.

8. **Privacy explanation**
   - Center the following small muted-gray text near the lower portion of the page:

     **To continue, Google will share your name, email address, language preference, and profile picture with Vithey.**

   - Wrap into multiple centered lines as necessary.
   - This copy describes requested profile scopes; update it if the actual OAuth scopes differ.

9. **Legal links**
   - Center an inline row beneath the explanation:
     - **Privacy Policy**
     - A hyphen separator
     - **Terms of Service**
   - Both labels are tappable links that open the real Vithey legal pages through `url_launcher` or the project's in-app browser.
   - Do not ship placeholder or broken URLs.

## Visual style

| Token | Direction |
|---|---|
| Background | White / very light cool gray, approximately `#FAFBFC` |
| Main text | Dark charcoal, approximately `#303236` |
| Supporting text | Muted gray |
| Link/accent | Vithey teal, approximately `#08B9B3` |
| Card surface | White / near-white |
| Card border/dividers | Cool gray |
| Avatar fill | Light neutral gray |
| Font | App theme font with a clean sans-serif appearance |

Do not add a teal wave header, app bar, password field, Google password prompt, large primary button, checkboxes, or unrelated social providers.

## Responsive behavior

- Match the narrow portrait reference while adapting cleanly to larger and smaller phones.
- Use `SafeArea`, constraints, and proportional spacing rather than absolute screen coordinates.
- Keep the chooser card readable at `320 px` width and with increased system text scale.
- Allow vertical scrolling when account rows, legal copy, accessibility text size, or a short viewport requires it.
- For many accounts, constrain the account-list area and make it scroll independently or let the page scroll; keep **Add another account**, back navigation, and legal text reachable.
- Truncate long emails to one line with an ellipsis and expose the complete value through semantics.

## OAuth flow and controller behavior

1. The user taps **Continue with Google** from Sign In or Register.
2. Set the originating intent (`signIn` or `register`) in controller state.
3. Prefer launching the official provider account chooser immediately.
4. If the configured product flow uses this app-owned pre-chooser, load only safe cached account summaries; never enumerate device Google accounts without provider authorization.
5. Selecting a known account calls the auth adapter with a supported account/login hint.
6. **Add another account** calls the adapter without a hint and may request provider re-selection.
7. Validate `state` and `nonce` where applicable and let the OAuth library complete PKCE/token handling.
8. Send the verified provider authorization result or ID token to the backend exchange endpoint.
9. Save only Vithey `access_token` and `refresh_token` in secure storage.
10. Clear temporary OAuth state and navigate with `Get.offAllNamed(Routes.HOME)`.

Controller methods may include:

- `beginGoogleAuth({required AuthIntent intent})`
- `selectGoogleAccount(GoogleAccountSummary account)`
- `addGoogleAccount()`
- `cancelGoogleAuth()`
- `completeGoogleAuth(GoogleAuthResult result)`
- `retryGoogleAuth()`

Expose explicit states such as `idle`, `loadingAccounts`, `launchingProvider`, `exchangingToken`, `success`, `cancelled`, and `error`. Prevent duplicate taps while provider launch or token exchange is active.

## Error and cancellation behavior

- Provider cancellation returns safely to the chooser or originating auth screen and must not display a frightening error.
- Network/provider failures show a concise retryable message without exposing raw tokens, authorization codes, stack traces, or provider internals.
- Invalid state, nonce, or token verification is a hard authentication failure; clear temporary state and require a fresh attempt.
- If no saved account summaries exist, skip the empty custom list and launch the official provider chooser, or show only **Add another account**.
- Never persist Google access/ID tokens in plain preferences or logs.

## Accessibility

- Add semantic labels for the logo, title, every account row, **Add another account**, **Sign In**, Privacy Policy, and Terms of Service.
- Identify each account button by display name and email without exposing more profile data than necessary.
- Ensure all interactive targets are at least `44 × 44 logical pixels`.
- Support keyboard and assistive-technology focus order from title → accounts → add account → back → legal links.
- Announce loading, cancellation, and error states.
- Maintain sufficient text, border, and link contrast.

## Architecture

Suggested structure:

```text
lib/modules/auth/
  auth_controller.dart
  google_account_chooser_screen.dart
  widgets/
    google_account_card.dart
    google_account_row.dart
    oauth_legal_footer.dart

lib/data/models/
  google_account_summary.dart

lib/data/services/
  google_auth_adapter.dart
  auth_service.dart

lib/data/repositories/
  auth_repository.dart
```

- Keep provider SDK calls behind `GoogleAuthAdapter` (or the existing Auth0 abstraction).
- Keep account rows presentational and free of token/business logic.
- Use `AuthRepository` for the backend token exchange and user mapping.
- Reuse `AppLogo`, the app theme, loading/error widgets, and route constants.
- Inject the adapter/repository so OAuth behavior can be mocked in tests.
- Do not store or pass passwords through any app-owned widget, model, controller, or service.

## Backend integration

The current frontend/backend prompt set does not define a confirmed Google token-exchange endpoint. Do not invent a production URL silently. Add a typed repository contract such as:

```dart
Future<AuthSession> exchangeGoogleCredential({
  required String idToken,
  required AuthIntent intent,
});
```

Wire it to the backend endpoint only after that endpoint, expected token type, audience/client ID, response envelope, and account-linking rules are documented. The backend must verify the Google token server-side before issuing Vithey tokens.

## Navigation

| From | Action | To |
|---|---|---|
| Sign In | Tap **Continue with Google** | Official provider chooser or this pre-chooser |
| Register | Tap **Continue with Google** | Official provider chooser or this pre-chooser |
| Chooser | Select/add account and authenticate successfully | Home |
| Chooser | Tap **Sign In** | Sign In |
| Provider | Cancel | Chooser or originating auth screen |

## Testing and acceptance criteria

- The app-owned rendering matches `Auth Google Screen 1.png`: logo position, heading, subtitle, bordered account card, dividers, account rows, add-account row, back link, privacy copy, and legal links.
- Account rows are dynamic; the reference names/emails are fixtures and never production constants.
- Selecting an account and adding another account both delegate credential handling to the official OAuth provider.
- The app never requests, receives, stores, or logs a Google password.
- Loading, cancellation, retry, provider error, backend-exchange error, and success states are covered.
- Successful OAuth stores Vithey tokens securely and replaces the route stack with Home.
- Privacy Policy and Terms of Service open valid URLs.
- The screen remains usable with no saved accounts, many accounts, long emails, small screens, and increased text scale.
- Unit/widget tests mock the auth adapter; end-to-end tests use a sanctioned provider test configuration rather than real user credentials.

## Dependencies

- `00-foundation-prompt.md`
- `03-auth-prompt.md`
- `03-register-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- The configured Google Sign-In or Auth0 Flutter package and platform setup

## Output

Deliver a secure, responsive Google authentication account-chooser flow that reflects the supplied design while delegating all credential entry, provider account discovery, consent, and token issuance to the official OAuth implementation.
