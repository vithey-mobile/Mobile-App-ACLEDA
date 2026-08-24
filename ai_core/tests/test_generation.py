import pytest

from fakes import MockDeepSeekClient

from vithey_ai import ExtractedActivity, GeneratedCV
from vithey_ai.errors import AIResponseValidationError, EmptyInputError
from vithey_ai.generation import CVGenerationService


def make_activity(source_id="post_1", title="Recycling Pickup App"):
    return ExtractedActivity(
        activity_type="project",
        title=title,
        role="Developer",
        summary="Built a recycling pickup app at RUPP using Flutter and Firebase.",
        tools=["Flutter", "Firebase"],
        skills=["Mobile Development"],
        outcome="Launched to 100 users",
        date="2024-06-01",
        source_id=source_id,
    )


def test_generate_returns_generated_cv():
    client = MockDeepSeekClient(
        responses=[
            {
                "summary": "Software engineering student with mobile development experience.",
                "sections": [
                    {
                        "heading": "Projects",
                        "items": [
                            {
                                "title": "Recycling Pickup App",
                                "bullet": "Built a recycling pickup app serving campus users.",
                                "evidence": ["post_1"],
                            }
                        ],
                    }
                ],
            }
        ]
    )
    service = CVGenerationService(client)

    cv = service.generate(
        activities=[make_activity()],
        target_role="Software Engineer Intern",
        language="en",
    )

    assert isinstance(cv, GeneratedCV)
    assert "student" in cv.summary
    assert cv.sections[0].heading == "Projects"
    assert cv.sections[0].items[0]["title"] == "Recycling Pickup App"


def test_generate_requires_activities():
    service = CVGenerationService(MockDeepSeekClient())

    with pytest.raises(EmptyInputError):
        service.generate(activities=[])


def test_generate_serializes_activities_in_prompt():
    client = MockDeepSeekClient(responses=[{"summary": "S", "sections": []}])
    service = CVGenerationService(client)
    activity = make_activity(source_id="post_99", title="Smart Campus App")

    service.generate(activities=[activity], target_role="Intern", language="en")

    _, user_prompt = client.calls[0]
    assert "post_99" in user_prompt
    assert "Smart Campus App" in user_prompt
    assert "Intern" in user_prompt
    assert "en" in user_prompt


def test_generate_invalid_json_raises():
    client = MockDeepSeekClient(
        errors=[AIResponseValidationError("DeepSeek returned invalid JSON.")]
    )
    service = CVGenerationService(client)

    with pytest.raises(AIResponseValidationError):
        service.generate(activities=[make_activity()])


def test_generate_missing_required_fields_raises():
    # Missing "sections" -> schema validation failure
    client = MockDeepSeekClient(responses=[{"summary": "S"}])
    service = CVGenerationService(client)

    with pytest.raises(AIResponseValidationError):
        service.generate(activities=[make_activity()])
