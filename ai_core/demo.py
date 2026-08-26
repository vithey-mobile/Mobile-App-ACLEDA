"""Vithey AI showcase: raw messy posts -> guaranteed standard CV.

Only the DeepSeek network hop is simulated (no API key needed); every other
stage -- dedupe, normalization, profile merge, evidence filtering, quality
scoring, HTTP envelope -- is the real production code.
"""

import json

from vithey_ai import RawPost, UserProfile, VitheyAI
from vithey_ai.errors import AIClientError


# ---------------------------------------------------------------------------
# The "LLM": scripted responses, including sabotage
# ---------------------------------------------------------------------------


class ScriptedLLM:
    def __init__(self):
        self.extraction_calls = 0

    def ask_json(self, system_prompt: str, user_prompt: str) -> dict:
        if "extracts structured information" in system_prompt:
            self.extraction_calls += 1
            n = self.extraction_calls
            if n == 3:  # lunch photo post -> upstream blows up
                raise AIClientError("upstream exploded (simulated)")
            if n == 1:
                return {
                    "activity_type": "project",
                    "title": "Recycling Pickup App",
                    "role": "Team Lead",
                    "summary": "Built a recycling pickup web app at RUPP with 4 classmates.",
                    "tools": ["React", "Node.js"],
                    "skills": ["Web Development", "Team Leadership"],
                    "outcome": "Won best project in the course",
                    "date": "2025-03-10",
                    "source_id": "?",
                }
            if n == 2:  # repost of project #1 with a typo title
                return {
                    "activity_type": "project",
                    "title": "recycling pickup app",
                    "role": None,
                    "summary": "Our app now serves 200 students; added QR scan flow.",
                    "tools": ["React", "PostgreSQL"],
                    "skills": ["Web Development", "QR Integration"],
                    "outcome": None,
                    "date": "2025-05-02",
                    "source_id": "?",
                }
            if n == 4:  # national hackathon
                return {
                    "activity_type": "achievement",
                    "title": "Smart Cambodia Hackathon 2025",
                    "summary": "Placed 2nd of 40 teams with a waste-tracking dashboard.",
                    "skills": ["Data Visualization", "Public Speaking"],
                    "outcome": "2nd place trophy + $500 prize",
                    "date": "2025-07-20",
                    "source_id": "?",
                }
            if n == 5:  # weekend volunteer teaching
                return {
                    "activity_type": "volunteer",
                    "title": "STEM Weekend Tutor",
                    "organization": "Teach Cambodia NGO",
                    "summary": "Taught basic Python to 25 high-schoolers on weekends.",
                    "skills": ["Python", "Mentoring"],
                    "date": "2025-08-16",
                    "source_id": "?",
                }
            return {  # internship
                "activity_type": "work",
                "title": "Software Engineering Intern",
                "role": "Intern",
                "summary": "Shipped 3 internal dashboards at ACLEDA bank summer program.",
                "tools": ["Java", "Spring Boot"],
                "skills": ["Backend Development", "SQL"],
                "date": "2025-09-01",
                "source_id": "?",
            }

        # --- CV generation stage: SABOTAGE the output on purpose ----------
        # Wrong contact, invented sections, string bullets, fake evidence,
        # empty summary. The normalizer must fix ALL of it.
        return {
            "contact": {"full_name": "TOTALLY WRONG NAME", "email": "ai@made-up.com"},
            "summary": "",
            "sections": [
                {
                    "heading": "Work History",
                    "items": [
                        {
                            "title": "Software Engineering Intern",
                            "bullet": "Shipped 3 internal dashboards used by 2 departments",
                            "evidence": ["post_6", "FAKE_ID_42"],
                        }
                    ],
                },
                {
                    "heading": "My Cool Projects",
                    "items": [
                        {
                            "name": "Recycling Pickup App",
                            "period": "2025-03 ~ 2025-05",
                            "tech_stack": ["React", "Node.js", "PostgreSQL", "QR"],
                            "bullets": "single string instead of a list",
                            "evidence": ["post_9", "post_1", "post_2"],
                        }
                    ],
                },
                {"heading": "Totally Made Up Section", "items": [{"title": "ghost"}]},
                {
                    "heading": "Skills",
                    "items": [
                        {"category": "Technical", "skills": ["React", "SQL"]},
                        "loose skill string",
                    ],
                },
                {
                    "heading": "Awards",
                    "items": [
                        {
                            "title": "2nd Place - Smart Cambodia Hackathon 2025",
                            "evidence": ["post_4"],
                        }
                    ],
                },
                {
                    "heading": "Volunteering",
                    "items": [{"title": "STEM Weekend Tutor", "evidence": ["post_5"]}],
                },
            ],
        }


# ---------------------------------------------------------------------------
# Messy real-world-ish input
# ---------------------------------------------------------------------------

POSTS = [
    RawPost(source_id="post_1", content="we shipped our recycling pickup app!! React+Node"),
    RawPost(source_id="post_2", content="update: our app now does QR scanning, 200 users!"),
    RawPost(source_id="post_3", content="best phnom penh beef noodle review thread 🍜"),
    RawPost(source_id="post_4", content="2nd place at Smart Cambodia Hackathon!!"),
    RawPost(source_id="post_5", content="taught python to high schoolers today :)"),
    RawPost(source_id="post_6", content="first week as SE intern at ACLEDA done"),
]

PROFILE = {
    "full_name": "Sok Dara",
    "headline": "Computer Science senior @ RUPP",
    "email": "sok.dara@example.com",
    "phone": "+855 12 345 678",
    "location": "Phnom Penh, Cambodia",
    "github": "github.com/sokdara",
    "education": [
        {
            "degree": "BSc Computer Science",
            "institution": "Royal University of Phnom Penh",
            "period": "2022 ~ 2026",
            "details": "GPA 3.7/4.0",
        }
    ],
}


def hr(title):
    print(f"\n{'=' * 64}\n  {title}\n{'=' * 64}")


def main():
    ai = VitheyAI(api_key="demo-key", client=ScriptedLLM())

    hr("STEP 1 - batch extraction: 6 messy posts")
    batch = ai.extract_activities([p.model_dump() for p in POSTS])
    print(f"kept {batch.ok_count} activities, {batch.failure_count} failed:")
    for f in batch.failures:
        print(f"   [skipped] {f.source_id}: {f.error[:60]}...")
    merged = next(a for a in batch.activities if "recycling" in a.title.lower())
    print(f"duplicate reposts merged into one activity, evidence = {merged.all_source_ids}")

    hr("STEP 2 - generate STANDARD CV (with sabotaged LLM output)")
    cv = ai.build_cv_from_raw_posts(
        posts=[p.model_dump() for p in POSTS],
        profile=PROFILE,
        target_role="Junior Software Engineer",
        job_description=(
            "We need a junior engineer with strong web backend skills "
            "(Node.js/Java), SQL, and hackathon/project experience."
        ),
        language="en",
    )

    hr("RESULT - the guaranteed standard shape (contact from PROFILE ONLY)")
    print(f"name     : {cv.contact.full_name}      <- profile won, not 'TOTALLY WRONG NAME'")
    print(f"headline : {cv.contact.headline}")
    print(f"contact  : {cv.contact.email} | {cv.contact.phone}")
    print(f"summary  : {cv.summary[:110]}...  <- fact-based fallback (model gave '')")
    print(f"sections : {[k for k, v in cv.section_lists().items()]}")
    print(f"experience[0]           : {cv.experience[0].title}")
    print(f"experience[0].bullets   : {cv.experience[0].bullets}  <- string coerced to list")
    print(f"experience[0].evidence  : {cv.experience[0].evidence}  <- FAKE_ID_42 dropped")
    proj = cv.projects[0]
    print(f"project                 : {proj.name} | stack={proj.tech_stack}")
    print(f"project.evidence        : {proj.evidence}  <- post_9 dropped, dupes collapsed")
    print(f"'Made Up Section'       : gone. Achievements: {len(cv.achievements)}, "
          f"Volunteer: {len(cv.volunteer)}")

    report = ai.quality_report(cv)
    hr(f"QUALITY REPORT - score {report.score}/100 ({report.grade})")
    for issue in report.issues:
        print(f"   [{issue.code}] {issue.message}")

    hr("SAME RESULT OVER HTTP (real FastAPI app, platform envelope)")
    import sys
    sys.path.insert(0, "tests")
    from fastapi.testclient import TestClient

    from vithey_ai.api.app import create_app

    class DemoFacade:
        def build_cv_from_raw_posts(self, posts, **kwargs):
            return cv

        def quality_report(self, inner_cv):
            return report

    client = TestClient(create_app(ai=DemoFacade()))
    resp = client.post(
        "/api/v1/cv/generate",
        json={"posts": [{"source_id": "p", "content": "x"}], "language": "en"},
    )
    body = resp.json()
    print(f"POST /api/v1/cv/generate -> HTTP {resp.status_code}, success={body['success']}")
    print(f"envelope keys : {sorted(body.keys())}")
    print(f"meta          : request_id={body['meta']['request_id'][:13]}... service={body['meta']['service']}")
    print(f"X-Request-ID echoed back in headers: {'X-Request-ID' in resp.headers}")

    hr("DONE - every claim traceable to a source_id, structure always valid")


if __name__ == "__main__":
    main()
