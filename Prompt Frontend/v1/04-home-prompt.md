# 04 - Home Screen Prompt

Build the **Home** feed module for Vithey App.

## Goal
Display a Facebook-style social feed with video, poster, and job posts. Support like, comment, follow, and navigate to post detail / apply CV.

## Depends On
- `03-auth-prompt.md`, foundation core widgets

## Reuse From Core
- `UserAvatar`
- `AppAppBar`
- `ShimmerListTile`
- `EmptyStateWidget`
- `AppErrorWidget`
- `LoadingWidget`
- `CustomButton` (for retry, FAB)

## Module Files
```text
lib/modules/home/
  home_screen.dart
  home_controller.dart
  home_binding.dart
  widgets/
    post_card.dart            # Base card shell — shared layout
    video_post_card.dart      # Extends/composes post_card
    poster_post_card.dart
    job_post_card.dart
    feed_action_bar.dart      # Like, comment, share row
    mention_text.dart         # Highlight @mentions

lib/data/models/post_model.dart
lib/data/models/comment_model.dart
lib/data/repositories/post_repository.dart
lib/data/services/post_service.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Purpose | Social feed |
| Post types | Video, poster, job poster |
| Actions | Like, comment, follow, apply (jobs) |
| API | `GET /posts?page&limit` |
| Nav | Post tap → Post Detail; Apply → Apply CV; Avatar → Profile |

## Controller Logic
- `fetchPosts()` — paginated list, pull-to-refresh
- `loadMore()` — infinite scroll when near bottom
- `toggleLike(postId)`
- `toggleFollow(userId)`
- `RxList<PostModel> posts`, loading/error/empty states
- Bottom nav or drawer: Home, Create Post, Chat, Notifications, Profile

## UI Requirements
- `RefreshIndicator` on feed list.
- Shimmer placeholders while loading (3–5 `ShimmerListTile`).
- `post_card.dart` provides shared header (avatar, name, time) + content slot.
- Type-specific cards compose `post_card` + media section.
- Job card shows **Apply** button using `CustomButton`.
- FAB or nav item → Create Post.
- App bar: logo, search icon (optional), notification icon.

## Reusable Component Design
```text
post_card (module)
  ├── uses UserAvatar (core)
  ├── uses feed_action_bar (module)
  └── child: video | poster | job content widget
```
If `feed_action_bar` or `mention_text` is needed on Post Detail too, consider promoting to `core/widgets/` in prompt 06.

## Route Registration
Add `Routes.HOME` as main shell (may use nested nav).

## Testing
- Widget test: `job_post_card` shows Apply button
- Controller test: pagination appends items

## Output
Working feed UI with mock data fallback and navigation hooks.
