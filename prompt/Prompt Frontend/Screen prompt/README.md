# Vithey App — Screen Prompt Index

All frontend screen prompts live in this folder. Organized flows use subfolders so related prompts stay together.

## Start here

1. Read `Prompt Frontend/COMMON_CONTEXT.md`.
2. Read `Prompt Frontend/api-intergration/integration-contract.md`.
3. Build [`00-foundation-prompt.md`](00-foundation-prompt.md).
4. Follow the flow indexes below.

## Auth and startup

| Order | Prompt |
|---|---|
| 1 | [`auth/01-splash-prompt.md`](auth/01-splash-prompt.md) |
| 2 | [`auth/02-onboarding-prompt.md`](auth/02-onboarding-prompt.md) |
| 3 | [`auth/03-auth-prompt.md`](auth/03-auth-prompt.md) |
| 4 | [`auth/04-register-prompt.md`](auth/04-register-prompt.md) |
| 5 | [`auth/05-auth-google-1-prompt.md`](auth/05-auth-google-1-prompt.md) |
| 6 | [`auth/06-auth-google-2-prompt.md`](auth/06-auth-google-2-prompt.md) |
| 7–9 | Startup steps in [`auth/`](auth/) |

## Home media

See the dedicated [`media/README.md`](media/README.md).

| Prompt | Purpose |
|---|---|
| [`media/01-home-prompt.md`](media/01-home-prompt.md) | Mixed Home feed orchestration |
| [`media/02.comment.md`](media/02.comment.md) | Shared comments |
| [`media/03.create_poster.md`](media/03.create_poster.md) | Create Poster, Video, Job |
| [`media/04.share.md`](media/04.share.md) | Public share/private save |
| [`media/card_poster/01.poster_sample.md`](media/card_poster/01.poster_sample.md) | Regular Poster card |
| [`media/card_poster/02.poster_video.md`](media/card_poster/02.poster_video.md) | Video card |
| [`media/card_poster/03.poster_job.md`](media/card_poster/03.poster_job.md) | Job card |

## Other screens

| Prompt | Purpose |
|---|---|
| [`chat/README.md`](chat/README.md) | Private chat list, messages, participant profile |
| [`profile/README.md`](profile/README.md) | Profile, content, jobs, applicants, CV preview |
| [`upload_cv/README.md`](upload_cv/README.md) | Job description, CV update/upload, application submission |
| [`notification/01-notification-prompt.md`](notification/01-notification-prompt.md) | Notifications |
| [`chatbot/README.md`](chatbot/README.md) | Vithey AI Home, history, input, rich responses |
| [`finance/README.md`](finance/README.md) | Verification, Finance Home, payments, invoice detail |
| [`setting/README.md`](setting/README.md) | Settings home, account, privacy, security, password, help, about |

## Maintenance rules

- Keep Home/card/comment/share/create details in `media/` only.
- Keep auth/startup details in `auth/` only.
- Use stable IDs in routes and APIs; never infer type from visible copy/media.
- Update this index and the relevant subfolder README when moving prompts.
- Use [`_SCREEN-TEMPLATE.md`](_SCREEN-TEMPLATE.md) for new standalone screens.
