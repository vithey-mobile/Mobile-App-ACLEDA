# Search — Facebook-Style Global Search Prompt Index

Complete specification for a **Facebook / Messenger-style global search** experience in Vithey App.

## Product goal

Deliver a production-quality search experience comparable to **Facebook / Meta**:

- Full-screen search with **back arrow + inline search field** (autofocus)
- **Recent** section when query is empty — avatar, name, last-seen subtitle
- **Grouped live results** while typing — People, Posts, Jobs, Videos
- Debounced server search with skeleton + empty states
- Tap result → Profile, Post Detail, Job, or start Chat
- **Recent history** persisted locally (users + queries)
- **Backend-ready** — mock today, `user-profile-service` + `content-service` tomorrow

## Visual reference

| Screen | Asset |
|--------|-------|
| Search main (recent / empty query) | `Prompt Frontend/screen image/search/search main.png` |

## Technology stack (mandatory)

| Layer | Package / Tech | Role |
|-------|----------------|------|
| UI | `shadcn_flutter ^0.0.52` | Clear button, result action sheets |
| UI | Material 3 + semantic colors | Search bar, list tiles |
| REST | **Dio** | `GET /users/search`, `GET /posts?search=` |
| Local | **shared_preferences** or **Isar** | Recent searches + recent users |
| State | **GetX** | Controller, debounce, routing |

### Architecture

```text
Home AppBar [🔍]
    │
    ▼
SearchScreen (autofocus)
    │
    ├── query empty → Recent (local + suggested contacts)
    │
    └── query ≥ 2 chars → debounce 350ms
            ├── SearchRepository
            │     ├── UserSearchService  → GET /users/search
            │     └── PostSearchService  → GET /posts?search=&type=
            └── Grouped UI sections
                    ├── People
                    ├── Posts
                    ├── Jobs
                    └── Videos
```

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.search_main.md`](01.search_main.md) | Search shell, app bar, recent list, empty query UX |
| 2 | [`02.search_results.md`](02.search_results.md) | Grouped results, row design, navigation |
| 3 | [`03.search_recent_local.md`](03.search_recent_local.md) | Local recent history, clear, dedupe |
| 4 | [`04.search_api_backend.md`](04.search_api_backend.md) | REST contract, mock mode, error mapping |

## Entry points

| Source | Behavior |
|--------|----------|
| Home app bar `Icons.search` | `AppRoutes.search` full screen |
| Chat list search icon | Same route *(replace bottom sheet)* |
| **Notification app bar `Icons.search`** | Same route — `Get.toNamed(AppRoutes.search)` |
| Deep link `vithey://search?q=` | Pre-fill query + run search |

## Feature matrix

| Feature | UI | Local | REST |
|---------|----|-------|------|
| Autofocus search field | `01` | — | — |
| Recent users | `01` | ✅ | — |
| Recent queries | `01` | ✅ | — |
| Clear recent | `01`, `03` | ✅ | — |
| Search people | `02` | upsert recent | `GET /users/search` |
| Search posts | `02` | — | `GET /posts?search=` |
| Search jobs | `02` | — | `GET /posts?search=&type=JOB` |
| Search videos | `02` | — | `GET /posts?search=&type=VIDEO` |
| Debounce 350ms | `02` | — | — |
| Min query length 2 | `02` | — | — |
| See all per section | `02` | — | paginate |
| Start chat from people | `02` | — | chat-service |

## Module architecture (target)

```text
lib/modules/search/
  search_screen.dart
  search_controller.dart
  search_binding.dart
  widgets/
    search_app_bar.dart
    search_text_field.dart
    search_recent_section.dart
    search_recent_tile.dart
    search_results_view.dart
    search_section_header.dart
    search_person_tile.dart
    search_post_tile.dart
    search_job_tile.dart
    search_video_tile.dart
    search_empty_state.dart
    search_loading_skeleton.dart

lib/data/
  models/search_result_models.dart
  repositories/search_repository.dart
  services/
    user_search_service.dart
    post_search_service.dart
  local/
    search_recent_store.dart
```

## Current codebase baseline

Wire these entry points — do not duplicate search UIs:

- `lib/modules/home/widgets/home_app_bar.dart` — search icon currently no-op
- `lib/modules/chat/chat_list_screen.dart` — local filter bottom sheet → migrate to global search for people

## Acceptance checklist

- [ ] Matches `search main.png` — back, rounded field, Recent header, avatar rows
- [ ] Keyboard opens automatically on screen entry
- [ ] Recent persists across app restarts
- [ ] Typing shows grouped Facebook-style sections
- [ ] Debounced API; no request per keystroke
- [ ] Tap person → Profile; tap post → Post Detail
- [ ] Clear (×) in search field resets to Recent
- [ ] Empty query shows Recent only — no API call
- [ ] `flutter analyze` zero errors

## Output

Implement global search by following prompts **01 → 04** in order. One `SearchRepository` coordinates users + posts + local recents.

## Dependencies

- `Prompt Frontend/COMMON_CONTEXT.md`
- `Prompt Frontend/api-intergration/integration-contract.md`
- `Screen prompt/media/01-home-prompt.md` (Home search entry)
- `Screen prompt/chat/01.list_chat.md` (people picker overlap)
- `Screen prompt/profile/v0/01.profile_home.md` (profile destination)
- `Prompt Backend/services/user-profile-service/API_ENDPOINTS.md`
