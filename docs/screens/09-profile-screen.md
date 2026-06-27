# Profile Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `09` |
| Route | `Routes.PROFILE` |
| Flutter module | `lib/modules/profile/` |
| Backend service(s) | `user-profile-service`, `content-service` |
| Auth required | Yes |

## Purpose

Show user profile, social links, and content tabs (info, videos, posters, CV).

## Open from

- Home (avatar), bottom nav, own profile menu

## Main UI

| Element | Description |
|---------|-------------|
| Header | Avatar, name, bio, follow/edit button |
| Social links | Telegram, Facebook (`url_launcher`) |
| Tabs | Info \| Videos \| Posters \| CV |
| Settings icon | Own profile only |
| View CV | Opens Preview CV |

## Tabs

| Tab | Content |
|-----|---------|
| Info | University, major, bio |
| Videos | Grid of user's video posts |
| Posters | Grid of image posts |
| CV | CV summary + view icon |

## User actions

| Action | Result |
|--------|--------|
| Follow | Toggle follow (other users) |
| Edit | Edit profile (own) |
| View CV | Preview CV |
| View applicants | Applicant CV Preview (job poster) |
| Tap post | Post Detail |
| Settings | Settings screen |

## Logic & behavior

- `userId` from args or current user
- `isOwnProfile` controls edit/settings visibility
- Job posters see link to applicant list

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/users/me` | Own profile |
| GET | `/api/v1/users/{id}` | Other user |
| GET | `/api/v1/users/{id}/posts` | Filter by type |

## Status checklist

- [ ] UX/UI designed
- [ ] All 4 tabs implemented
- [ ] Social links work
