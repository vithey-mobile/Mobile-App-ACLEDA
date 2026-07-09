# AI / Chatbot — Folder Structure

## In Vithey Java repo (`backend/services/ai-service/`)

Docker/runtime files only — **no markdown docs in backend**. Integration prompts live in `Prompt Backend/services/ai-service/`:

```text
backend/services/ai-service/
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── src/                        # Java ai-service if implemented here
```

Prompt docs (this folder):

```text
Prompt Backend/services/ai-service/
├── INTEGRATION.md
├── API_ENDPOINTS.md
├── SERVICE_PROMPT.md
└── ...
```

## In your Python project (you build this)

Example layout (your choice):

```text
your-python-ai-project/
├── requirements.txt
├── Dockerfile
├── docker-compose.yml          # joins vithey-network + gdce-network
├── app/
│   ├── main.py                 # FastAPI + Eureka register
│   ├── api/                    # /api/v1/ai/* routes
│   ├── auth/                   # Vithey JWT + X-User-* headers
│   └── services/               # your chatbot logic
└── tests/
```

If reusing GDCE stack, your Vithey adapter can live inside `D:\GDCE-chatbot\chatbot_review\` or as a thin wrapper service.

## Java repo references

| Path | Role |
| --- | --- |
| `services/api-gateway/` | Route `/api/v1/ai/**` |
| `infrastructure/eureka-server/` | Discovery |
| `infrastructure/config-repo/ai-service.yml` | Optional env reference |
