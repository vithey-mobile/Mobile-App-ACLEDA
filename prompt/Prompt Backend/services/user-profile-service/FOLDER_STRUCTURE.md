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
    │   │   │   ├── OpenApiConfig.java
    │   │   │   └── JacksonConfig.java
    │   │   ├── controller/
    │   │   │   ├── UserController.java
    │   │   │   └── SettingsController.java
    │   │   ├── service/
    │   │   │   ├── ProfileService.java
    │   │   │   ├── SettingsService.java
    │   │   │   └── UserSearchService.java
    │   │   ├── repository/
    │   │   │   ├── ProfileRepository.java
    │   │   │   └── UserSettingsRepository.java
    │   │   ├── entity/
    │   │   │   ├── Profile.java
    │   │   │   └── UserSettings.java
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── mapper/
    │   │   ├── client/FileServiceClient.java
    │   │   ├── event/listener/UserRegisteredEventListener.java
    │   │   ├── security/CurrentUserProvider.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/
    │       ├── V1__init_profile_schema.sql
    │       └── V2__Enable_pg_trgm_and_full_name_gin_index.sql
    └── test/java/com/vithey/profile/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, OpenFeign, RabbitMQ listener, MapStruct, Lombok, springdoc.

