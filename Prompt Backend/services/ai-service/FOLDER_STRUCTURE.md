# AI Service — Folder Structure

Target output:

```text
vithey-backend/services/ai-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/ai/
    │   │   ├── AiServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── RedisConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── OpenApiConfig.java
    │   │   │   └── AiProviderConfig.java
    │   │   ├── controller/
    │   │   ├── service/
    │   │   ├── provider/
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── support/PromptLoader.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   ├── resources/
    │   │   ├── db/migration/V1__init_ai_schema.sql
    │   │   └── prompts/
    │   │       ├── cv-system.md
    │   │       ├── job-system.md
    │   │       ├── interview-system.md
    │   │       ├── student-system.md
    │   │       └── finance-system.md
    └── test/java/com/vithey/ai/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Security, Eureka Client, Config Client, Redis, RestClient/WebClient, MapStruct, Lombok, springdoc.

