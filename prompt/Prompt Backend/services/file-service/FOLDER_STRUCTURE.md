# File Service — Folder Structure

Target output:

```text
backend/services/file-service/
├── pom.xml
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── src/
    ├── main/
    │   ├── java/com/vithey/file/
    │   │   ├── FileServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── MinioConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   └── OpenApiConfig.java
    │   │   ├── controller/FileController.java
    │   │   ├── service/
    │   │   │   ├── FileStorageService.java
    │   │   │   ├── FileMetadataService.java
    │   │   │   ├── FileMetadataPersistence.java
    │   │   │   └── FileValidationService.java
    │   │   ├── repository/FileMetadataRepository.java
    │   │   ├── entity/
    │   │   │   ├── FileMetadata.java
    │   │   │   └── StoredFileType.java
    │   │   ├── dto/response/
    │   │   │   ├── FileUploadResponse.java
    │   │   │   └── FileMetadataResponse.java
    │   │   ├── mapper/FileMapper.java
    │   │   ├── security/
    │   │   │   ├── JwtProvider.java
    │   │   │   ├── JwtAuthenticationFilter.java
    │   │   │   ├── CurrentUser.java
    │   │   │   └── CurrentUserProvider.java
    │   │   ├── exception/
    │   │   │   ├── ApiException.java
    │   │   │   ├── ErrorCode.java
    │   │   │   └── GlobalExceptionHandler.java
    │   │   └── util/ApiResponseWrapper.java
    │   └── resources/
    │       ├── application.yml
    │       ├── application-docker.yml
    │       └── db/migration/
    │           ├── V1__init_file_schema.sql
    │           └── V2__Drop_unused_file_metadata_indexes.sql
    └── test/java/com/vithey/file/
```

No request DTOs — multipart params are bound on the controller. Snake_case JSON comes from `application.yml` (no `JacksonConfig`).

## Required dependencies

Spring Web, Validation, Security, Actuator, MinIO Java SDK, JPA metadata, PostgreSQL, Flyway, Eureka Client, Config Client, MapStruct, Lombok, springdoc.
