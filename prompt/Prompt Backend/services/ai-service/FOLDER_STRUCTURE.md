# AI / Chatbot — Folder Structure

## In Vithey Java repo (`backend/services/ai-service/`)

Integration docs only — **no source code**:

```text
backend/services/ai-service/
├── README.md
├── INTEGRATION.md
├── API.md
├── PYTHON_CHECKLIST.md
└── docker-compose.integration.example.yml
```

**Not present:** `pom.xml`, `src/`, `Dockerfile`, Maven CI.

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
