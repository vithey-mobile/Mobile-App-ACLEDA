# Media Prompt Index

Use this folder as the single source of truth for Home media, post cards, comments, sharing, and creation.

## Recommended reading order

1. [`01-home-prompt.md`](01-home-prompt.md) — Home shell and mixed feed orchestration.
2. [`card_poster/01.poster_sample.md`](card_poster/01.poster_sample.md) — regular Poster card.
3. [`card_poster/02.poster_video.md`](card_poster/02.poster_video.md) — Video card/playback.
4. [`card_poster/03.poster_job.md`](card_poster/03.poster_job.md) — Job card/Apply logic.
5. [`02.comment.md`](02.comment.md) — shared Facebook-style comments.
6. [`04.share.md`](04.share.md) — shared public-share/private-save sheet.
7. [`03.create_poster.md`](03.create_poster.md) — create Poster, Video, and Job posts.
8. [`05.post_detail.md`](05.post_detail.md) — full Post Detail for every post type.

## Ownership boundaries

| Prompt | Owns |
|---|---|
| Home | App bar, composer launcher, mixed ordering, pagination, shared state |
| Poster card | Image poster rendering and Follow |
| Video card | Playback, thumbnail, processing state |
| Job card | Structured job state, Apply/Applicants |
| Comment | Comment sheet, composer, comment pagination |
| Share | Public reshare vs private save |
| Create | Type/audience/media/job fields/schedule/upload/publish |
| Post Detail | Full post, comments, media, and type-specific actions |

Avoid duplicating detailed behavior between files. Component prompts own their interaction; Home only coordinates them.

## Post-type mapping

| Backend type | Create mode | Home renderer |
|---|---|---|
| `POSTER` | Regular Poster | `PosterPostCard` |
| `VIDEO` | Video | `VideoPostCard` |
| `JOB` | Job Poster | `JobPosterCard` |

All routing and mutations use stable IDs, never media/caption heuristics.

## Acceptance checklist (release gate)

- [ ] Home feed matches `screen image/home/home screen.png` — mixed cards, pagination, bottom nav
- [ ] Poster card matches `poster .png`; video card matches job poster references
- [ ] Job card Apply opens Apply CV wizard (not Post Detail)
- [ ] Comments sheet matches `comment.png` — composer, pagination
- [ ] Share sheet matches public reshare vs private save behavior
- [ ] Create post supports type selection, media upload, schedule (see `create poster/` images)
- [ ] Post detail shows full post + type-specific actions for all post types
- [ ] Dark mode readable on feed cards and sheets
- [ ] `flutter analyze` zero errors on touched files
