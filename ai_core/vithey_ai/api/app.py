"""FastAPI application factory for the vithey-ai HTTP service.

Run with:
    uvicorn vithey_ai.api.app:create_app --factory --port 8100
or via the CLI:
    python main.py serve
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from ..config import Config
from ..logging_conf import get_logger
from .deps import build_ai
from .middleware import (
    BodySizeLimitMiddleware,
    PerClientRateLimitMiddleware,
    RequestContextMiddleware,
)
from .routes import health_router, router

logger = get_logger(__name__)


def create_app(config: Config | None = None, ai=None) -> FastAPI:
    """Build the app. Pass ``ai`` to inject a fake VitheyAI (tests)."""
    config = config or Config()
    app = FastAPI(
        title="Vithey AI Core",
        description=(
            "CV generation service for the Vithey superapp: extracts "
            "structured activities from user posts and turns them into a "
            "standard, evidence-backed CV."
        ),
        version=Config.VERSION,
    )

    # App-scoped AI facade (overridable in tests).
    app.state.ai = ai if ai is not None else build_ai(config)

    # Middleware (order matters: outermost first).
    app.add_middleware(RequestContextMiddleware)
    app.add_middleware(
        PerClientRateLimitMiddleware,
        requests_per_minute=config.API_RATE_LIMIT_PER_MINUTE,
    )
    app.add_middleware(
        BodySizeLimitMiddleware, max_bytes=config.API_MAX_BODY_BYTES
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=config.API_CORS_ORIGINS or ["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID", "X-Process-Time-Ms", "X-RateLimit-Remaining"],
    )

    app.include_router(health_router)
    app.include_router(router)
    logger.info("vithey-ai HTTP app created (version %s)", Config.VERSION)
    return app
