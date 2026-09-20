"""Rule-based product AI: job match, skill score, feed recommendations.

No LLM calls — deterministic overlap / activity heuristics for the demo.
"""

from __future__ import annotations

import hashlib
import re
import uuid
from typing import Any

import httpx

from .config import Config
from .logging_conf import get_logger

logger = get_logger(__name__)

_TOKEN_SPLIT = re.compile(r"[,;/|\n•·\-–—]+|\band\b|\bor\b", re.IGNORECASE)
_WORD = re.compile(r"[A-Za-z][A-Za-z0-9+#.]*")

# Common campus / tech skill tokens used to extract requirements from free text.
_KNOWN_SKILLS = {
    "flutter",
    "dart",
    "react",
    "javascript",
    "typescript",
    "html",
    "css",
    "java",
    "spring",
    "python",
    "sql",
    "postgresql",
    "mysql",
    "excel",
    "git",
    "docker",
    "figma",
    "canva",
    "marketing",
    "communication",
    "english",
    "accounting",
    "finance",
    "rest",
    "api",
    "nodejs",
    "kotlin",
    "swift",
}


def _headers(authorization: str | None, user_id: uuid.UUID) -> dict[str, str]:
    headers = {"X-User-Id": str(user_id), "Accept": "application/json"}
    if authorization:
        headers["Authorization"] = authorization
    return headers


def _label_for_score(score: int) -> str:
    if score >= 80:
        return "Excellent"
    if score >= 65:
        return "Good"
    if score >= 50:
        return "Fair"
    return "Low"


def _norm(skill: str) -> str:
    return re.sub(r"\s+", " ", skill.strip().lower())


def extract_skills_from_text(*parts: str | None) -> list[str]:
    """Pull skill-like tokens from job requirement / description free text."""
    found: list[str] = []
    seen: set[str] = set()
    for part in parts:
        if not part:
            continue
        # Prefer comma/bullet lists
        chunks = [c.strip() for c in _TOKEN_SPLIT.split(part) if c and c.strip()]
        if len(chunks) <= 1:
            chunks = _WORD.findall(part)
        for chunk in chunks:
            cleaned = chunk.strip(" .()[]")
            if len(cleaned) < 2:
                continue
            key = _norm(cleaned)
            # Keep multi-word list items, or known single tokens
            words = key.split()
            if len(words) > 1 or key in _KNOWN_SKILLS or cleaned[0].isupper():
                if key not in seen:
                    seen.add(key)
                    found.append(cleaned)
            elif key in _KNOWN_SKILLS and key not in seen:
                seen.add(key)
                found.append(cleaned)
    return found[:12]


def score_skill(name: str, related_posts: int = 0, attachments: int = 0) -> int:
    trimmed = name.strip()
    if not trimmed:
        return 0
    seed = int(hashlib.md5(trimmed.lower().encode()).hexdigest()[:4], 16) % 18
    base = 42 + related_posts * 8 + seed + attachments * 10
    return max(0, min(100, base))


class ProductAiService:
    def __init__(self, config: Config):
        self._config = config

    def match_job(
        self,
        caller_id: uuid.UUID,
        job_post_id: str,
        authorization: str | None,
        applicant_user_id: str | None = None,
        cv_file_id: str | None = None,
    ) -> dict[str, Any]:
        applicant_id = (
            uuid.UUID(applicant_user_id) if applicant_user_id else caller_id
        )
        post = self._fetch_post(job_post_id, authorization, caller_id)
        if not post:
            raise LookupError("Job post not found")

        job_meta = post.get("job_meta") or {}
        required = extract_skills_from_text(
            job_meta.get("requirement"),
            job_meta.get("description"),
            job_meta.get("title"),
            post.get("content") or post.get("caption"),
        )
        if not required:
            required = ["Communication", "English"]

        profile = self._fetch_profile(applicant_id, authorization, caller_id)
        applicant_skills = [
            str(s.get("name") if isinstance(s, dict) else s).strip()
            for s in (profile.get("skills") or [])
            if (s.get("name") if isinstance(s, dict) else s)
        ]
        applicant_norm = {_norm(s) for s in applicant_skills if s}

        if not applicant_norm:
            return {
                "job_post_id": job_post_id,
                "applicant_user_id": str(applicant_id),
                "cv_file_id": cv_file_id,
                "score": 12,
                "label": _label_for_score(12),
                "matched_skills": [],
                "gap_skills": required,
                "reasons": [
                    "Your profile has no skills listed yet, so AI cannot compare them with this job.",
                    "Add at least 3 relevant skills to unlock a real match score.",
                    "The poster will still see your CV and application note.",
                ],
                "incomplete_profile": True,
                "disclaimer": "AI assist only — not a hiring decision.",
            }

        matched = [s for s in required if _norm(s) in applicant_norm]
        gaps = [s for s in required if s not in matched]
        score = int(round((len(matched) / max(len(required), 1)) * 75)) + 20
        if len(matched) == len(required):
            score = 96
        score = max(15, min(96, score))

        reasons: list[str] = []
        if matched:
            reasons.append(
                f"Your skills in {' and '.join(matched[:2])} match what this job is asking for."
            )
        else:
            reasons.append(
                "None of your listed skills appear in this job’s requirements yet."
            )
        if gaps:
            reasons.append(
                f"Learning {' or '.join(gaps[:2])} would raise your match noticeably."
            )
        else:
            reasons.append("You cover every skill this job asks for — great job!")
        reasons.append("Your CV and application note are still reviewed by a human.")

        return {
            "job_post_id": job_post_id,
            "applicant_user_id": str(applicant_id),
            "cv_file_id": cv_file_id,
            "score": score,
            "label": _label_for_score(score),
            "matched_skills": matched,
            "gap_skills": gaps,
            "reasons": reasons,
            "incomplete_profile": False,
            "disclaimer": "AI assist only — not a hiring decision.",
        }

    def skill_scores(
        self,
        user_id: uuid.UUID,
        authorization: str | None,
    ) -> dict[str, Any]:
        profile = self._fetch_profile(user_id, authorization, user_id)
        posts = self._fetch_user_posts(user_id, authorization)
        post_blob = " ".join(
            str(p.get("content") or p.get("caption") or "").lower() for p in posts
        )

        skills_raw = profile.get("skills") or []
        top: list[dict[str, Any]] = []
        for skill in skills_raw:
            if isinstance(skill, dict):
                name = str(skill.get("name") or "").strip()
                attachments = skill.get("attachment_paths") or skill.get("attachments") or []
                att_count = len(attachments) if isinstance(attachments, list) else 0
            else:
                name = str(skill).strip()
                att_count = 0
            if not name:
                continue
            related = post_blob.count(name.lower())
            ai = score_skill(name, related_posts=related, attachments=att_count)
            signals = [
                f"{related} related post{'s' if related != 1 else ''}",
            ]
            if att_count:
                signals.append(
                    f"{att_count} linked attachment{'s' if att_count != 1 else ''}"
                )
            if related >= 2:
                signals.append("Chat practice detected")
            top.append(
                {
                    "skill_name": name,
                    "self_percent": ai,
                    "ai_score": ai,
                    "signals": signals,
                }
            )

        top.sort(key=lambda s: s["ai_score"], reverse=True)
        overall = (
            int(round(sum(s["ai_score"] for s in top) / len(top))) if top else 0
        )
        weakest = sorted(top, key=lambda s: s["ai_score"])[:3]
        suggestions = [
            f"Practice {s['skill_name']} — AI score {s['ai_score']}%" for s in weakest
        ]
        return {
            "overall_score": overall,
            "top_skills": top,
            "suggestions": suggestions,
        }

    def feed_recommendations(
        self,
        user_id: uuid.UUID,
        authorization: str | None,
        limit: int = 20,
    ) -> list[dict[str, Any]]:
        limit = max(1, min(limit, 50))
        profile = self._fetch_profile(user_id, authorization, user_id)
        skills = {
            _norm(str(s.get("name") if isinstance(s, dict) else s))
            for s in (profile.get("skills") or [])
            if (s.get("name") if isinstance(s, dict) else s)
        }
        following = self._fetch_following_ids(user_id, authorization)
        posts = self._fetch_feed(authorization, user_id, limit=40)

        ranked: list[dict[str, Any]] = []
        for post in posts:
            post_id = str(post.get("id") or post.get("post_id") or "")
            if not post_id:
                continue
            ptype = str(post.get("type") or "").upper()
            author = post.get("author") or {}
            author_id = str(author.get("user_id") or author.get("id") or "")
            job_meta = post.get("job_meta") or {}
            text_skills = extract_skills_from_text(
                job_meta.get("requirement"),
                job_meta.get("title"),
                post.get("content") or post.get("caption"),
            )
            overlap = [s for s in text_skills if _norm(s) in skills]

            relevance = 30
            reason = "Popular in your network"
            if ptype == "JOB" and overlap:
                relevance = min(96, 70 + len(overlap) * 8)
                reason = f"Because your skills include {' & '.join(overlap[:2])}"
            elif ptype == "JOB":
                relevance = 55
                reason = "Open job on campus"
            elif author_id and author_id in following:
                relevance = 48
                reason = "Because you follow this author"
            elif post.get("is_following_author"):
                relevance = 48
                reason = "Because you follow this author"

            ranked.append(
                {
                    "post_id": post_id,
                    "relevance": relevance,
                    "reason": reason,
                }
            )

        ranked.sort(key=lambda r: r["relevance"], reverse=True)
        return ranked[:limit]

    def _fetch_post(
        self, post_id: str, authorization: str | None, user_id: uuid.UUID
    ) -> dict[str, Any]:
        base = self._config.CONTENT_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/posts/{post_id}"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return {}
                return resp.json().get("data") or {}
        except Exception as exc:
            logger.warning("Post fetch failed: %s", exc)
            return {}

    def _fetch_profile(
        self,
        target_id: uuid.UUID,
        authorization: str | None,
        caller_id: uuid.UUID,
    ) -> dict[str, Any]:
        base = self._config.USER_PROFILE_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/users/{target_id}"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, caller_id))
                if resp.status_code >= 400:
                    return {}
                return resp.json().get("data") or {}
        except Exception as exc:
            logger.warning("Profile fetch failed: %s", exc)
            return {}

    def _fetch_user_posts(
        self, user_id: uuid.UUID, authorization: str | None
    ) -> list[dict[str, Any]]:
        base = self._config.CONTENT_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/users/{user_id}/posts?page=1&limit=30"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return []
                data = resp.json().get("data")
                return data if isinstance(data, list) else []
        except Exception as exc:
            logger.warning("User posts fetch failed: %s", exc)
            return []

    def _fetch_feed(
        self, authorization: str | None, user_id: uuid.UUID, limit: int = 40
    ) -> list[dict[str, Any]]:
        base = self._config.CONTENT_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/posts?page=1&limit={limit}"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return []
                data = resp.json().get("data")
                return data if isinstance(data, list) else []
        except Exception as exc:
            logger.warning("Feed fetch failed: %s", exc)
            return []

    def _fetch_following_ids(
        self, user_id: uuid.UUID, authorization: str | None
    ) -> set[str]:
        base = self._config.CONTENT_BASE_URL.rstrip("/")
        url = f"{base}/api/v1/users/{user_id}/following?page=1&limit=100"
        try:
            with httpx.Client(timeout=5.0) as client:
                resp = client.get(url, headers=_headers(authorization, user_id))
                if resp.status_code >= 400:
                    return set()
                data = resp.json().get("data")
                if not isinstance(data, list):
                    return set()
                ids: set[str] = set()
                for item in data:
                    if isinstance(item, dict):
                        uid = item.get("user_id") or item.get("id")
                        if uid:
                            ids.add(str(uid))
                    elif item:
                        ids.add(str(item))
                return ids
        except Exception as exc:
            logger.warning("Following fetch failed: %s", exc)
            return set()
