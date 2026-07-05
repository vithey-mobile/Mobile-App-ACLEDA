# Finance Service — Folder Structure

Target output:

```text
vithey-backend/services/finance-service/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/finance/
    │   │   ├── FinanceServiceApplication.java
    │   │   ├── config/
    │   │   ├── controller/
    │   │   │   ├── PaymentController.java
    │   │   │   └── FeeController.java
    │   │   ├── service/
    │   │   │   ├── PaymentService.java
    │   │   │   └── FeeService.java
    │   │   ├── scheduler/PaymentAlertScheduler.java
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/response/
    │   │   ├── event/listener/StudentVerifiedEventListener.java
    │   │   ├── event/publisher/PaymentEventPublisher.java
    │   │   ├── security/StudentRoleRequiredAspect.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/db/migration/V1__init_finance_schema.sql
    └── test/java/com/vithey/finance/
```

## Required dependencies

Spring Web, JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, RabbitMQ, Scheduler, MapStruct, Lombok, springdoc.

