import json

import pytest

import main
from vithey_ai.config import Config
from vithey_ai.schemas import ExtractedActivity, GeneratedCV


class FakeVitheyAI:
    """Fake facade so CLI tests never hit the network."""

    def __init__(self, api_key=None):
        self.api_key = api_key

    def extract_activity(self, content, source_id, source_type="post"):
        return ExtractedActivity(
            activity_type="project",
            title="Recycling Pickup App",
            summary=content,
            source_id=source_id,
        )

    def generate_cv(self, activities, target_role="", language="en"):
        return GeneratedCV(summary="Generated summary", sections=[])

    def build_cv_from_raw_posts(self, posts, target_role="", language="en"):
        return GeneratedCV(summary="Generated summary", sections=[])


@pytest.fixture(autouse=True)
def use_fake_facade(monkeypatch):
    monkeypatch.setattr(main, "VitheyAI", FakeVitheyAI)


def test_extract_outputs_json(capsys):
    rc = main.main(["extract", "--content", "hello world", "--source-id", "post_1"])

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["source_id"] == "post_1"
    assert data["title"] == "Recycling Pickup App"


def test_generate_from_activities(tmp_path, capsys):
    activities_file = tmp_path / "activities.json"
    activities_file.write_text(
        json.dumps(
            [
                {
                    "activity_type": "project",
                    "title": "Recycling Pickup App",
                    "summary": "Built a recycling pickup app.",
                    "source_id": "post_1",
                }
            ]
        ),
        encoding="utf-8",
    )

    rc = main.main(
        [
            "generate",
            "--activities",
            str(activities_file),
            "--target-role",
            "Software Engineer Intern",
        ]
    )

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["summary"] == "Generated summary"


def test_generate_from_raw_posts(tmp_path, capsys):
    posts_file = tmp_path / "posts.json"
    posts_file.write_text(
        json.dumps([{"source_id": "post_1", "content": "Built a smart campus app."}]),
        encoding="utf-8",
    )

    rc = main.main(["generate", "--posts", str(posts_file), "--language", "en"])

    assert rc == 0
    data = json.loads(capsys.readouterr().out)
    assert data["summary"] == "Generated summary"


def test_invalid_json_file_is_reported(capsys, tmp_path):
    bad_file = tmp_path / "bad.json"
    bad_file.write_text("{not valid json", encoding="utf-8")

    rc = main.main(["generate", "--activities", str(bad_file)])

    assert rc == 1
    assert "invalid JSON" in capsys.readouterr().err


def test_missing_activities_file_is_reported(capsys, tmp_path):
    rc = main.main(["generate", "--activities", str(tmp_path / "nope.json")])

    assert rc == 1
    assert "file not found" in capsys.readouterr().err


def test_missing_api_key_returns_error(capsys, monkeypatch):
    # Use the REAL facade here (override the autouse fake) and force it to
    # see no API key -> helpful error, not a crash.
    from vithey_ai import VitheyAI as RealVitheyAI

    monkeypatch.setattr(Config, "DEEPSEEK_API_KEY", "")
    monkeypatch.setattr(main, "VitheyAI", RealVitheyAI)

    rc = main.main(["extract", "--content", "x", "--source-id", "post_1"])

    assert rc == 1
    assert "DEEPSEEK_API_KEY" in capsys.readouterr().err
