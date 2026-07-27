# File Service — Folder Structure

Target output:

```text
backend/services/file-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/file/
    │   │   ├── FileServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── MinioConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── OpenApiConfig.java
    │   │   │   └── JacksonConfig.java
    │   │   ├── controller/FileController.java
    │   │   ├── service/
    │   │   │   ├── FileStorageService.java
    │   │   │   └── FileMetadataService.java
    │   │   ├── repository/FileMetadataRepository.java
    │   │   ├── entity/FileMetadata.java
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── mapper/FileMapper.java
    │   │   ├── security/CurrentUserProvider.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/
    │       ├── V1__init_file_schema.sql
    │       └── V2__Drop_unused_file_metadata_indexes.sql
    └── test/java/com/vithey/file/
```

## Required dependencies

Spring Web, Validation, Security, Actuator, MinIO Java SDK, JPA metadata, PostgreSQL, Flyway, Eureka Client, Config Client, MapStruct, Lombok, springdoc.

