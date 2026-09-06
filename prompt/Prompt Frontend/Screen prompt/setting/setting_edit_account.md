# Settings Edit Account Prompt

Build the **Edit Account** screen for Vithey App in Flutter.

## Quick info

| Field | Value |
|---|---|
| Route | `AppRoutes.settingsEditAccount` (`/settings/account/edit`) |
| Flutter module | `lib/modules/settings/account/` |
| Backend services | `user-profile-service`, `auth-service`, `file-service` |
| Auth required | Yes |
| Entry point | Settings Account → **Edit personal info** |

## Goal

Let the user edit **private personal account fields only**, using the **same interaction model as Edit Profile**:

- **No inline text fields** on the main screen.
- Each field is a **tappable row** showing the current value.
- Tap a row (e.g. **Full name**) → **bottom sheet** dialog to edit.
- Footer **Save** / **Cancel** persists or discards the draft.

Professional fields (bio, skills, work, education, links) stay on **Edit Profile** — do not include them here.

## Visual requirements

### Shell

- Use `SettingsScaffold` (Settings gray page + collapsing title).
- Title: **Edit account**.
- Bottom nav remains (Settings shell).

### Header

- Centered avatar + camera button (same as Account).
- Do **not** show an “Update Information” link.

### Field rows (Edit Profile style)

- Group in a white rounded card under section label **Personal**.
- Each row: primary icon + label + current value (or `Not set`) + chevron.
- **No** `TextField` / `VitheyField` on the list itself.

| UI label | Model field | Sheet behavior |
|---|---|---|
| Full name | `fullName` | Required text sheet |
| Email | `email` | Tap → **Google account chooser** (same UI as sign-up Google auth). Confirm account → draft email updates. Auth-managed; not a text sheet. |
| Phone | `phone` | Phone keyboard sheet |
| Date of birth | `dateOfBirth` | Date picker inside sheet |
| Gender | `gender` | Text sheet |
| Location | `location` | Text sheet |

### Bottom sheets

Reuse Edit Profile sheet chrome:

- `showEditProfileSheet` from `modules/profile/widgets/edit_profile_bottom_sheet.dart`
- Drag handle, title, field(s), **Submit** / **Cancel**
- Controllers owned by sheet `State` (dispose after route removed)

Sheet helpers live in:

```text
lib/modules/settings/account/widgets/account_section_sheets.dart
```

Examples:

- Tap **Full name** → sheet titled `Edit full name` with one text field.
- Tap **Date of birth** → sheet with read-only field + calendar picker.
- Submit updates **local draft** on Edit Account controller (does not PATCH until Save).

### Footer

- Row: primary **Save** + outline **Cancel** (same pattern as Edit Profile).
- Save validates full name, calls `ProfileRepository.updateProfile` for personal fields only, then `Get.back(result: true)`.
- Cancel / back without save → `Get.back(result: false)`.

## Out of scope on this screen

| Field | Reason |
|---|---|
| Bio, skills, work, education, links | Edit Profile |
| Stats | Read-only elsewhere |
| Student verification | Account overview → verification route |
| Inline list text fields | Forbidden — sheets only |

## Architecture

```text
lib/modules/settings/account/
  edit_account_settings_screen.dart
  edit_account_settings_controller.dart
  edit_account_settings_binding.dart
  widgets/
    account_section_sheets.dart
```

## Controller behavior

- `loadProfile()` — load into draft observables / controllers for display values.
- `changeAvatar()` — gallery → update draft avatar (persist on Save or immediately if product prefers; default: persist avatar immediately like Account).
- Sheet openers: `editFullName`, `editPhone`, `editGender`, `editLocation`, `editDateOfBirth` — update draft on sheet success.
- `save()` — PATCH personal fields only (`fullName`, `phone`, `gender`, `location`, `dateOfBirth`, `avatarUrl` as needed).
- Do **not** send bio/skills/work/education/links from this screen.

## Navigation

| From | Action | To |
|---|---|---|
| Account | Edit personal info | Edit Account |
| Edit Account | Save success | Pop Account with `true` → reload |
| Edit Account | Cancel / back | Pop with `false` |

## API

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/v1/users/me` | Load |
| `PATCH` | `/api/v1/users/me` | Personal fields only |
| `POST` | `/api/v1/files/upload` | Avatar |
| `PATCH` | `/api/v1/users/me/avatar` | Avatar |

## Empty / error states

- Loading / error same as Account.
- Sheet cancel leaves draft unchanged.
- Save failure: snackbar; keep draft on screen.

## Testing

- [ ] No text fields on the Edit Account list.
- [ ] Tap Full name opens bottom sheet; Submit updates row value.
- [ ] Email tap does not open an edit sheet.
- [ ] Save persists and Account refreshes.
- [ ] Cancel discards draft changes.
- [ ] No professional fields on this screen.
- [ ] Light + dark mode OK.

## Output

Edit Account screen matching **Edit Profile** interaction (row → bottom sheet), Settings visual system, personal-fields-only, registered route from Account.
