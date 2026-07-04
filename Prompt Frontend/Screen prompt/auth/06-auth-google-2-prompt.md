# 03D - Google Authentication Confirmation Prompt

Implement the **Google authentication account-confirmation step** for the Vithey App in Flutter, using the supplied image as the visual and interaction reference.

## Visual reference

- Reference image: `Prompt Frontend/screen image/Auth Google Screen 2.png`
- Reference canvas: approximately `302 × 656 px` (portrait mobile)
- This is the second Google authentication step, shown after an account is selected in `Auth Google Screen 1.png`.
- Match the reference when rendering an app-owned confirmation or development mock, subject to the production OAuth security rules below.

## Important implementation rule

For production authentication, prefer the official Google Sign-In, Auth0, or browser-based OAuth consent/confirmation UI. Provider-owned UI can differ across operating systems, locales, SDK versions, accounts, and requested scopes and does not need to pixel-match this concept image.

Never collect a Google password, imitate a provider page to capture credentials, embed secrets, or trust locally constructed account data as proof of identity. If this app-owned confirmation screen is retained, it may display only a safe account summary returned from an authorized provider flow; tapping **Continue** must resume or complete the official OAuth process.

## Quick info

| Field | Value |
|---|---|
| Screen ID | `03D` |
| Suggested route | `Routes.GOOGLE_AUTH_CONFIRMATION` |
| Previous step | Google account chooser (`03C`) |
| Success destination | `Routes.HOME` |
| Cancel destination | Google chooser or originating auth screen |
| Flutter module | `lib/modules/auth/` |
| Provider | Google through the configured Google Sign-In/Auth0 adapter |
| Auth required | No (public OAuth flow) |

## Goal

Confirm the Google identity selected by the user, explain the profile information requested by Vithey, allow the user to continue through the secure provider flow, or cancel without creating a session.

## Screen composition

Build the reference layout from top to bottom:

1. **System status-bar area**
   - Use a white or very light background with dark system status-bar icons.
   - Respect `SafeArea`.
   - Do not manually draw the time, signal, Wi-Fi, or battery indicators.

2. **Centered confirmation card**
   - Place a tall card within approximately `23 px` horizontal margins.
   - The card begins well below the status bar and extends through most of the viewport.
   - Use a white/light-neutral surface, thin medium-gray outline, and approximately `6–8 px` corner radius.
   - Keep card content centered with roughly `24 px` internal horizontal padding.
   - Allow the page/card body to scroll when the viewport is short or text scaling is increased.

3. **Google mark**
   - Show the official multicolor Google `G` near the top of the card.
   - Use the approved asset/package and preserve its colors and aspect ratio.
   - Do not recolor, distort, or substitute the Vithey logo in this position.

4. **Heading**
   - Centered text: **Continue to Vithey**.
   - Bold dark charcoal, approximately `18 px` in the reference.

5. **Consent explanation**
   - Center this exact reference copy below the heading:

     **To continue, Google will share your name, email address, and profile picture with Vithey.**

   - Use small muted-gray text across multiple centered lines.
   - Keep the wording synchronized with the actual OAuth scopes and provider disclosure. If the requested data changes, update the copy and privacy documentation.

6. **Selected account avatar**
   - Display a large circular avatar approximately `96–100 px` across.
   - Use the provider-returned profile photo when available.
   - Clip the image to a circle with `BoxFit.cover`.
   - If no image is available, use an accessible initials/avatar placeholder; do not bundle a real user's photo as a production default.

7. **Selected account identity**
   - Display the selected user's full name centered in bold dark text.
   - Display the email address below in smaller muted-gray text.
   - The reference uses **Khorn Molika** and **molika.ops@aub.edu.kh** as fixtures only. Do not hard-code them in production.
   - Long names/emails must truncate gracefully and expose the complete value through accessibility semantics.

8. **Primary continue action**
   - Full-width teal rounded button inside the card.
   - Dynamic label: **Continue as {firstName}** or another consistent display-name strategy.
   - White bold text, teal fill close to `#08B9B3`, and approximately `8 px` corner radius.
   - Preserve at least a `44 px` logical tap height.
   - The button label must derive from the same selected-account object as the displayed name and email.

9. **Cancel action**
   - Full-width white/transparent button immediately below Continue.
   - Use a thin cool-gray outline, rounded corners, and centered dark text: **Cancel**.
   - Tapping Cancel clears temporary confirmation state and returns to the chooser or originating auth page without authenticating.

10. **Existing-account prompt**
    - Center a compact row below the buttons:
      - Muted-gray text: **Already have an account.**
      - Teal link: **Sign In**
    - Tapping **Sign In** cancels the OAuth flow and returns to `Routes.LOGIN` / `Routes.AUTH` without duplicate routes.

## Reference inconsistency to correct

The mockup displays **Khorn Molika** but labels the primary button **Continue as Heng**. Treat this as a design-data inconsistency, not intended behavior. The avatar, full name, email, semantic label, and Continue button text must all come from one immutable selected-account summary and must never identify different users.

## Visual style

| Token | Direction |
|---|---|
| Page background | White / very light cool gray, approximately `#FAFBFC` |
| Card background | White / near-white |
| Card outline | Medium cool gray |
| Heading/name | Dark charcoal, approximately `#303236` |
| Supporting text | Muted gray |
| Primary button/link | Vithey teal, approximately `#08B9B3` |
| Secondary button | White with light-gray border |
| Font | App theme font with a clean sans-serif appearance |

Do not add a wave header, app bar, password input, editable email field, terms checkbox, unrelated social providers, or extra profile details.

## Responsive behavior

- Preserve the centered-card composition on narrow portrait devices and adapt cleanly to larger screens.
- Use `SafeArea`, `LayoutBuilder`, and constraints instead of absolute screen coordinates.
- Limit card width on tablets so it does not stretch excessively.
- Allow scrolling when the content cannot fit due to short height, localization, or increased text scale.
- Keep both action buttons reachable and prevent clipping at `320 px` width.
- Handle long localized text, names, and emails without horizontal overflow.
- Keep loading indicators from changing button dimensions.

## Data model

Use a safe, immutable account summary supplied by the auth adapter, for example:

```dart
class GoogleAccountSummary {
  final String providerAccountId;
  final String displayName;
  final String email;
  final Uri? photoUrl;
}
```

- Do not place Google access tokens, ID tokens, authorization codes, passwords, or provider secrets in the display model.
- Do not log personally identifiable account data in production analytics or debug output.
- Validate that the selected summary belongs to the active OAuth transaction before rendering or continuing.

## OAuth behavior

1. Receive the selected account summary and current OAuth transaction from the account-chooser step or provider callback.
2. Render the name, email, and avatar from that single selected account.
3. On **Continue as {name}**, set a busy state and resume/launch the official provider authorization flow using a supported account/login hint if available.
4. Let the OAuth library manage authorization, PKCE, `state`, `nonce`, redirects, and provider token handling.
5. Send the verified provider authorization result or ID token to the Vithey backend exchange operation.
6. The backend verifies provider signature, issuer, audience, expiry, and nonce/account-linking rules before issuing Vithey tokens.
7. Save only the resulting Vithey `access_token` and `refresh_token` in secure storage.
8. Clear temporary OAuth state and navigate with `Get.offAllNamed(Routes.HOME)`.

Suggested controller methods:

- `loadGoogleConfirmation(GoogleAccountSummary account)`
- `continueWithSelectedGoogleAccount()`
- `cancelGoogleConfirmation()`
- `returnToSignIn()`
- `retryGoogleConfirmation()`

Expose states such as `ready`, `launchingProvider`, `exchangingToken`, `success`, `cancelled`, and `error`. Prevent duplicate Continue/Cancel actions while a provider operation or exchange is active.

## Loading, cancellation, and errors

- While continuing, replace or accompany the button label with a compact spinner while keeping button size stable.
- Disable Continue and Cancel during irreversible callback/token-exchange processing; allow provider cancellation through the provider UI.
- Treat user cancellation as a normal outcome, not a critical error.
- On a retryable network/provider error, keep the selected safe account summary and show a concise message with Retry/Cancel behavior.
- On invalid `state`, nonce, expired transaction, account mismatch, or failed token verification, clear the transaction and restart the OAuth flow.
- Never expose raw tokens, codes, stack traces, or provider response bodies to the user.

## Accessibility

- Add semantic labels for the Google mark, selected avatar, identity summary, Continue button, Cancel button, and Sign In link.
- The Continue semantic label should include the same user identity shown visually.
- Ensure all interactive targets are at least `44 × 44 logical pixels`.
- Maintain sufficient text, border, and control contrast.
- Support logical keyboard/focus order: heading → identity → Continue → Cancel → Sign In.
- Announce loading, cancellation, success, and error changes to assistive technology.

## Architecture

Suggested structure:

```text
lib/modules/auth/
  auth_controller.dart
  google_account_chooser_screen.dart
  google_auth_confirmation_screen.dart
  widgets/
    google_account_avatar.dart
    google_confirmation_card.dart

lib/data/models/
  google_account_summary.dart

lib/data/services/
  google_auth_adapter.dart
  auth_service.dart

lib/data/repositories/
  auth_repository.dart
```

- Reuse the same `GoogleAccountSummary`, OAuth transaction, and `GoogleAuthAdapter` established for Screen 1.
- Keep provider SDK calls behind the adapter and backend exchange logic in `AuthRepository`.
- Keep the confirmation card presentational and free of token/network logic.
- Reuse core theme, buttons, loading/error components, and route constants where they can reproduce the reference.
- Inject the adapter and repository for deterministic tests.

## Backend integration

The current project prompts do not define a confirmed Google token-exchange endpoint. Do not silently invent one. Use the typed repository boundary established in the Screen 1 prompt:

```dart
Future<AuthSession> exchangeGoogleCredential({
  required String idToken,
  required AuthIntent intent,
});
```

Wire this method only after the backend endpoint, expected credential type, client audience, response envelope, new-user behavior, and existing-account linking rules are documented. The server—not the Flutter client—must establish that the Google credential is valid.

## Navigation

| From | Action | To |
|---|---|---|
| Google chooser | Select account | Confirmation/provider consent |
| Confirmation | Continue successfully | Home |
| Confirmation | Cancel | Google chooser or originating auth screen |
| Confirmation | Tap **Sign In** | Sign In |
| Provider | Cancel | Confirmation or originating auth screen |

## Testing and acceptance criteria

- The app-owned rendering matches `Auth Google Screen 2.png`: centered outlined card, Google mark, heading, disclosure, circular avatar, identity, teal Continue button, outlined Cancel button, and Sign In link.
- Account name, email, avatar, Continue text, and semantics always represent the same selected account.
- Reference identity data is used only in fixtures, previews, or tests—not production constants.
- Continue delegates authentication/consent to the official provider and never asks for a Google password.
- Cancel creates no session, stores no tokens, and returns safely.
- Successful OAuth exchanges a verified provider result, stores Vithey tokens securely, clears temporary state, and replaces the route stack with Home.
- Loading, provider cancellation, retryable error, expired transaction, account mismatch, backend rejection, and success states are tested.
- Widget tests cover long names/emails, missing avatar, small screens, and increased text scale.
- No OAuth tokens, codes, secrets, or unnecessary personal data appear in logs.

## Dependencies

- `00-foundation-prompt.md`
- `03-auth-prompt.md`
- `03-register-prompt.md`
- `03-auth-google-1-prompt.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- The configured Google Sign-In or Auth0 Flutter package and platform setup

## Output

Deliver a secure, responsive Google account-confirmation flow that reproduces the supplied concept when app-owned UI is appropriate, keeps all selected-account data consistent, and delegates credentials, provider consent, and token issuance to the official OAuth implementation.
