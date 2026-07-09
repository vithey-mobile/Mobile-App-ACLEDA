# Infrastructure — Folder Structure

Target output:

```text
backend/
├── pom.xml
├── config-repo/
│   ├── application.yml
│   ├── eureka-server.yml
│   ├── config-server.yml
│   ├── api-gateway.yml
│   ├── auth-service.yml
│   ├── user-profile-service.yml
│   ├── file-service.yml
│   ├── content-service.yml
│   ├── career-service.yml
│   ├── finance-service.yml
│   ├── chat-service.yml
│   ├── notification-service.yml
│   └── ai-service.yml
├── scripts/
│   └── init-databases.sql
├── eureka-server/
│   ├── pom.xml
│   └── src/main/java/com/vithey/eureka/EurekaServerApplication.java
└── config-server/
    ├── pom.xml
    └── src/main/java/com/vithey/config/ConfigServerApplication.java
```

## Required dependencies

Eureka Server:

- `spring-cloud-starter-netflix-eureka-server`
- `spring-boot-starter-actuator`

Config Server:

- `spring-cloud-config-server`
- `spring-cloud-starter-netflix-eureka-client`
- `spring-boot-starter-actuator`

