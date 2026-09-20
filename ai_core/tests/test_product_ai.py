"""Unit tests for rule-based product AI helpers."""

from vithey_ai.product_ai_service import (
    extract_skills_from_text,
    score_skill,
    _label_for_score,
)


def test_extract_skills_from_requirement_list():
    skills = extract_skills_from_text(
        "Flutter, Dart, REST API, Git",
        "Looking for mobile interns",
    )
    assert "Flutter" in skills
    assert "Dart" in skills


def test_score_skill_is_deterministic():
    assert score_skill("Flutter", related_posts=2) == score_skill(
        "Flutter", related_posts=2
    )
    assert 0 <= score_skill("Flutter", related_posts=2) <= 100


def test_label_for_score():
    assert _label_for_score(90) == "Excellent"
    assert _label_for_score(70) == "Good"
    assert _label_for_score(55) == "Fair"
    assert _label_for_score(10) == "Low"
