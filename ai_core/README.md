# Vithey AI Core (`vithey-ai`)

Self-contained Python package that powers the Vithey CV generation feature.

Other developers do **not** need to know anything about prompts, JSON schemas,
or DeepSeek. They only import `VitheyAI` and call a few methods.

## Quick start

```bash
pip install -e .          # install the package
cp .env.example .env      # then put your DEEPSEEK_API_KEY in .env
```

## Usage

### One-off extraction

```python
from vithey_ai import VitheyAI

ai = VitheyAI()

activity = ai.extract_activity(
    content="We built a recycling pickup app at RUPP using Flutter and Firebase.",
    source_id="post_123",
)
print(activity.title)
print(activity.skills)
```

### Full CV from raw posts

```python
from vithey_ai import VitheyAI, RawPost

ai = VitheyAI()

posts = [
    RawPost(source_id="post_1", content="Built a smart campus app..."),
    RawPost(source_id="post_2", content="Shared a guide on Python data structures..."),
]

cv = ai.build_cv_from_raw_posts(
    posts=posts,
    target_role="Software Engineer Intern",
    language="en",
)

print(cv.summary)
for section in cv.sections:
    print(section.heading)
```

## Public API

| Method | Description |
| --- | --- |
| `extract_activity(content, source_id, source_type="post")` | Reads raw text from one post/activity, returns `ExtractedActivity`. |
| `generate_cv(activities, target_role="", language="en")` | Takes extracted activities, returns `GeneratedCV`. |
| `build_cv_from_raw_posts(posts, target_role="", language="en")` | Convenience: posts → extract each → generate CV. |

Public models: `ExtractedActivity`, `GeneratedCV`, `RawPost`.

Errors: all custom exceptions inherit from `VitheyAIError`
(`AIClientError`, `AIResponseValidationError`, `EmptyInputError`).

## CLI

Single entry point for developers who don't want to import the package. No
imports needed — the AI internals stay hidden.

```bash
# extract one activity from raw post text
python main.py extract --content "We built a recycling pickup app at RUPP" --source-id post_123

# generate a CV from already-extracted activities (JSON array file)
python main.py generate --activities activities.json --target-role "Software Engineer Intern"

# generate a CV straight from raw posts (JSON array file)
python main.py generate --posts posts.json --language en
```

Output is clean JSON on stdout (easy to pipe), errors go to stderr with a
non-zero exit code. The API key is read automatically from `.env`; pass
`--api-key` to override for a single call.

## Development

```bash
pip install -e ".[dev]"
pytest
```

## Layout

```
ai_core/
├── main.py            # CLI entry point (python main.py ...)
├── vithey_ai/          # only service.py and __init__.py are public
│   ├── config.py        # API key, model, temperature, timeouts
│   ├── schemas.py       # Pydantic data models
│   ├── errors.py        # custom exceptions
│   ├── deepseek_client.py
│   ├── prompts.py       # prompt templates (internal)
│   ├── extraction.py
│   ├── generation.py
│   ├── cache.py         # optional in-memory cache
│   └── service.py       # public facade: VitheyAI
├── tests/
├── pyproject.toml
└── .env.example
```
