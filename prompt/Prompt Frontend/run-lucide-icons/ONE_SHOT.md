# GLM 5.3 Flash — Lucide icons (ONE PROMPT)

**Run only this file.** One chat. Paste everything below `---` .

---

You are a Flutter icons agent for Vithey. In **one pass**, migrate **all UI Material `Icons.*` glyphs to Lucide**. Do not split into multiple chats.

## Project

App root: `vithey_app/`  
Brand stays teal. Do **not** restyle layouts, colors, radii, routes, or business logic — **glyph swap only**.

## Step 1 — Barrel (do first)

Create `vithey_app/lib/core/icons/vithey_icons.dart`:

```dart
/// Lucide icons for Vithey UI.
/// Feature modules must import this file — never `shadcn_flutter` directly.
library;

export 'package:shadcn_flutter/shadcn_flutter.dart' show LucideIcons;
```

Export it from `vithey_app/lib/core/widgets/widgets.dart`.

Add a short note to `prompt/Prompt Frontend/COMPONENT_KIT.md`:
- UI glyphs = `LucideIcons` via `core/icons/vithey_icons.dart`
- Modules must not import `shadcn_flutter`
- Do not use Material `Icons.*` for chrome

## Step 2 — Replace icons everywhere

Search and replace under:

```text
vithey_app/lib/modules/**          # auth home profile jobs finance chat chatbot search settings map
vithey_app/lib/core/widgets/**
vithey_app/lib/core/alerts/**
vithey_app/lib/data/models/**      # only IconData catalogs (skills, startup draft, etc.)
```

For every UI `Icons.foo` / `Icon(Icons.foo)`:

1. Import: `package:aub_connect_app/core/icons/vithey_icons.dart`  
   (or kit `widgets.dart` if already imported)
2. Swap to `LucideIcons.bar` using the map below
3. Keep size / color / IconTheme behavior

### Already Lucide (fix imports only)

Home / chat list app bar may already use `LucideIcons.search|map|messageCircle|wallet`.  
If they import `shadcn_flutter` with `show LucideIcons`, **switch to the core barrel**. Do not revert to Material.

### Leave alone

- `Image.asset` / PNG under `assets/icons/**` (wallet png, skill pngs, etc.)
- Third-party packages
- Google Map platform views (only replace Flutter `Icon` / `IconData` usages)

## Material → Lucide map

| Material `Icons.*` | Lucide `LucideIcons.*` |
|--------------------|------------------------|
| `search` / `search_rounded` | `search` |
| `map_outlined` / `map` | `map` |
| `chat_bubble_outline` / `chat` | `messageCircle` |
| `account_balance_wallet_outlined` | `wallet` |
| `arrow_back` / `arrow_back_ios` | `arrowLeft` |
| `arrow_forward` / `chevron_right` | `chevronRight` |
| `chevron_left` | `chevronLeft` |
| `close` / `clear` | `x` |
| `check` / `check_circle` | `check` / `circleCheck` |
| `add` / `add_circle` | `plus` / `circlePlus` |
| `remove` / `delete` / `delete_outline` | `minus` / `trash2` |
| `edit` / `edit_outlined` | `pencil` |
| `more_vert` / `more_horiz` | `ellipsisVertical` / `ellipsis` |
| `settings` / `settings_outlined` | `settings` |
| `person` / `person_outline` | `user` |
| `people` / `group` | `users` |
| `home` / `home_outlined` | `house` |
| `notifications` / `notifications_outlined` | `bell` |
| `favorite` / `favorite_border` | `heart` |
| `share` / `share_outlined` | `share2` |
| `send` | `send` |
| `image` / `photo` | `image` |
| `videocam` / `video_library` | `video` |
| `camera_alt` | `camera` |
| `mic` / `mic_none` | `mic` |
| `attach_file` | `paperclip` |
| `link` | `link` |
| `lock` / `lock_outline` | `lock` |
| `visibility` / `visibility_off` | `eye` / `eyeOff` |
| `email` / `mail_outline` / `mark_email_unread` | `mail` |
| `phone` / `call` | `phone` |
| `location_on` / `place` | `mapPin` |
| `work` / `work_outline` | `briefcase` |
| `school` | `graduationCap` |
| `info` / `info_outline` | `info` |
| `warning` / `error` | `triangleAlert` / `circleAlert` |
| `help_outline` | `circleHelp` |
| `refresh` | `refreshCw` |
| `filter_list` | `listFilter` |
| `sort` | `arrowUpDown` |
| `calendar_today` | `calendar` |
| `access_time` / `schedule` | `clock` |
| `star` / `star_border` | `star` |
| `bookmark` / `bookmark_border` | `bookmark` |
| `copy` / `content_copy` | `copy` |
| `download` | `download` |
| `upload` | `upload` |
| `play_arrow` | `play` |
| `pause` | `pause` |
| `volume_up` / `volume_off` | `volume2` / `volumeX` |
| `fullscreen` | `maximize` |
| `logout` | `logOut` |
| `login` | `logIn` |
| `language` | `languages` |
| `dark_mode` / `light_mode` | `moon` / `sun` |
| `menu` | `menu` |
| `dashboard` | `layoutDashboard` |
| `qr_code` / `qr_code_2` | `qrCode` |
| `verified` | `badgeCheck` |
| `auto_awesome` | `sparkles` |
| `smart_toy` | `bot` |
| `code` | `code` |
| `folder` | `folder` |
| `file_present` / `description` | `fileText` |
| `payments` / `credit_card` | `creditCard` |
| `receipt` | `receipt` |
| `thumb_up` | `thumbsUp` |
| `thumb_down` | `thumbsDown` |
| `reply` | `reply` |
| `block` | `ban` |
| `report` | `flag` |
| `videocall` | `video` |
| `my_location` | `locate` |
| `layers` | `layers` |
| `navigation` | `navigation` |
| `history` | `history` |
| `shield` / `security` | `shield` |

Unlisted Material icons → nearest Lucide by meaning (`LucideIcons.` autocomplete). Do **not** leave Material `Icons.` for UI chrome.

## Step 3 — Verify

```text
rg "Icons\." vithey_app/lib
rg "shadcn_flutter" vithey_app/lib/modules
```

Targets:
- Near-zero `Icons.` in UI code
- **Zero** `shadcn_flutter` imports under `modules/`
- `dart analyze` clean on touched files

## Stop when

- Barrel exists and is exported
- All 10 modules + core widgets/alerts + IconData catalogs migrated
- Verify commands pass (aside from intentional exceptions)
- Print: files changed count + short list of common swaps + any leftovers with reason
