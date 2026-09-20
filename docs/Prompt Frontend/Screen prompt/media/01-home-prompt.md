# 01 - Home Media Feed Prompt

Build the Vithey **Home media feed** in Flutter as one chronological, paginated list containing three typed post cards: regular posters, videos, and job posters.

This file owns the Home shell, feed orchestration, pagination, shared state, and routing. Detailed components live beside it:

- Comments: `02.comment.md`.
- Create Poster/Video/Job: `03.create_poster.md`.
- Share sheet: `04.share.md`.
- Regular poster card: `card_poster/01.poster_sample.md`.
- Video card: `card_poster/02.poster_video.md`.
- Job poster card: `card_poster/03.poster_job.md`.

## Visual references

- `Prompt Frontend/screen image/home/home screen.png`.
- Card and interaction references are listed in the component prompts.

## Quick info

| Field | Value |
|---|---|
| Route | `Routes.HOME` |
| Module | `lib/modules/home/` |
| Backend services | `content-service`, `career-service`, `user-profile-service` |
| Auth required | Yes |
| Feed types | `POSTER`, `VIDEO`, `JOB` |

## Goal

Display a Facebook-style mixed media feed where all three post types preserve API order and share common social actions while rendering their own media/body/action behavior.

## Screen layout

### App bar

- White safe-area-aware app bar.
- Left: Vithey logo and **Vithey**.
- Right: Notifications, Search, and Finance shortcuts.
- Notification opens `Routes.NOTIFICATION`; Finance opens `Routes.FINANCE`.
- All targets are at least `44 × 44` logical pixels.

### Create-post launcher

- Current-user avatar.
- Rounded prompt: **What’s on your mind?**.
- Gallery icon at right.
- Prompt opens `Routes.CREATE_POST`.
- Gallery opens Create Post with a Poster/media-picker intent.
- This is a launcher, not an editable Home text field.

### Mixed feed

- One lazy vertical list with stable post IDs.
- Preserve server order; never group types into separate Home sections.
- Dispatch strictly by typed `post.type`:
  - `POSTER` → `PosterPostCard`.
  - `VIDEO` → `VideoPostCard`.
  - `JOB` → `JobPosterCard`.
- Unknown types render a safe unsupported item or are skipped/reported by repository policy; they never crash the feed.
- Body/media tap opens Post Detail.
- Author tap opens Profile.
- Comment tap opens the sheet in `02.comment.md`.
- Share tap opens the sheet in `04.share.md`.
- Card-specific actions follow the three card prompts.

### Bottom navigation

Use the shared five-item shell:

1. Home — active teal.
2. Finance.
3. Raised center Create action.
4. Chat.
5. Profile.

Preserve Home scroll/feed state when switching tabs.

## Shared feed model

Use a typed discriminator and normalized models:

```dart
enum PostType { poster, video, job }

sealed class FeedPost {
  String get id;
  PostType get type;
  PostAuthor get author;
  String get content;
  Uri? get mediaUrl;
  DateTime get createdAt;
  int get reactionCount;
  int get commentCount;
  int get shareCount;
  bool get userReacted;
}
```

Type models add only their required fields:

- `PosterFeedPost` — poster media and follow relationship.
- `VideoFeedPost` — duration, thumbnail, processing/playback state.
- `JobFeedPost` — structured job metadata and application state.

Normalize raw API envelopes in `PostRepository`. Widgets never inspect JSON or infer type from caption/media.

## Shared card shell

All cards compose `PostCard`:

1. Author header: avatar, name, relative time, type-specific right action.
2. Safe plain/mention-aware caption.
3. Type-specific media/body.
4. Engagement footer: Like, Comment, Share and counts.

Shared rules:

- White card with subtle border/shadow and compact spacing.
- Remote image/avatar placeholders and error fallbacks.
- No raw HTML execution.
- Action taps stop card-body navigation.
- At least `44 × 44` action targets.
- Owner cards never show self-Follow or self-Apply.

## Controller behavior

Implement:

- `fetchInitialFeed()`.
- `refreshFeed()`.
- `loadMore()`.
- `toggleReaction(postId)`.
- `toggleFollow(authorId)`.
- `openComments(postId)`.
- `openShareTypes(postId)`.
- `openPost(postId)`.
- `openJobApplication(jobPostId)`.
- `insertCreatedPost(CreatedPostResult result)`.
- `retryFeed()`.

Keep separate states for initial load, refresh, pagination, empty/error, per-post reaction, per-author follow, per-job application, comments, share/save, and per-video playback/processing.

## Optimistic synchronization

- Reaction updates one post immediately and rolls back on failure.
- Follow updates every visible card by the same author.
- Comment creation synchronizes comment count across Home and Post Detail.
- Public share updates share count once; private save does not.
- Successful job application changes the matching job card to Applied.
- Created immediate posts upsert at index 0 by ID; scheduled/private posts appear only when eligible.
- Counts never become negative and rapid taps never create parallel mutations.

## Pagination and refresh

- `RefreshIndicator` wraps the feed.
- Show 3–5 card-shaped skeletons initially.
- Load next page near the end, never concurrently.
- Append while deduplicating by `post_id`.
- Footer spinner for load-more; footer Retry on failure.
- Pull-to-refresh reconciles mutations safely.
- Preserve scroll position after Post Detail, comments, share sheet, Apply CV, and bottom-tab navigation.

## API

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/posts` | Mixed paginated feed |
| `GET` | `/api/v1/posts/{id}` | Detail |
| `POST` | `/api/v1/posts/{id}/reactions` | Toggle Like |
| `POST` | `/api/v1/users/{id}/follow` | Follow |
| `DELETE` | `/api/v1/users/{id}/follow` | Unfollow |

Comment, share/save, upload/create, and job-application APIs are owned by their component prompts.

## Required feed contract

Every item should return:

- `post_id`, `type`, `content`, `created_at`.
- Author ID/name/avatar.
- Media URL/metadata appropriate to type.
- Reaction/comment/share counts and current-user states.
- `is_following_author` or a batch-safe relationship state.
- Video duration/thumbnail/processing state for VIDEO.
- Structured `job_meta`, lifecycle, applicant/current-user application state for JOB.

Avoid one network call per card. Missing optional contract fields hide/disable the affected UI rather than showing fake values.

## Empty and error states

- Empty feed: friendly message and Create/follow action.
- Initial error: full `AppErrorWidget` with Retry.
- Pagination error retains items.
- One malformed item does not crash the list.
- `401` uses the global refresh-token flow.
- Deleted target routes show content-unavailable state.

## Accessibility and performance

- Label app-bar, launcher, author, post type, media, social actions/counts, card actions, and bottom navigation.
- Announce mutation state changes without excessive chatter.
- Support `320 px`, large text, long names/captions, and tablets with max content width.
- Lazy-build cards and cache/rescale media to display dimensions.
- Never autoplay multiple videos; dispose/offload controllers when cards leave the active range.
- Avoid full-resolution image/video decoding for list thumbnails.

## Architecture

```text
lib/modules/home/
  home_screen.dart
  home_controller.dart
  home_binding.dart
  widgets/
    home_app_bar.dart
    create_post_composer.dart
    mixed_post_feed.dart
    post_card.dart
    post_author_header.dart
    feed_action_bar.dart
    poster_post_card.dart
    video_post_card.dart
    job_poster_card.dart
    home_bottom_navigation.dart
```

- Card widgets implement the card prompts; Home owns ordering/state orchestration.
- Comment/share sheets remain modular.
- API and business mutations stay outside widgets.

## Testing and acceptance criteria

- Matches `home screen.png` shell, launcher, feed density, and bottom navigation.
- An alternating POSTER/VIDEO/JOB response renders in exact API order.
- Each type dispatches to the correct component prompt.
- Comment/Share action taps open the correct post sheet without firing Post Detail.
- Follow state synchronizes by author; Apply state synchronizes by job ID.
- Created posts insert once only when immediately visible.
- Initial/refresh/empty/error/pagination states work without losing existing feed.
- No overflow or stale-card mutation occurs on small screens, large text, and rapid scrolling.

## Dependencies

- `../00-foundation-prompt.md`
- `02.comment.md`
- `03.create_poster.md`
- `04.share.md`
- `card_poster/01.poster_sample.md`
- `card_poster/02.poster_video.md`
- `card_poster/03.poster_job.md`
- `05.post_detail.md`
- `Prompt Frontend/api-intergration/integration-contract.md`

## Output

Deliver one robust Home media feed that orchestrates regular poster, video, and job cards while delegating detailed component behavior to the organized media prompt files.
