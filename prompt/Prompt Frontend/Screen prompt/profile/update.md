# Profile Module — As-Built Spec (ayheng)

> **Status:** Implemented in `vithey_app/lib/modules/profile/` on branch `ayheng`.  
> This file is the **source of truth** for current profile/edit-skills behavior.  
> Prompts live in this folder (flat — no version subfolders).

---

## Scope (ayheng ownership)

| Area | Status |
|------|--------|
| Profile home cover redesign | Implemented — `ProfileCoverRedesign` |
| About / Videos / Posters / Jobs / Applied Jobs | Implemented — **20px** horizontal padding |
| Edit personal info (sheets + Remove) | Implemented |
| Skills: Coding drill-down, icons, watermark rings | Implemented |
| Skills: system-owned %, immediate persist | Implemented |
| Bio: no Add, no leading icon | Implemented |
| App logo white circle (shared) | Implemented — `AppLogo` |

---

## Profile home cover

**Active widget:** `profile_cover_redesign.dart` (wired from `profile_screen.dart`).  
**Backup (inactive):** `profile_wavy_header.dart`.

| Spec | Value |
|------|-------|
| Teal cover | `#99E3DF` plane + `#016560` decor icons |
| Wave | Low → high → low boundary |
| Avatar | Overlaps wave; half on boundary |
| Under avatar | Name, bio, equal-column stats (Likes Â· Followers Â· Following) |
| Owner CTAs | Edit Profile Info / Verify Student / outlined Share |
| Visitor CTAs | Follow / Message / Share (via `ProfileActionRow`) |

---

## Profile tabs — padding & chrome

All tab bodies use **20px** left/right padding.

| Tab | List padding | Notes |
|-----|--------------|-------|
| About | `fromLTRB(20, 16, 20, 100)` | Skills row + `ProfileAboutDetails` |
| Videos | `fromLTRB(20, 0, 20, 100)` | |
| Posters | `fromLTRB(20, 0, 20, 100)` | `PosterPostCard` margin **vertical only** (no extra horizontal) |
| Jobs | `fromLTRB(20, 0, 20, 100)` | |
| Applied Jobs | `fromLTRB(20, 8, 20, 100)` | Each row in bordered `Card` (radius 12) |

---

## About — Skills display

| Spec | Value |
|------|-------|
| Widget | `ProfileSkillsRow` / `ProfileSkillRing` |
| Ring | Progress = `proficiency` 0–100; size ~80 |
| Center | Bold `%` text |
| Watermark | Technology / category logo at **~30% opacity** behind `%` (`SkillIcon`) |
| Label | Skill name under ring (max 2 lines) |
| Color | `colorValue` if set; else palette by name hash |
| Edit | Display-only on About; edit via Edit Profile Info |

`dart
class ProfileSkill {
  final String name;
  final int proficiency; // 0–100; system-owned after create
  final int? colorValue;
  final String? iconKey;
  final String? iconPath;
}
`

---

## Edit personal info — layout

**Files:** `edit_profile_screen.dart`, `edit_profile_bottom_sheet.dart`, `profile_section_sheets.dart`

`
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â†  Edit personal info               â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Skills                              â”‚  Leading âŠ• Add Skill circle + rings
â”‚ Bio                                 â”‚  Title only — no Add, no icon
â”‚ Personal details               Add  â”‚
â”‚ Work                           Add  â”‚
â”‚ Education                      Add  â”‚
â”‚ Links                          Add  â”‚
â”‚ Contact info                   Add  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ [ Save ]              [ Cancel ]    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
`

| Spec | Value |
|------|-------|
| Content padding | `fromLTRB(20, 8, 20, 24)` |
| Footer padding | `fromLTRB(20, 12, 20, 12)` |
| Sheet result | `ProfileSheetResult.saved(T)` / `.deleted()` |

### Bio

- No **Add** header button; no leading quote icon.
- Empty: tappable “No bio yet”.
- Filled: tappable text row.
- Edit sheet may show **Remove** → clears bio on confirm (saved with footer Save).

### Skills list

- First item: `ProfileAddSkillCircle` (“Add Skill”).
- Tap ring → Edit skill sheet.
- **Add / edit / remove skill persists immediately** via `persistSkills()` (repository + own ProfileController sync). About updates without waiting for footer Save.
- Footer Save still persists the full draft (bio, personal, work, ... + skills).

### Remove on edit sheets

When editing existing content, title trailing **Remove** + destructive confirm (same pattern as logout):

| Section | On confirm |
|---------|------------|
| Skill | Remove from list + persist |
| Bio | Clear local bio |
| Personal details | Clear location / gender / DOB |
| Work / Education / Links / Contact | Remove that list entry |

---

## Skill selection flow (as built)

`text
Select skill (L1) — startupSkills + Other
    â”‚
    â”œâ”€ Coding â”€â”€â–º Select category (Frontend | Backend | Other)
    â”‚                 â”‚
    â”‚                 â”œâ”€ Frontend / Backend â”€â”€â–º tech list (â‰¥20) + Other
    â”‚                 â””â”€ Other â”€â”€â–º custom name (+ optional icon/image)
    â”‚
    â”œâ”€ Other top-level â”€â”€â–º custom name (+ optional icon/image)
    â””â”€ Other categories â”€â”€â–º save category label + iconKey
`

### Catalog

| Source | Path / constant |
|--------|-----------------|
| Top-level | `startupSkills` + Other → `topLevelSkillCatalog` |
| Coding categories | `codingCategories` |
| Frontend techs | `codingFrontendSkills` (Flutter, Dart, ... Expo, Other) |
| Backend techs | `codingBackendSkills` (Java, Spring Boot, ... Kubernetes, Other) |
| Icon picker grid | `pickableSkillIcons` (Material + catalog logos) |
| Resolver | `findCatalogSkill` / `SkillIcon` |

Tech logos: official Devicon PNGs via URL (`iconUrl`), cached. Category skills use Material icons.

### Other (custom) skill fields

| Field | Required | Notes |
|-------|----------|-------|
| Skill name | Yes | |
| Choose icon | No | Full-height icon grid |
| Choose image | No | Gallery; optional |
| Remove | — | Clears custom icon/image |

### Color

- Palette swatches + rainbow custom → HSV/HEX sheet.
- Stored as `colorValue` (ARGB); null = auto palette.

### Skill level (system-owned)

| Spec | Value |
|------|-------|
| UI | Ring preview + bar (slider) |
| Interaction | **Disabled** (`onChanged: null`) — user cannot edit |
| Preset chips | **Removed** (no 25/50/75/100) |
| Helper | “Set automatically by the system” |
| New skill default | **0%** |
| Existing skill | Shows current `proficiency` from profile |

---

## Data / API notes

- Mock: `ProfileRepository.updateProfile(skills: ...)` updates in-memory store.
- API patch must include `skills` JSON array (`toJson` / `fromJson` with `iconKey`, `iconPath`, `colorValue`).
- `UserProfileModel.fromJson` parses `skills`.

---

## Key Flutter paths

`text
lib/modules/profile/
  profile_screen.dart
  profile_controller.dart
  edit_profile_screen.dart
  widgets/
    profile_cover_redesign.dart      # active cover
    profile_wavy_header.dart         # backup
    profile_tabs.dart
    profile_skills.dart
    skill_icon.dart
    profile_section_sheets.dart
    edit_profile_bottom_sheet.dart
lib/data/models/
  user_profile_model.dart            # ProfileSkill
  profile_skill_catalog.dart
  startup_profile_draft.dart
lib/core/widgets/app_logo.dart       # always white circle
`

---

## Acceptance (as built)

- [x] Cover redesign active; wavy header retained as backup
- [x] All profile tabs 20px horizontal padding; Applied Jobs bordered; Posters no double inset
- [x] Coding → Frontend/Backend/Other → tech (+ Other custom)
- [x] Logos as ~30% watermark in skill rings
- [x] Choose Icon + Choose Image for Other
- [x] Skill % display-only; new skills start at 0%
- [x] Skills persist immediately to About
- [x] Bio without Add / without icon
- [x] Remove on edit sheets with confirm
- [x] AppLogo always white circular background
