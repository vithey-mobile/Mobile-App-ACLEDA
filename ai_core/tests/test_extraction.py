import pytest

from fakes import MockDeepSeekClient

from vithey_ai import ExtractedActivity
from vithey_ai.errors import AIResponseValidationError
from vithey_ai.extraction import ExtractionService


def make_client(activity_data):
    return MockDeepSeekClient(responses=[activity_data])


def test_extract_returns_activity():
    client = make_client(
        {
            "activity_type": "project",
            "title": "Recycling Pickup App",
            "role": "Developer",
            "summary": "Built a recycling pickup app at RUPP using Flutter and Firebase.",
            "tools": ["Flutter", "Firebase"],
            "skills": ["Mobile Development", "Firebase"],
            "outcome": "Launched to 100 users",
            "date": "2024-06-01",
            "source_id": "wrong_id",  # must be forced by the service
        }
    )
    service = ExtractionService(client)

    activity = service.extract(
        content="We built a recycling pickup app at RUPP.",
        source_id="post_123",
    )

    assert isinstance(activity, ExtractedActivity)
    assert activity.title == "Recycling Pickup App"
    assert activity.source_id == "post_123"  # forced
    assert activity.tools == ["Flutter", "Firebase"]
    assert activity.skills == ["Mobile Development", "Firebase"]


def test_extract_sends_content_and_source_id():
    client = make_client(
        {
            "activity_type": "project",
            "title": "T",
            "summary": "S",
            "source_id": "post_1",
        }
    )
    service = ExtractionService(client)

    service.extract(content="Hello world", source_id="post_1")

    system_prompt, user_prompt = client.calls[0]
    assert "Hello world" in user_prompt
    assert "post_1" in user_prompt
    assert "extracts structured information" in system_prompt


def test_extract_invalid_json_raises():
    client = MockDeepSeekClient(
        errors=[AIResponseValidationError("DeepSeek returned invalid JSON.")]
    )
    service = ExtractionService(client)

    with pytest.raises(AIResponseValidationError):
        service.extract(content="x", source_id="post_1")


def test_extract_missing_required_fields_raises():
    # Missing title, summary, source_id -> schema validation failure
    client = make_client({"activity_type": "project"})
    service = ExtractionService(client)

    with pytest.raises(AIResponseValidationError):
        service.extract(content="x", source_id="post_1")
