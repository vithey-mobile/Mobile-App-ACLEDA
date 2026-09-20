"""Flutter contract routes under /api/v1/ai/**."""

from __future__ import annotations

import asyncio
import json
import uuid
from typing import Any

from fastapi import APIRouter, Body, Query, Request
from fastapi.responses import Response, StreamingResponse
from pydantic import BaseModel, Field

from openai import OpenAI

from ..chat_service import ChatService, chunk_reply
from ..chat_stubs import stub_reply
from ..cv_app_service import CvAppService
from ..logging_conf import get_logger
from ..product_ai_service import ProductAiService
from .auth import UserDep
from .flutter_envelope import fail, ok, page_meta

logger = get_logger(__name__)

flutter_router = APIRouter(prefix="/api/v1/ai", tags=["flutter-ai"])


class ChatBody(BaseModel):
    message: str = Field(min_length=1)
    topic: str | None = None
    session_id: uuid.UUID | None = None
    client_message_id: str | None = None


class CvGenerateBody(BaseModel):
    target_role: str | None = None
    language: str | None = "en"
    template_id: str | None = None


class CvSuggestBody(BaseModel):
    section: str = Field(min_length=1)
    original_text: str = Field(min_length=1)
    cv_file_id: str | None = None


class JobMatchBody(BaseModel):
    applicant_user_id: str | None = None
    cv_file_id: str | None = None


def _chat(request: Request) -> ChatService:
    return request.app.state.chat_service


def _cv(request: Request) -> CvAppService:
    return request.app.state.cv_app_service


def _product(request: Request) -> ProductAiService:
    return request.app.state.product_ai_service


@flutter_router.post("/chat")
def chat(request: Request, user: UserDep, body: ChatBody):
    try:
        data = _chat(request).chat(
            user.user_id, body.message, body.topic, body.session_id
        )
        return ok(data)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))
    except ValueError as exc:
        return fail(400, "VALIDATION_ERROR", str(exc))
    except Exception as exc:
        return fail(502, "UPSTREAM_ERROR", str(exc))


@flutter_router.post("/chat/stream")
async def chat_stream(request: Request, user: UserDep, body: ChatBody):
    chat_svc = _chat(request)
    config = request.app.state.config
    request_id = chat_svc.registry.register(user.user_id)

    async def event_gen():
        try:
            prepared = await asyncio.to_thread(
                chat_svc.prepare_stream_turn,
                user.user_id,
                body.message,
                body.topic,
                body.session_id,
            )
            meta = {
                "request_id": str(request_id),
                "session_id": str(prepared["session_id"]),
                "user_message_id": str(prepared["user_message_id"]),
                "topic": prepared["topic"],
            }
            yield _sse("meta", json.dumps(meta))

            use_live = (
                config.AI_CHAT_MODE != "stub"
                and bool(config.DEEPSEEK_API_KEY)
            )

            streamed: list[str] = []
            cancelled = False

            if use_live:
                try:
                    history = chat_svc.get_history_for_llm(
                        user.user_id, prepared["session_id"], limit=6
                    )
                    system_prompt = (
                        f"You are Vithey AI, a friendly, intelligent assistant for the Vithey superapp "
                        f"serving Cambodian university students (AUPP/ACLEDA). Topic: {prepared['topic']}. "
                        f"Give concise, helpful answers formatted in Markdown."
                    )
                    messages = [{"role": "system", "content": system_prompt}]
                    messages.extend(history)
                    if not history or history[-1].get("role") != "user":
                        messages.append({"role": "user", "content": body.message})

                    client = OpenAI(
                        api_key=config.DEEPSEEK_API_KEY,
                        base_url=config.DEEPSEEK_BASE_URL,
                        timeout=config.TIMEOUT_SECONDS,
                    )

                    stream = await asyncio.to_thread(
                        client.chat.completions.create,
                        model=config.DEEPSEEK_MODEL,
                        messages=messages,
                        stream=True,
                        max_tokens=config.MAX_TOKENS,
                        temperature=config.TEMPERATURE,
                    )

                    for chunk in stream:
                        if chat_svc.registry.is_cancelled(request_id):
                            cancelled = True
                            break
                        if chunk.choices and chunk.choices[0].delta:
                            text = chunk.choices[0].delta.content or ""
                            if text:
                                streamed.append(text)
                                yield _sse("token", json.dumps({"text": text}))
                except Exception as exc:
                    logger.warning("Live LLM stream error: %s; falling back to stub", exc)
                    if not streamed:
                        reply = stub_reply(prepared["topic"], body.message)
                        for chunk in chunk_reply(reply):
                            if chat_svc.registry.is_cancelled(request_id):
                                cancelled = True
                                break
                            streamed.append(chunk)
                            yield _sse("token", json.dumps({"text": chunk}))
                            await asyncio.sleep(0.02)
            else:
                reply = stub_reply(prepared["topic"], body.message)
                for chunk in chunk_reply(reply):
                    if chat_svc.registry.is_cancelled(request_id):
                        cancelled = True
                        break
                    streamed.append(chunk)
                    yield _sse("token", json.dumps({"text": chunk}))
                    await asyncio.sleep(0.02)

            final = "".join(streamed)
            assistant_id = None
            if final or not cancelled:
                assistant_id = await asyncio.to_thread(
                    chat_svc.complete_stream_turn, prepared, final or ""
                )
            done = {
                "request_id": str(request_id),
                "session_id": str(prepared["session_id"]),
                "message_id": str(assistant_id) if assistant_id else None,
                "cancelled": cancelled,
            }
            yield _sse("done", json.dumps(done))
        except Exception as exc:
            yield _sse(
                "error",
                json.dumps({"code": "UPSTREAM_ERROR", "message": str(exc)}),
            )
        finally:
            chat_svc.registry.mark_done(request_id)

    return StreamingResponse(event_gen(), media_type="text/event-stream")


@flutter_router.post("/messages/{message_id}/regenerate")
def regenerate(request: Request, user: UserDep, message_id: uuid.UUID):
    try:
        data = _chat(request).regenerate(user.user_id, message_id)
        return ok(data)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))
    except ValueError as exc:
        return fail(400, "VALIDATION_ERROR", str(exc))


@flutter_router.delete("/chat/requests/{request_id}", status_code=204)
def cancel_request(request: Request, user: UserDep, request_id: uuid.UUID):
    try:
        _chat(request).cancel(user.user_id, request_id)
        return Response(status_code=204)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.get("/sessions")
def list_sessions(
    request: Request,
    user: UserDep,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    data, total = _chat(request).list_sessions(user.user_id, page, limit)
    return ok(data, page_meta(page, limit, total))


@flutter_router.get("/sessions/{session_id}/messages")
def list_messages(
    request: Request,
    user: UserDep,
    session_id: uuid.UUID,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    try:
        data, total = _chat(request).list_messages(
            user.user_id, session_id, page, limit
        )
        return ok(data, page_meta(page, limit, total))
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.delete("/sessions/{session_id}", status_code=204)
def delete_session(request: Request, user: UserDep, session_id: uuid.UUID):
    try:
        _chat(request).delete_session(user.user_id, session_id)
        return Response(status_code=204)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))


@flutter_router.post("/cv/generate")
def cv_generate(
    request: Request,
    user: UserDep,
    body: CvGenerateBody | None = Body(default=None),
):
    body = body or CvGenerateBody()
    authorization = request.headers.get("Authorization")
    data = _cv(request).generate(
        user.user_id,
        authorization,
        body.target_role,
        body.language,
        body.template_id,
    )
    return ok(data)


@flutter_router.post("/cv/suggest")
def cv_suggest(request: Request, user: UserDep, body: CvSuggestBody):
    data = _cv(request).suggest(
        user.user_id, body.section, body.original_text, body.cv_file_id
    )
    return ok(data)


@flutter_router.post("/jobs/{job_post_id}/match")
def job_match(
    request: Request,
    user: UserDep,
    job_post_id: str,
    body: JobMatchBody | None = Body(default=None),
):
    body = body or JobMatchBody()
    try:
        data = _product(request).match_job(
            user.user_id,
            job_post_id,
            request.headers.get("Authorization"),
            body.applicant_user_id,
            body.cv_file_id,
        )
        return ok(data)
    except LookupError as exc:
        return fail(404, "NOT_FOUND", str(exc))
    except ValueError as exc:
        return fail(400, "VALIDATION_ERROR", str(exc))
    except Exception as exc:
        return fail(502, "UPSTREAM_ERROR", str(exc))


@flutter_router.get("/skills/score")
def skills_score(request: Request, user: UserDep):
    try:
        data = _product(request).skill_scores(
            user.user_id, request.headers.get("Authorization")
        )
        return ok(data)
    except Exception as exc:
        return fail(502, "UPSTREAM_ERROR", str(exc))


@flutter_router.get("/feed/recommendations")
def feed_recommendations(
    request: Request,
    user: UserDep,
    limit: int = Query(20, ge=1, le=50),
):
    try:
        data = _product(request).feed_recommendations(
            user.user_id, request.headers.get("Authorization"), limit
        )
        return ok(data)
    except Exception as exc:
        return fail(502, "UPSTREAM_ERROR", str(exc))


def _sse(event: str, data: str) -> str:
    # Safely prefix every line with data: so newlines never break the SSE envelope
    data_lines = "\n".join(f"data: {line}" for line in data.splitlines())
    return f"event: {event}\n{data_lines}\n\n"
