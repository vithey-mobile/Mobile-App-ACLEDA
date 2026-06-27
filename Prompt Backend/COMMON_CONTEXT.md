# AI-Chatbot Microservice System - Common Context

## Objective
Build a backend-only microservice platform for an AI chatbot system with one orchestrator and four feature services. The project must be production-oriented, testable service-by-service, and strict about service isolation.

## Services
1. **orchestrator**: public gateway, auth validation, LLM-based intent classification, request rewriting, downstream routing.
2. **tax-service**: deterministic tax calculation and PostgreSQL-backed tax rate storage.
3. **trade-data-service**: LLM-assisted trade question understanding, metadata-to-DAL request mapping, DAL HTTP integration, frontend-ready output.
4. **hs-lookup-service**: direct-access HS lookup, LLM-assisted ranking, PostgreSQL-backed HS reference data.
5. **customs-knowledge-service**: RAG over Qdrant with grounded LLM generation.

## Mandatory Architecture Rules
- Backend only. No frontend code.
- Monorepo.
- HTTP is the default for service-to-service communication in v1.
- gRPC and message queues must remain architecture-ready, but do not force them into the first implementation unless a specific service design explicitly needs them.
- No shared Python packages between services.
- Each service is independently runnable.
- Each service is independently testable.
- Databases are treated as external services and run separately from app containers.



## Strict Coding Standard
The AI agent must follow these rules exactly.

### 1. File and folder discipline
- Do not invent random folders.
- Use only the approved structure in this prompt.
- Every service must have the same base structure.
- Put code in the correct layer only.
- Do not place business logic inside route files.
- Do not place HTTP client logic inside service logic.
- Do not place database queries inside route handlers.

### 2. Mandatory layer responsibilities
#### `app/api/v1/endpoints/`
- Only request/response handling.
- No business logic.
- No database access.
- No direct LLM calls.

#### `app/services/`
- Business logic only.
- Can call clients, repositories, or helper functions.
- Must not contain FastAPI request objects.

#### `app/clients/`
- Outbound integration only.
- Use for LLM providers, HTTP upstreams, Qdrant, etc.
- Must be isolated and replaceable.

#### `app/db/repositories/`
- Database access only.
- Use ORM or parameterized queries only.
- No raw SQL string concatenation.

#### `app/core/`
- Configuration, logging, auth, errors, shared constants.
- No business logic.

### 3. Mandatory response contract
Every service response must use this exact envelope structure.

#### Success
```json
{
  "success": true,
  "data": {},
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "service": "service-name"
  }
}
```

#### Error
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  },
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "service": "service-name"
  }
}
```

### 4. Mandatory endpoint rules
- Every endpoint must be under `/api/v1/` except `/health`.
- Every endpoint must have request and response Pydantic models.
- Every endpoint must define OpenAPI tags, summary, description, and examples.
- Every endpoint must return a documented status code.
- Every public endpoint must support auth toggle behavior where applicable.

### 5. Mandatory error model
- Use a single error response model across the service.
- Validation errors must be converted into the standard envelope.
- Upstream errors must be mapped to `502` or `503` where appropriate.
- Auth errors must be mapped to `401` or `403`.

### 6. Mandatory docs
Each service must always include:
- `README.md`
- `API.md`
- `ARCHITECTURE.md`
- OpenAPI examples in Pydantic schema classes.

### 7. Mandatory testing
Each service must include:
- one unit test file per major service module
- one integration test file per endpoint group
- mocked LLM tests
- mocked HTTP client tests
- DB tests where DB exists
- one e2e test for the main happy path

### 8. Mandatory code style
- Use type hints everywhere.
- Use Pydantic V2 models everywhere for request/response data.
- Use dataclasses only if clearly justified.
- Use async functions for I/O operations.
- Use dependency injection for FastAPI services and clients.
- Use explicit imports, not wildcard imports.
- Keep functions short and single-purpose.
- Avoid large monolithic files.

### 9. Mandatory OpenAPI quality
- Every response schema must have examples.
- Every request schema must have examples.
- Every endpoint must return documented schema examples.
- Every service must have health check examples.
- Keep error examples realistic.

### 10. Mandatory provider handling
- LLM provider selection must be an environment-driven switch.
- No code may assume OpenAI only.
- No code may assume Gemini only.
- No code may assume local models only.
- Use provider adapters so the service can swap providers without rewriting business logic.

## Required Tech Stack
- Python 3.12
- FastAPI latest stable
- Uvicorn latest stable
- Pydantic v2
- pydantic-settings
- SQLAlchemy 2.x
- Alembic
- PostgreSQL 16
- Qdrant latest stable
- httpx for service-to-service HTTP calls only
- pytest, pytest-asyncio, pytest-cov
- Ruff
- Mypy
- Docker multi-stage builds
- Docker Compose v2

## LLM Rules
- LLM provider must be configurable per service via environment variables.
- Do not hardcode OpenAI as the only provider.
- Each service MUST support these provider modes:
  - `LLM_PROVIDER=openai` → Use OpenAI API
  - `LLM_PROVIDER=gemini_openai_compat` → Use Gemini OpenAI-compatible endpoint
  - `LLM_PROVIDER=local_openai_compat` → Use local OpenAI-compatible endpoint (Ollama, LM Studio, vLLM, etc.)
- Required environment variables per service:
  - `LLM_PROVIDER`
  - `LLM_BASE_URL`
  - `LLM_API_KEY`
  - `LLM_MODEL`
- Each service owns its own LLM client or provider adapter.
- Use the OpenAI client only as an interface style if the target provider supports OpenAI-compatible API.
- Do not share one central LLM client across all services.
- Use provider-appropriate SDKs for LLM calls (not httpx).

## Auth Rules
- SSO exists outside this system.
- Each service is auth-ready.
- Add `AUTH_ENABLED=true|false`.
- Orchestrator must validate auth when enabled.
- HS lookup must support direct access and auth toggling.
- Other services can keep auth disabled by default if they are only called behind the orchestrator.

## Database Rules
- Tax-service uses PostgreSQL.
- HS lookup-service uses PostgreSQL.
- Customs knowledge-service uses Qdrant.
- Trade-data-service and orchestrator may keep DB support standby-ready if needed later.
- Use Alembic migrations for SQL services.

## HTTP Client Rules
- Use `httpx` only for service-to-service HTTP.
- Use provider-appropriate SDKs or compatible clients for LLM calls.
- Add explicit timeout and retry handling for downstream service calls.

## Logging
- Structured JSON logs to stdout.
- Include service name, request id, user id if available, latency, route, and upstream target.

## Error Handling
- Standard FastAPI errors.
- Clear domain-specific responses.
- Orchestrator can use simple retry with exponential backoff for transient downstream failures.
- No circuit breakers or heavy resilience frameworks in v1.

## Testing
Each service must include:
- unit tests
- integration tests
- mocked LLM tests
- mocked HTTP tests
- DB integration tests where relevant
- e2e happy-path tests
- coverage target around 80% where reasonable

## Documentation
Each service must include:
- README.md
- API.md
- ARCHITECTURE.md

Repo-level docs must include:
- root README.md
- onboarding
- local run instructions
- compose usage
- env var explanation

## Repo Layout
```text
ai-chatbot/
  README.md
  Makefile
  docker-compose.yml
  docker-compose-app.yml
  docker-compose-db.yml
  services/
    orchestrator/
    tax-service/
    trade-data-service/
    hs-lookup-service/
    customs-knowledge-service/
```

## Standard Service Layout
```text
service-name/
  Dockerfile
  requirements.txt
  .env.example
  README.md
  API.md
  ARCHITECTURE.md
  alembic.ini
  alembic/
  app/
    main.py
    api/
      dependencies.py
      v1/
        router.py
        endpoints/
    core/
      config.py
      logger.py
      errors.py
      auth.py
    db/
      session.py
      models/
      repositories/
    schemas/
    services/
    clients/
    prompts/
    utils/
  tests/
    unit/
    integration/
    e2e/
```




## Additional Best Practices

### 1. Prompt schema standardization
- Every prompt file should follow a consistent structure:
  - `# Title`
  - Purpose
  - Inputs
  - Rules
  - Output format
  - Examples
- Keep prompt files short and task-specific.
- Prefer multiple small prompt files over one huge prompt.

### 2. Model-specific settings
- Keep model configuration separate from prompt content.
- Store model name, temperature, max tokens, timeout, and retry settings in config.
- Do not embed model tuning values inside prompt text.

### 3. Output validation
- Parse LLM output into a typed Pydantic schema.
- Reject malformed outputs.
- Use a fallback or retry strategy if output does not match schema.

### 4. Prompt testing
- Add sample input/output cases for each prompt.
- Validate prompt behavior in unit tests.
- Mock LLM responses in tests.
- Keep prompt regressions visible.

### 5. Prompt loading
- Load prompts from files with a dedicated prompt loader.
- Do not mix prompt loading with route logic.
- Cache prompt files if needed, but keep source of truth in Markdown.

### 6. Service-specific prompt sets
- Orchestrator: intent, route, rewrite, answer formatting.
- Tax service: tax interpretation, rate explanation, calculation explanation.
- Trade data: metadata extraction, query generation, response summarization.
- HS lookup: commercial description detection, 6-digit inference, 8-digit ranking, reason generation.
- Customs knowledge: retrieval, synthesis, citation, answer formatting.

## OpenAPI Response Standards
All endpoints must follow OpenAPI 3.1 standards with consistent response envelopes.

### Standard Success Response Envelope
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "service": "service-name"
  }
}
```

### Standard Error Response Envelope
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { ... }
  },
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "service": "service-name"
  }
}
```

### Required HTTP Status Codes
- `200` — Success
- `201` — Created
- `400` — Bad Request (validation error)
- `401` — Unauthorized (missing/invalid auth)
- `403` — Forbidden (insufficient permissions)
- `404` — Not Found
- `409` — Conflict
- `422` — Unprocessable Entity (Pydantic validation)
- `500` — Internal Server Error
- `502` — Bad Gateway (upstream service error)
- `503` — Service Unavailable

### Response Headers (All Endpoints)
- `X-Request-ID` — UUID for tracing
- `Content-Type` — `application/json`

### OpenAPI Documentation
- All endpoints must have:
  - `summary`
  - `description`
  - `tags`
  - `requestBody` schema with examples
  - `responses` with full envelope schemas
  - `security` requirements if auth-needed
- Use Pydantic models with `Field()` for all schema validation
- Include `example` in all schema definitions



## Prompt Management Rules
Because every service may call an LLM frequently, prompts must be stored as structured Markdown files and loaded at runtime.

### Required Prompt File Pattern
Each service must keep prompts in a dedicated folder such as:
```text
app/prompts/
  system.md
  intent.md
  extract.md
  route.md
  explain.md
  response.md
```

### Prompt File Rules
- Do not hardcode large prompts directly inside route handlers.
- Do not bury long prompt text in business logic files.
- Keep prompt text in `.md` files for readability and version control.
- Load prompt templates from files at runtime.
- Keep prompt rendering logic separate from business logic.
- Use small, focused prompt files per task.
- If a prompt becomes too long, split it into multiple Markdown files.

### Prompt Flow Examples
- Orchestrator: intent, route, rewrite, answer normalization prompts.
- Tax service: interpretation prompt, explanation prompt.
- Trade data service: query understanding, metadata extraction, response formatting prompts.
- HS lookup service: commercial description detection, 6-digit inference, 8-digit ranking prompts.
- Customs knowledge service: retrieval prompt, answer synthesis prompt, citation prompt.

### Prompt Versioning
- Each prompt file should have a clear filename.
- Prompt updates must be reviewed like code changes.
- Prompt changes must be testable and documented.



## Tech Stack and Algorithm Guidance

### Backend stack
- Python 3.12
- FastAPI latest stable
- Uvicorn latest stable
- Pydantic v2
- pydantic-settings
- SQLAlchemy 2.x
- Alembic
- PostgreSQL 16
- Qdrant latest stable
- httpx for service-to-service HTTP only
- pytest, pytest-asyncio, pytest-cov
- Ruff
- Mypy
- Docker multi-stage builds
- Docker Compose v2

### LLM stack
- Keep provider configurable per service.
- Use provider adapters for OpenAI-compatible or provider-native APIs.
- Use Markdown prompt files loaded at runtime.
- Parse LLM output into typed schemas.

### Algorithm guidance by service
#### Orchestrator
- Use LLM-based intent classification.
- Use explicit routing rules after classification.
- Use retry with backoff for downstream failures.
- Normalize response shape before returning.

#### Tax service
- Use deterministic calculation logic.
- Use a rule-based calculator with tax rate lookup.
- LLM may only help interpret user intent or explain results.
- Do not let LLM perform the math.

#### Trade data service
- Use LLM to interpret user question and extract query intent.
- Map extracted intent to metadata and DAL query structure.
- Use deterministic response rendering for table/chart payloads.
- Use LLM only to help with explanation or summarization.

#### HS lookup service
- Use LLM to detect commercial description.
- Infer 6-digit heading first.
- Retrieve candidate 8-digit items under that heading.
- Use LLM to rank top-k candidates and explain the choice.
- Keep ranking output structured and reproducible.

#### Customs knowledge service
- Use embedding retrieval from Qdrant.
- Retrieve top-k relevant chunks.
- Use LLM to synthesize grounded answer.
- Include references and confidence metadata.

### Algorithm design rules
- Use simple, explainable algorithms first.
- Do not over-engineer with agent frameworks unless necessary.
- Keep each service algorithm small and testable.
- Prefer deterministic logic where business correctness matters.
- Use LLM only for interpretation, ranking, or synthesis tasks.
- Store algorithm steps in code comments and docs when needed.



## Algorithm Migration Rule
- Existing business algorithms from previous projects may be migrated later by the human developer.
- The AI agent must create clean algorithm placeholders and interfaces only.
- Do not force a final algorithm implementation if the human wants to migrate an existing one.
- For services with complex business rules, create:
  - a clear algorithm interface,
  - a placeholder implementation,
  - a well-documented extension point,
  - test cases that can be reused after migration.
- Keep the algorithm entry points small and replaceable.

## Pydantic Schema Standards
All response and request schemas must use Pydantic V2 with explicit type hints and Field() validation.

### Required Pydantic Base Models
```python
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Any, List
from uuid import UUID
from datetime import datetime

class MetaResponse(BaseModel):
    request_id: UUID = Field(..., description="Unique request ID for tracing")
    timestamp: datetime = Field(..., description="ISO8601 timestamp")
    service: str = Field(..., description="Service name")

class ErrorDetail(BaseModel):
    code: str = Field(..., description="Error code")
    message: str = Field(..., description="Human-readable error message")
    details: Optional[dict] = Field(None, description="Additional error details")

class ErrorResponse(BaseModel):
    success: bool = Field(False, const=True)
    error: ErrorDetail = Field(..., description="Error details")
    meta: MetaResponse = Field(..., description="Response metadata")

class SuccessResponse(BaseModel):
    success: bool = Field(True, const=True)
    data: Any = Field(..., description="Response data")
    meta: MetaResponse = Field(..., description="Response metadata")
```

### Field Validation Rules
- All fields must have `Field()` with `description`
- Use `Optional` for nullable fields
- Use explicit type hints (no `Any` without justification)
- Add `min_length`, `max_length`, `gt`, `ge`, `pattern` where applicable
- Add `example` or `json_schema_extra` for documentation

## Health Check Standards
All services must implement `/health` endpoint with these requirements:

### Health Response Schema
```json
{
  "success": true,
  "data": {
    "status": "healthy|unhealthy|degraded",
    "service": "service-name",
    "version": "1.0.0",
    "checks": {
      "database": "healthy|unhealthy|unknown",
      "llm": "healthy|unhealthy|unknown",
      "upstream_services": "healthy|unhealthy|unknown"
    },
    "uptime_seconds": 12345,
    "timestamp": "2026-06-08T16:00:00Z"
  },
  "meta": { ... }
}
```

### Health Check Requirements
- Check database connection (if applicable)
- Check LLM connectivity (if applicable)
- Check upstream service connectivity (if applicable)
- Return `200` for healthy, `503` for unhealthy
- Include `X-Health-Status` header

## Rate Limiting Standards
All public-facing endpoints must support rate limiting:

### Rate Limit Headers
- `X-RateLimit-Limit` — Max requests per window
- `X-RateLimit-Remaining` — Remaining requests
- `X-RateLimit-Reset` — Unix timestamp when limit resets
- `Retry-After` — Seconds to wait (on 429)

### Rate Limit Response (429)
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "details": {
      "limit": 100,
      "window_seconds": 60,
      "retry_after": 45
    }
  },
  "meta": { ... }
}
```

## Pagination Standards
All list endpoints must support pagination:

### Pagination Query Parameters
- `page` — Page number (default: 1, min: 1)
- `per_page` — Items per page (default: 20, min: 1, max: 100)
- `sort_by` — Sort field
- `sort_order` — `asc` or `desc` (default: asc)

### Pagination Response Schema
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total_items": 150,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  },
  "meta": { ... }
}
```

## CORS Standards
All services must include CORS middleware:

### Allowed Origins
- Configurable via `CORS_ORIGINS` env var (comma-separated)
- Default: `["http://localhost:3000", "http://localhost:8080"]`

### CORS Headers
- `Access-Control-Allow-Origin`
- `Access-Control-Allow-Methods`
- `Access-Control-Allow-Headers`
- `Access-Control-Max-Age`

## API Versioning Standards
All APIs must be versioned:

### Versioning Pattern
- URL path: `/api/v1/...`
- All endpoints must include version in path
- Version must be in OpenAPI `info.version`
- Deprecation must be documented with `X-Deprecated` header

## Security Standards
All services must implement security best practices:

### Security Headers
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- `Content-Security-Policy: default-src 'self'`

### Authentication
- JWT bearer token in `Authorization: Bearer <token>`
- Token validation via `app/core/auth.py`
- Optional via `AUTH_ENABLED` env var

### Input Validation
- All inputs validated via Pydantic
- No raw SQL (use ORM or parameterized queries)
- Sanitize user input before LLM calls
- Request size limits via `MAX_REQUEST_SIZE`


## Output Quality
- No TODO placeholders.
- No pseudo-code.
- No vague “implement later” comments.
- Generate complete runnable code.
- Keep modules small and explicit.
- Keep services isolated.


## Standardization Rule
- Build a standard project structure with standard request and response models.
- Do not hard-code business behavior into routes or handlers.
- Keep algorithms isolated behind interfaces so they can be migrated from an old project.
- Use configuration, typed schemas, and service boundaries instead of embedded logic.
- The goal is a clean, maintainable project where the algorithm is plugged in, not scattered across the codebase.
