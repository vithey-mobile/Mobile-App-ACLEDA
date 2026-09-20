# API Gateway — Folder Structure

Target output:

```text
backend/services/api-gateway/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/gateway/
    │   │   ├── ApiGatewayApplication.java
    │   │   ├── config/
    │   │   │   ├── VitheyGatewayProperties.java
    │   │   │   ├── CorsConfig.java
    │   │   │   ├── RedisRateLimiterConfig.java
    │   │   │   └── OpenApiConfig.java
    │   │   ├── filter/
    │   │   │   ├── JwtAuthenticationGlobalFilter.java
    │   │   │   ├── RequestIdGlobalFilter.java
    │   │   │   └── UserHeaderForwardFilter.java
    │   │   ├── security/
    │   │   │   └── JwtValidator.java
    │   │   ├── exception/
    │   │   │   └── GatewayErrorHandler.java
    │   │   └── util/
    │   │       └── PublicPathMatcher.java
    │   └── resources/
    │       ├── bootstrap.yml
    │       └── application.yml
    └── test/java/com/vithey/gateway/
```

## Required dependencies

- Spring Cloud Gateway
- Eureka Client, Config Client
- Redis Reactive for rate limiting
- Actuator
- JJWT for token validation

Do not add JPA, PostgreSQL, or RabbitMQ to the gateway.

