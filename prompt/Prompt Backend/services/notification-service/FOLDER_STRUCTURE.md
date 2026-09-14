# Notification Service — Folder Structure

Target output:

```text
backend/services/notification-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/notification/
    │   │   ├── NotificationServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── FirebaseConfig.java
    │   │   │   ├── RabbitMqConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   └── OpenApiConfig.java
    │   │   ├── controller/
    │   │   │   ├── NotificationController.java
    │   │   │   └── DeviceTokenController.java
    │   │   ├── service/
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── event/listener/
    │   │   ├── event/mapper/
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/
    │       ├── V1__init_notification_schema.sql
    │       └── V2__Notification_type_and_platform_checks.sql
    └── test/java/com/vithey/notification/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, RabbitMQ listeners, Firebase Admin SDK, MapStruct, Lombok, springdoc.

