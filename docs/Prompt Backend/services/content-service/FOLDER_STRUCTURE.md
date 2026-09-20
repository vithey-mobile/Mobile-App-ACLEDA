# Content Service — Folder Structure

Target output (as implemented):

```text
backend/services/content-service/
├── pom.xml
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── src/
    ├── main/
    │   ├── java/com/vithey/content/
    │   │   ├── ContentServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RabbitMqConfig.java          # TopicExchange + Jackson2JsonMessageConverter
    │   │   │   ├── OpenApiConfig.java            # bearerAuth + springdoc
    │   │   │   └── FeignAuthConfig.java          # forward Authorization / X-User-*
    │   │   ├── controller/
    │   │   │   ├── PostController.java           # @Tag Posts + OpenAPI examples
    │   │   │   ├── CommentController.java
    │   │   │   ├── ReactionController.java
    │   │   │   └── FollowController.java
    │   │   ├── service/
    │   │   │   ├── PostService.java
    │   │   │   ├── FeedService.java
    │   │   │   ├── CommentService.java
    │   │   │   ├── ReactionService.java
    │   │   │   ├── FollowService.java
    │   │   │   └── PostEnrichmentService.java    # enrich / enrichAll (batched)
    │   │   ├── repository/
    │   │   │   ├── PostRepository.java
    │   │   │   ├── CommentRepository.java        # + countGroupedByPostId
    │   │   │   ├── ReactionRepository.java       # + countGroupedByPostId, findReactedPostIds
    │   │   │   ├── FollowRepository.java
    │   │   │   └── MentionRepository.java
    │   │   ├── entity/
    │   │   ├── dto/request/                      # @Schema examples
    │   │   ├── dto/response/                     # @Schema examples
    │   │   ├── mapper/
    │   │   ├── client/
    │   │   │   ├── UserProfileClient.java
    │   │   │   └── FileServiceClient.java
    │   │   ├── security/
    │   │   │   ├── JwtAuthenticationFilter.java  # parse-only try/catch + JSON 401
    │   │   │   ├── JwtProvider.java
    │   │   │   ├── CurrentUser.java
    │   │   │   └── CurrentUserProvider.java
    │   │   ├── event/publisher/ContentEventPublisher.java
    │   │   ├── event/payload/
    │   │   ├── exception/
    │   │   │   ├── ApiException.java
    │   │   │   ├── ErrorCode.java
    │   │   │   └── GlobalExceptionHandler.java
    │   │   └── util/ApiResponseWrapper.java
    │   └── resources/
    │       ├── application.yml
    │       ├── application-docker.yml
    │       ├── bootstrap.yml
    │       └── db/migration/
    │           ├── V1__init_content_schema.sql
    │           ├── V2__Content_indexes_checks_and_drop_dead.sql
    │           └── V3__Restore_reaction_and_mention_indexes.sql
    └── test/java/com/vithey/content/
        └── service/
            ├── FollowServiceTest.java
            └── PostServiceTest.java
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, OpenFeign, RabbitMQ, MapStruct, springdoc, JJWT.

## Local API testing

- Collection: `postman/Content-Module.postman_collection.json` (gitignored local file)
- Env: `postman/Vithey-Local.postman_environment.json` (`content_service_url`, `post_id`, `poster_file_id`, `video_file_id`)
- Gateway: `http://localhost:8080`
