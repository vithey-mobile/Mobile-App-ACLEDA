# 06 - Post Detail Screen Prompt

Build the **Post Detail** module for Vithey App.

## Goal
Show full post content, comments with @mentions, like/follow actions, and Apply CV for job posts.

## Depends On
- `04-home-prompt.md`, `05-create-post-prompt.md`

## Reuse From Core
- `UserAvatar`, `AppAppBar`, `CustomButton`, `CustomTextField`
- `LoadingWidget`, `EmptyStateWidget`, `ShimmerListTile`
- Reuse or import `video_post_card` / `poster_post_card` / `job_post_card` media sections from home module OR extract shared `post_media_view.dart` to avoid duplication

## Module Files
```text
lib/modules/post_detail/
  post_detail_screen.dart
  post_detail_controller.dart
  post_detail_binding.dart
  widgets/
    comment_list.dart
    comment_input.dart
    mention_user_box.dart       # @mention autocomplete overlay
    post_detail_header.dart

lib/data/repositories/comment_repository.dart
```

## Screen Spec
| Item | Detail |
|------|--------|
| Video | Inline `video_player` |
| Poster | Full-width `cached_network_image` |
| Job | Job details + **Apply CV** button |
| Comments | List + input with @mention |
| API | `GET /posts/{id}`, `GET /posts/{id}/comments`, `POST` comment, reactions |

## Controller Logic
- Load post by `Get.arguments` postId
- `fetchComments()`, `submitComment(text)`
- `mentionUser(user)` — insert `@username` in input
- `toggleLike()`, `toggleFollow()`
- Job post: `applyJob()` → navigate `Routes.APPLY_CV` with postId

## UI Requirements
- Scrollable column: post content → action bar → comments
- `comment_input.dart` composes `CustomTextField` + send icon button
- `mention_user_box` shows filtered user list when typing `@`
- Video autoplays muted or with play button per UX choice
- Pull comments with pagination

## Promote to Core (if reused)
If `feed_action_bar` from Home is identical, move to `lib/core/widgets/feed_action_bar.dart` and update Home + Post Detail to import it.

## Route Registration
Add `Routes.POST_DETAIL`

## Output
Full post detail with comments and job apply navigation.
