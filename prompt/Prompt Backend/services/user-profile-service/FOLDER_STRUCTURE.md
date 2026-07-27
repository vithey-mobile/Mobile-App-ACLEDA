# User Profile Service — Folder Structure

Target output:

```text
backend/services/user-profile-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/profile/
    │   │   ├── UserProfileServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RabbitMqConfig.java
    │   │   │   ├── FeignAuthConfig.java
    │   │   │   └── OpenApiConfig.java
    │   │   ├── controller/
    │   │   │   ├── UserController.java          # @Tag User Profile + @Operation / @Parameter
    │   │   │   └── SettingsController.java      # @Tag User Settings + @Operation
    │   │   ├── service/
    │   │   │   ├── ProfileService.java          # Feign outside TX for avatar; language/theme projection for /me
    │   │   │   ├── SettingsService.java         # dirty-check before save
    │   │   │   └── UserSearchService.java       # escape LIKE, min length, page/limit caps
    │   │   ├── repository/
    │   │   │   ├── ProfileRepository.java
    │   │   │   ├── UserSettingsRepository.java
    │   │   │   ├── UserSearchProjection.java    # search column projection
    │   │   │   └── LanguageThemeProjection.java # /me language+theme only
    │   │   ├── entity/
    │   │   │   ├── Profile.java
    │   │   │   ├── UserSettings.java
    │   │   │   ├── AppLanguage.java
    │   │   │   └── AppTheme.java
    │   │   ├── dto/request/                     # @Schema examples on update DTOs
    │   │   ├── dto/response/
    │   │   ├── mapper/
    │   │   ├── client/FileServiceClient.java
    │   │   ├── event/
    │   │   │   ├── listener/UserRegisteredEventListener.java
    │   │   │   └── payload/UserRegisteredEvent.java
    │   │   ├── security/
    │   │   │   ├── JwtProvider.java             # reused JwtParser
    │   │   │   ├── JwtAuthenticationFilter.java # skip actuator/swagger
    │   │   │   ├── CurrentUser.java
    │   │   │   └── CurrentUserProvider.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/
    │       ├── application.yml                  # Hikari pool + Feign timeouts
    │       └── db/migration/
    │           ├── V1__init_profile_schema.sql
    │           └── V2__Enable_pg_trgm_and_full_name_gin_index.sql
    └── test/java/com/vithey/profile/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, OpenFeign, RabbitMQ listener, MapStruct, Lombok, springdoc.
