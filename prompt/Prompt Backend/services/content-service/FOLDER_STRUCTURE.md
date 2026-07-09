# Content Service — Folder Structure

Target output:

```text
backend/services/content-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/content/
    │   │   ├── ContentServiceApplication.java
    │   │   ├── config/SecurityConfig.java
    │   │   ├── config/RabbitMqConfig.java
    │   │   ├── config/OpenApiConfig.java
    │   │   ├── controller/
    │   │   │   ├── PostController.java
    │   │   │   ├── CommentController.java
    │   │   │   ├── ReactionController.java
    │   │   │   └── FollowController.java
    │   │   ├── service/
    │   │   │   ├── PostService.java
    │   │   │   ├── FeedService.java
    │   │   │   ├── CommentService.java
    │   │   │   ├── ReactionService.java
    │   │   │   └── FollowService.java
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── mapper/
    │   │   ├── client/
    │   │   │   ├── UserProfileClient.java
    │   │   │   └── FileServiceClient.java
    │   │   ├── event/publisher/
    │   │   ├── event/payload/
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/V1__init_content_schema.sql
    └── test/java/com/vithey/content/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, OpenFeign, RabbitMQ, MapStruct, Lombok, springdoc.

