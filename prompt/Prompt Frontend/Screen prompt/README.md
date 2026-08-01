# Vithey App — Screen Prompt Index

All frontend screen prompts live in this folder. Organized flows use subfolders so related prompts stay together.

## UI version status (Flutter)

| Area | Current UI prompt set | Status in `vithey_app` |
| --- | --- | --- |
| Auth / Splash / Language / Onboarding / Startup | [`auth/v1/`](auth/README.md) | **Complete** |
| Home / media / create / post detail | [`media/`](media/README.md) | **Complete** |
| Private chat | [`chat/`](chat/README.md) | **Complete** |
| Vithey AI chatbot | [`chatbot/`](chatbot/README.md) | **Complete** |
| Profile | [`profile/v1/`](profile/README.md) | **Complete** |
| Job apply | [`job_apply/`](job_apply/README.md) | **Complete** |
| Finance + verification | [`finance/v1/`](finance/README.md) | **Complete** |
| Notifications | [`notification/`](notification/README.md) | **Complete** |
| Search | [`search/`](search/README.md) | **Complete** |
| Settings | [`setting/`](setting/README.md) | **Complete** |

When a section has `v0/` + `v1/`, **implement and maintain `v1` only**. `v0` is archive. Root `update.md` files are historical redesign briefs (already applied unless a README says otherwise).

## Start here

1. Read `Prompt Frontend/COMMON_CONTEXT.md`.
2. Read `Prompt Frontend/api-intergration/integration-contract.md`.
3. Build [`00-foundation-prompt.md`](00-foundation-prompt.md) (already done for this repo).
4. Follow the flow indexes below — prefer **v1** paths where they exist.

## Auth and startup (v1)

See dedicated [`auth/README.md`](auth/README.md).

| Order | Prompt |
|---|---|
| 1 | [`auth/v1/01-splash-prompt-v1.md`](auth/v1/01-splash-prompt-v1.md) |
| 2 | [`auth/v1/02-select-language-prompt-v1.md`](auth/v1/02-select-language-prompt-v1.md) |
| 3 | [`auth/v1/03-onboarding-prompt-v1.md`](auth/v1/03-onboarding-prompt-v1.md) |
| 4 | [`auth/v1/04-auth-prompt-v1.md`](auth/v1/04-auth-prompt-v1.md) |
| 5 | [`auth/v1/05-register-prompt-v1.md`](auth/v1/05-register-prompt-v1.md) |
| 6 | [`auth/v1/06-auth-google-1-prompt-v1.md`](auth/v1/06-auth-google-1-prompt-v1.md) |
| 7 | [`auth/v1/07-auth-google-2-prompt-v1.md`](auth/v1/07-auth-google-2-prompt-v1.md) |
| 8–10 | [`auth/v1/08`](auth/v1/08-startup-1-prompt-v1.md)–[`10`](auth/v1/10-startup-3-prompt-v1.md) startup |

Entry flow: **Splash → Select Language → Onboarding → Auth → Startup → Home**.

## Home media

See the dedicated [`media/README.md`](media/README.md).

| Prompt | Purpose |
|---|---|
| [`media/01-home-prompt.md`](media/01-home-prompt.md) | Mixed Home feed orchestration (+ shell / reels) |
| [`media/02.comment.md`](media/02.comment.md) | Shared comments |
| [`media/03.create_poster.md`](media/03.create_poster.md) | Create Poster, Video, Job |
| [`media/04.share.md`](media/04.share.md) | Public share/private save |
| [`media/05.post_detail.md`](media/05.post_detail.md) | Full post detail for all post types |
| [`media/card_poster/01.poster_sample.md`](media/card_poster/01.poster_sample.md) | Regular Poster card |
| [`media/card_poster/02.poster_video.md`](media/card_poster/02.poster_video.md) | Video card |
| [`media/card_poster/03.poster_job.md`](media/card_poster/03.poster_job.md) | Job card |

## Other screens

| Prompt | Purpose |
|---|---|
| [`chat/README.md`](chat/README.md) | Private chat — list, thread, profile, Isar, STOMP, FCM |
| [`profile/README.md`](profile/README.md) | Profile — use **`v1/`** prompts |
| [`job_apply/README.md`](job_apply/README.md) | Apply Job wizard + Apply Status |
| [`notification/README.md`](notification/README.md) | Notification center |
| [`search/README.md`](search/README.md) | Global search |
| [`chatbot/README.md`](chatbot/README.md) | Vithey AI chatbot |
| [`finance/README.md`](finance/README.md) | Verification + Finance — use **`v1/`** prompts |
| [`setting/README.md`](setting/README.md) | Settings home, account, privacy, security, notifications prefs, about |

## Maintenance rules

- Keep Home/card/comment/share/create details in `media/` only.
- Keep auth/startup details in `auth/` only.
- Use stable IDs in routes and APIs; never infer type from visible copy/media.
- Update this index and the relevant subfolder README when moving prompts.
- When UI redesign finishes, mark the section **Complete** in the status table and keep `v0/` as archive.
- Use [`_SCREEN-TEMPLATE.md`](_SCREEN-TEMPLATE.md) for new standalone screens.
