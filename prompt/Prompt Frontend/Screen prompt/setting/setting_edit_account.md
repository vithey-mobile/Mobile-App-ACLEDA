# Settings Edit Account Prompt

Build the **Edit Account** screen for Vithey App in Flutter, matching:

- `Prompt Frontend/screen image/setting/setting_edit_account.png`

## Quick info

| Field | Value |
|---|---|
| Route | `Routes.SETTING_EDIT_ACCOUNT` |
| Flutter module | `lib/modules/settings/account/` |
| Backend services | `user-profile-service`, `auth-service`, `file-service` |
| Auth required | Yes |
| Entry point | Settings Account → **Update Information** |

## Goal

Let the user edit **all** `UserProfileModel` account fields except **Stats** on a dedicated scrollable screen. Skills support add and remove. Proficiency is read-only. Replace the previous bottom-sheet edit modal.

## Visual requirements

Match `setting_edit_account.png` layout style (elevated cards, avatar header, pinned Save button). Extend with additional field cards using the same card pattern.

### App bar

- Back arrow on left.
- Bold title: **Account**.
- Thin divider below.
- No bottom navigation on this screen (push route, not tab root).

### Profile header

- Centered circular avatar near top.
- Small teal camera button overlapping bottom-right of avatar — upload from device gallery.
- Do **not** show the **Update Information** link on this screen.

### Input cards

Each field uses the same elevated card pattern:

- Rounded corners (~12px) with soft shadow.
- Top row: primary-colored outline icon + muted label.
- Below: full-width rounded text field (or custom editor for skills / date).
- Consistent vertical spacing (~12px).
- Group fields with section labels where helpful.

### Editable fields (all except Stats)

| Section | UI label | Model field | Input type |
|---|---|---|---|
| Profile | Avatar | `avatarUrl` | Device gallery upload |
| Basic | Full Name | `fullName` | Text |
| Basic | Bio | `bio` | Multiline text |
| Basic | Email | `email` | Read-only text |
| Basic | Phone | `phone` | Phone keyboard |
| Basic | Date of Birth | `dateOfBirth` | Date picker |
| Basic | Location | `location` | Text |
| Academic & Career | University | `university` | Text |
| Academic & Career | Major | `major` | Text |
| Academic & Career | Graduation Year | `graduationYear` | Number |
| Academic & Career | Education | `education` | Multiline (one entry per line) |
| Academic & Career | Workplace | `workplace` | Text |
| Academic & Career | Student Verified | `isStudentVerified` | Read-only badge (not editable) |
| Social & Links | Telegram Link | `telegramLink` | URL text |
| Social & Links | Facebook Link | `facebookLink` | URL text |
| Social & Links | Portfolio URL | `portfolioUrl` | URL text |
| Skills | Skills | `skills` | Add / remove list (see below) |

### Skills editor

Dedicated card section for `List<ProfileSkill>`:

- Show each skill as a row with:
  - Skill name (editable text field).
  - **Proficiency** 0–100 — read-only disabled progress bar showing current value; users cannot change it manually.
  - Remove button (`X` icon).
- **Add Skill** button at bottom of section — appends a new empty skill row (default proficiency e.g. 50, not editable).
- Removing the last skill is allowed (empty list OK).
- Validate: skill name required before save.

Example skill row data: `ProfileSkill(name: 'Flutter', proficiency: 75)`.

### Not editable on this screen

| Field | Reason |
|---|---|
| `followerCount`, `followingCount`, `postCount`, `likeCount` | Stats — read-only on account view only |
| `email` | Auth-managed; display read-only |
| `isStudentVerified` | System badge; display read-only |
| `id`, `isFollowing` | Internal / not user-editable |

### Save button

- Full-width teal primary button pinned near bottom (safe-area padding).
- Rounded corners (~12px).
- White bold label: **Save** — **centered horizontally and vertically** in the button.
- Loading spinner centered while saving.
- Do not use left-aligned shadcn button text for Save.

## Light & dark mode

Use semantic theme colors — do not hard-code white/black:

| Element | Light | Dark |
|---|---|---|
| Page background | `appColors.bodyBackground` | dark body background |
| Card surface | `appColors.cardSurface` | dark card surface |
| Labels / icons | `appColors.muted` | muted text |
| Input text | `appColors.heading` | light heading text |
| Input fill | `appColors.inputFill` | dark input fill |
| Input border | `appColors.border` | dark border |
| Primary button | `colorScheme.primary` | primary (lighter teal) |
| Shadow | `appColors.subtleShadow` | stronger subtle shadow |

Verify contrast for labels, inputs, skill chips, and Save button in both themes.

## Architecture

```text
lib/modules/settings/account/
  edit_account_settings_screen.dart
  edit_account_settings_controller.dart
  edit_account_settings_binding.dart
  widgets/
    edit_account_field_card.dart
    edit_account_skills_editor.dart
    edit_account_date_field.dart
    edit_account_save_button.dart
    account_avatar_editor.dart
```

## Controller behavior

- `loadProfile()` — fetch `UserProfileModel` via `ProfileRepository.getProfile(currentUserId)`.
- `changeAvatar()` — image picker → upload (`type=AVATAR`) → update `avatarUrl`.
- `pickDateOfBirth()` — open date picker; update `dateOfBirth`.
- `addSkill()` — append empty `ProfileSkill` to editable skills list.
- `removeSkill(int index)` — remove skill at index.
- `updateSkill(int index, {String? name})` — update skill name only; proficiency is preserved from existing data.
- `save()`:
  1. Validate full name not empty.
  2. Validate skills (non-empty names).
  3. Call `ProfileRepository.updateProfile(...)` with API-supported fields.
  4. Include `avatarUrl` from local uploads.
  5. `Get.back(result: true)` on success.

## Navigation

| From | Action | To |
|---|---|---|
| Settings Account | Tap **Update Information** | `Routes.SETTING_EDIT_ACCOUNT` |
| Edit Account | Save success / back | Pop to Settings Account |
| Settings Account | Returns with `result: true` | Reload profile |

## API

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/v1/users/me` | Load profile |
| `PATCH` | `/api/v1/users/me` | Update supported profile fields |
| `POST` | `/api/v1/files/upload` | Avatar upload (`type=AVATAR`) |
| `PATCH` | `/api/v1/users/me/avatar` | Save avatar |

## Empty/error states

- Loading: spinner while profile loads.
- Load error: `AppErrorWidget` with Retry.
- Nullable fields: empty input allowed unless validation requires value.
- Skills empty: show empty state + Add Skill CTA.
- Save failure: snackbar; keep form values on screen.

## Testing

- All editable fields from `UserProfileModel` (except Stats) appear on edit screen.
- Email and Student Verified are read-only.
- Skills can be added and removed; proficiency bar is disabled/read-only.
- Save button label is centered.
- Avatar upload from device gallery.
- Save persists and account view refreshes.
- Correct in light and dark mode.

## Output

Complete Edit Account screen matching `setting_edit_account.png` style, all non-Stats fields editable, skills add/remove with read-only proficiency, centered Save button, avatar device upload, registered route, navigation from Settings Account.
