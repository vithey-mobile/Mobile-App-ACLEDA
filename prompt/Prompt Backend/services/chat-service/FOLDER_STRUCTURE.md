# Chat Service — Folder Structure

Target output:

```text
backend/services/chat-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/chat/
    │   │   ├── ChatServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── WebSocketConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RabbitMqConfig.java
    │   │   │   └── RedisConfig.java
    │   │   ├── controller/
    │   │   ├── websocket/
    │   │   ├── service/
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── event/publisher/
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/
    │       ├── V1__init_chat_schema.sql
    │       └── V2__Chat_indexes_checks_and_drop_dead.sql
    └── test/java/com/vithey/chat/
```

## Required dependencies

Spring Web, WebSocket/STOMP, JPA, PostgreSQL, Flyway, Security, Eureka Client, Config Client, RabbitMQ, Redis optional presence, MapStruct, Lombok, springdoc.

