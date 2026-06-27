# 09 - Profile Screen Prompt

Build the **Profile** module for Vithey App.

## Goal
Display user profile with info, videos, posters, CV tabs; social links; navigation to Preview CV and applicant CV list for job posters.

## Depends On
- `04-home-prompt.md`, `08-preview-cv-prompt.md`

## Reuse From Core
- `UserAvatar`
- `AppAppBar`
- `SectionHeader`
- `CustomButton`
- `ShimmerListTile`
- `EmptyStateWidget`
- `url_launcher` for Telegram/Facebook

## Module Files
```text
lib/modules/profile/
  profile_screen.dart
  profile_controller.dart
  profile_binding.dart
  widgets/
    profile_header.dart       # Avatar, name, bio, follow/edit button
    profile_tabs.dart         # TabBar: Info | Videos | Posters | CV
    user_info_tab.dart
    user_video_tab.dart
    user_poster_tab.dart
    user_cv_tab.dart
    view_cv_icon.dart         # Tap → Preview CV
    social_link_row.dart

lib/data/repositories/profile_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Header | Avatar, name, bio, Telegram, Facebook |
| Tabs | Info, Videos, Posters, CV |
| Own profile | Edit button, settings icon |
| Other user | Follow button |
| Job poster | Link to Applicant CV Preview |
| API | `GET /users/{id}`, user posts filtered by type |

## Controller Logic
- `userId` from arguments or current user
- `isOwnProfile` computed
- `fetchProfile()`, `fetchUserPosts(type)`
- `toggleFollow()`, `openTelegram()`, `openFacebook()`
- `navigateToPreviewCv()`, `navigateToApplicantCvs()` (if job poster)

## UI Requirements
- `profile_header` with gradient cover optional
- `profile_tabs` + `TabBarView` with 4 tabs
- Video tab: grid of thumbnails → post detail
- Poster tab: image grid
- CV tab: `view_cv_icon` + file summary
- Settings gear in app bar when own profile

## Reusable Design
- `social_link_row` — if used elsewhere, move to core
- Grid tile for videos/posters: consider `lib/core/widgets/media_grid_tile.dart` if Home also needs grids

## Route Registration
Add `Routes.PROFILE` with optional `userId` parameter

## Output
Full profile with tabs and navigation to CV preview.
