# Career Service — Folder Structure

Target output:

```text
backend/services/career-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/career/
    │   │   ├── CareerServiceApplication.java
    │   │   ├── config/
    │   │   ├── controller/
    │   │   │   ├── JobApplicationController.java
    │   │   │   └── UserCvController.java
    │   │   ├── service/
    │   │   │   ├── JobApplicationService.java
    │   │   │   └── UserCvService.java
    │   │   ├── repository/
    │   │   │   ├── JobApplicationRepository.java
    │   │   │   └── UserCvRepository.java
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── mapper/
    │   │   ├── client/
    │   │   │   ├── ContentServiceClient.java
    │   │   │   └── FileServiceClient.java
    │   │   ├── event/publisher/
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/
    │       ├── V1__init_career_schema.sql
    │       └── V2__Job_application_composite_indexes_and_status_check.sql
    └── test/java/com/vithey/career/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, OpenFeign, RabbitMQ, MapStruct, Lombok, springdoc.

