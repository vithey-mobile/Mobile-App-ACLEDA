# Profile Videos Prompt

Build the Videos tab shown in `Prompt Frontend/screen image/profile/profile_video.png`.

## Layout and behavior

- Heading **Videos** or approved **Featured Insights**.
- Fetch `GET /api/v1/users/{userId}/posts?type=VIDEO`.
- Render thumbnail cards/list with play indicator, caption/title, duration/time, and optional engagement summary.
- Tap opens Post Detail/full player.
- Do not autoplay multiple profile videos; list starts paused.
- Use server thumbnail/processing state, not full-video decoding for thumbnails.

The reference's Design For Scale/Job Applications text is fixture content only.

## Owner/visitor and states

- Own items never show self-Follow; optional owner menu only with contracts.
- Visitor sees server-authorized content.
- Per-tab skeleton, empty, refresh, pagination, processing, thumbnail error, and playback-unavailable states.
- Preserve scroll/playback position sensibly; pause on tab switch/background.

## Reuse

- `../media/card_poster/02.poster_video.md` for video model/player behavior.

## Testing

- Only VIDEO type renders.
- Processing/failed/ready states map correctly.
- Tab switch pauses playback and does not leak controllers.
- Pagination and large-text/thumbnail errors work.

## Output

Deliver a performant Profile Videos tab using the shared video post model and playback coordinator.
