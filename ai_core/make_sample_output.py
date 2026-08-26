"""Regenerates SAMPLE_OUTPUT.md from the real pipeline.

Uses the same scripted LLM as demo.py but with a *clean* generation-stage
payload, i.e. what a real DeepSeek call would plausibly return -- so the
sample document shows realistic content while every structural guarantee
(normalization, dedupe, evidence filtering, scoring) still comes from the
actual production code.
"""

from datetime import datetime, timezone

from demo import POSTS, PROFILE, ScriptedLLM
from vithey_ai import VitheyAI


class CleanLLM(ScriptedLLM):
    """Same extraction behavior; realistic (non-sabotaged) CV JSON."""

    def ask_json(self, system_prompt, user_prompt):
        if "extracts structured information" not in system_prompt:
            self.generation_called = True
            return {
                "contact": {},
                "summary": (
                    "Computer Science senior at RUPP with hands-on experience "
                    "shipping web applications, a national hackathon award, and "
                    "internship exposure to enterprise Java development."
                ),
                "experience": [
                    {
                        "title": "Software Engineering Intern",
                        "organization": "ACLEDA Bank",
                        "period": "2025-09 ~ present",
                        "bullets": [
                            "Shipped 3 internal dashboards used by 2 departments",
                            "Built REST APIs with Java Spring Boot",
                        ],
                        "evidence": ["post_6"],
                    }
                ],
                "education": [],
                "projects": [
                    {
                        "name": "Recycling Pickup App",
                        "role": "Team Lead",
                        "period": "2025-03 ~ 2025-05",
                        "summary": "Campus recycling pickup scheduling web app.",
                        "tech_stack": ["React", "Node.js", "PostgreSQL", "QR"],
                        "bullets": [
                            "Led a 4-person team to build and launch the app",
                            "Grew adoption to 200 students with a QR scan flow",
                            "Won best project in the course",
                        ],
                        "link": None,
                        "evidence": ["post_1", "post_2"],
                    }
                ],
                "skills": [
                    {
                        "category": "Technical",
                        "skills": [
                            "Java",
                            "Spring Boot",
                            "Node.js",
                            "React",
                            "PostgreSQL",
                            "SQL",
                            "Python",
                        ],
                    },
                    {
                        "category": "Soft skills",
                        "skills": ["Team Leadership", "Public Speaking", "Mentoring"],
                    },
                ],
                "certifications": [],
                "languages": [
                    {"name": "Khmer", "proficiency": "Native"},
                    {"name": "English", "proficiency": "Professional"},
                ],
                "achievements": [
                    {
                        "title": "2nd Place - Smart Cambodia Hackathon 2025",
                        "description": "Waste-tracking dashboard, $500 prize of 40 teams",
                        "date": "2025-07-20",
                        "evidence": ["post_4"],
                    }
                ],
                "volunteer": [
                    {
                        "title": "STEM Weekend Tutor",
                        "organization": "Teach Cambodia NGO",
                        "description": "Taught Python basics to 25 high-school students",
                        "date": "2025-08-16",
                        "evidence": ["post_5"],
                    }
                ],
            }
        return super().ask_json(system_prompt, user_prompt)


def render_human_cv(cv) -> str:
    lines = [f"# {cv.contact.full_name}", ""]
    if cv.contact.headline:
        lines.append(f"*{cv.contact.headline}*")
    contact_bits = [
        v
        for v in (
            cv.contact.email,
            cv.contact.phone,
            cv.contact.location,
            cv.contact.github,
        )
        if v
    ]
    lines.append(" | ".join(contact_bits))
    lines += ["", f"**Summary**", "", cv.summary, ""]

    def bullets(items):
        return "\n".join(f"- {b}" for b in items)

    if cv.experience:
        lines += ["## Work Experience", ""]
        for e in cv.experience:
            org = f" — {e.organization}" if e.organization else ""
            period = f" ({e.period})" if e.period else ""
            lines.append(f"**{e.title}**{org}{period}")
            lines.append(bullets(e.bullets))
            lines.append(f"  <sub>source: {', '.join(e.evidence)}</sub>\n")

    if cv.education:
        lines += ["## Education", ""]
        for ed in cv.education:
            inst = f", {ed.institution}" if ed.institution else ""
            period = f" ({ed.period})" if ed.period else ""
            detail = f" — {ed.details}" if ed.details else ""
            lines.append(f"**{ed.degree}**{inst}{period}{detail}\n")

    if cv.projects:
        lines += ["## Projects", ""]
        for p in cv.projects:
            stack = f" `{('`, `'.join(p.tech_stack))}`" if p.tech_stack else ""
            lines.append(f"**{p.name}**{stack}")
            if p.summary:
                lines.append(p.summary)
            lines.append(bullets(p.bullets))
            lines.append(f"  <sub>source: {', '.join(p.evidence)}</sub>\n")

    if cv.skills:
        lines += ["## Skills", ""]
        for g in cv.skills:
            lines.append(f"- **{g.category}:** {', '.join(g.skills)}")
        lines.append("")

    if cv.certifications:
        lines += ["## Certifications", ""]
        for c in cv.certifications:
            lines.append(f"- **{c.name}**"
                         f"{f' — {c.issuer}' if c.issuer else ''}"
                         f"{f' ({c.date})' if c.date else ''}\n")

    if cv.languages:
        lines += ["## Languages", ""]
        for l in cv.languages:
            prof = f" ({l.proficiency})" if l.proficiency else ""
            lines.append(f"- {l.name}{prof}")
        lines.append("")

    if cv.achievements:
        lines += ["## Achievements", ""]
        for a in cv.achievements:
            date = f" ({a.date})" if a.date else ""
            desc = f" — {a.description}" if a.description else ""
            lines.append(f"- **{a.title}**{date}{desc}"
                         f" <sub>source: {', '.join(a.evidence)}</sub>")
        lines.append("")

    if cv.volunteer:
        lines += ["## Volunteer Work", ""]
        for v in cv.volunteer:
            org = f" — {v.organization}" if v.organization else ""
            lines.append(f"- **{v.title}**{org}: {v.description}"
                         f" <sub>source: {', '.join(v.evidence)}</sub>")
        lines.append("")

    return "\n".join(lines)


def main():
    ai = VitheyAI(api_key="demo", client=CleanLLM())
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
    report = ai.quality_report(cv)
    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    md = f"""<!-- Auto-generated by make_sample_output.py -- do not edit by hand -->
<!-- Last generated: {generated_at} -->

# Sample Output — Vithey AI Core

What you get from ONE call:

```python
cv = ai.build_cv_from_raw_posts(posts=..., profile=..., target_role=..., language=\"en\")
```

Input: 6 messy social posts (one duplicated, one pure noise that failed
extraction) + a user profile + a job description.
Output below. Every claim cites the `post_N` it came from.

---

## The API response: `StandardCV` JSON

```json
{cv.model_dump_json(indent=2)}
```

---

## Deterministic quality report

```json
{{"score": {report.score}, "grade": "{report.grade}"}}
```

Issues found: {"none — ready to submit" if not report.issues else ""}
{chr(10).join(f'- `[{{i.code}}]` {{i.message}}' for i in report.issues)}

---

## Rendered as a CV

{render_human_cv(cv)}

---

*Note: the DeepSeek network hop is simulated in this offline sample; all
structure guarantees (standard sections, dedupe, profile merge, evidence
filtering, scoring) come from the real production code.*
"""

    with open("SAMPLE_OUTPUT.md", "w", encoding="utf-8") as f:
        f.write(md)
    print(f"SAMPLE_OUTPUT.md written ({len(md)} chars), quality={report.score}/100")


if __name__ == "__main__":
    main()
