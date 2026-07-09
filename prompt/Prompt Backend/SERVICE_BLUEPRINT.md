# Vithey Backend — Service Blueprint

> **Use with:** `COMMON_CONTEXT.md` + each `services/<name>/SERVICE_PROMPT.md`  
> **Scope:** Backend REST API only — no Flutter, no admin UI.

## Monorepo layout (`backend/`)

```text
backend/
├── pom.xml                              # parent POM — Spring Boot + Spring Cloud BOM
├── infrastructure/
│   ├── eureka-server/                   # port 8761
│   ├── config-server/                   # port 8888
│   ├── config-repo/                     # Spring Cloud Config (native)
│   ├── scripts/
│   └── docker-compose.yml               # shared infra only
└── services/
    ├── api-gateway/                     # port 8080
    ├── auth-service/                    # port 8081
    ├── user-profile-service/            # port 8082
    ├── file-service/                    # port 8083
    ├── content-service/                 # port 8084
    ├── career-service/                  # port 8085
    ├── finance-service/                 # port 8086
    ├── chat-service/                    # port 8087
    ├── notification-service/            # port 8088
    └── ai-service/                      # port 8089
```

Ports and build order: `_shared/SERVICE_REGISTRY.md`.

## Parent POM (required)

```xml
<!-- backend/pom.xml -->
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>3.3.5</version>
</parent>

<properties>
  <java.version>21</java.version>
  <spring-cloud.version>2023.0.3</spring-cloud.version>
  <mapstruct.version>1.5.5.Final</mapstruct.version>
</properties>

<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-dependencies</artifactId>
      <version>${spring-cloud.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

Each service module: `<parent>` → `backend` parent, `<artifactId>auth-service</artifactId>`.

## Spring Cloud — every domain service

| Starter | Purpose |
|---------|---------|
| `spring-cloud-starter-netflix-eureka-client` | Register with Eureka; discover peers |
| `spring-cloud-starter-config` | Pull config from Config Server |
| `spring-cloud-starter-openfeign` | Declarative HTTP to other services |
| `spring-cloud-starter-loadbalancer` | Client-side LB with Eureka |

**Gateway only:** `spring-cloud-starter-gateway` (not OpenFeign).

**Infrastructure:** Eureka Server + Config Server — no Eureka client on themselves.

### Bootstrap (`src/main/resources/bootstrap.yml`)

```yaml
spring:
  application:
    name: auth-service          # must match Eureka + config-repo file
  cloud:
    config:
      uri: http://localhost:8888
      fail-fast: true
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

Local override in `application-dev.yml` when Config Server is down (optional `spring.config.import=optional:configserver:`).

## Standard domain service — Maven dependencies

```xml
<!-- All domain services (auth, user-profile, content, ...) -->
<dependencies>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-security</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
  <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-netflix-eureka-client</artifactId></dependency>
  <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-config</artifactId></dependency>
  <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-openfeign</artifactId></dependency>
  <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-loadbalancer</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-amqp</artifactId></dependency> <!-- if events -->
  <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId></dependency>
  <dependency><groupId>org.flywaydb</groupId><artifactId>flyway-core</artifactId></dependency>
  <dependency><groupId>org.springdoc</groupId><artifactId>springdoc-openapi-starter-webmvc-ui</artifactId><version>2.6.0</version></dependency>
  <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><optional>true</optional></dependency>
  <dependency><groupId>org.mapstruct</groupId><artifactId>mapstruct</artifactId><version>${mapstruct.version}</version></dependency>
  <!-- test: spring-boot-starter-test, testcontainers postgresql, mockito -->
</dependencies>
```

**Add per service:**
| Service | Extra dependencies |
|---------|-------------------|
| auth-service | `jjwt-api`, `jjwt-impl`, `jjwt-jackson` |
| api-gateway | `spring-cloud-starter-gateway`, `spring-boot-starter-data-redis-reactive` |
| file-service | `io.minio:minio` |
| chat-service | `spring-boot-starter-websocket`, `spring-boot-starter-data-redis` |
| notification-service | `com.google.firebase:firebase-admin` |
| ai-service | **External Python** — integration docs in `services/ai-service/`, not Maven |

## Standard package tree (domain services)

```text
services/<service-name>/
├── pom.xml
├── README.md
├── API.md
├── ARCHITECTURE.md
└── src/
    ├── main/
    │   ├── java/com/vithey/<service>/
    │   │   ├── <Service>Application.java       # @EnableDiscoveryClient @EnableFeignClients
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java         # JWT resource server OR trust X-User-Id from gateway
    │   │   │   ├── OpenApiConfig.java
    │   │   │   ├── RabbitMqConfig.java           # if events
    │   │   │   └── JacksonConfig.java            # snake_case JSON
    │   │   ├── controller/
    │   │   ├── service/
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/
    │   │   │   ├── request/
    │   │   │   └── response/
    │   │   ├── mapper/
    │   │   ├── client/                         # @FeignClient interfaces
    │   │   ├── event/
    │   │   │   ├── publisher/
    │   │   │   ├── listener/
    │   │   │   └── payload/
    │   │   ├── security/
    │   │   │   └── CurrentUserProvider.java    # read X-User-Id / JWT sub
    │   │   ├── exception/
    │   │   │   ├── GlobalExceptionHandler.java
    │   │   │   ├── ApiException.java
    │   │   │   └── ErrorCode.java
    │   │   └── util/
    │   │       ├── ApiResponseWrapper.java     # { data } / { error } helpers
    │   │       └── PageMetaBuilder.java
    │   └── resources/
    │       ├── bootstrap.yml
    │       ├── application.yml                   # local fallbacks
    │       ├── application-dev.yml
    │       ├── application-prod.yml
    │       └── db/migration/
    │           └── V1__init_schema.sql
    └── test/java/com/vithey/<service>/
        ├── service/                              # unit tests
        ├── controller/                           # @WebMvcTest
        └── integration/                          # Testcontainers
```

## Security pattern (domain services behind gateway)

Gateway validates JWT and forwards:
- `X-User-Id` — UUID from JWT `sub`
- `X-User-Roles` — comma-separated roles
- `X-Request-ID` — correlation id

Domain services: `SecurityConfig` permits `/actuator/**`, `/swagger-ui/**`, `/v3/api-docs/**`; all `/api/v1/**` require authenticated user via filter reading `X-User-Id` OR OAuth2 resource server with same JWT secret.

## OpenFeign client pattern

```java
@FeignClient(name = "file-service")
public interface FileServiceClient {
  @GetMapping("/api/v1/files/{fileId}")
  ApiResponse<FileMetadataResponse> getFile(@PathVariable UUID fileId);
}
```

Use Eureka name = `spring.application.name`. Never hard-code host:port.

## RabbitMQ event pattern

**Publish:**
```java
rabbitTemplate.convertAndSend("vithey.events", "post.created", eventPayload);
```

**Listen:**
```java
@RabbitListener(queues = "notification.post.created")
public void onPostCreated(PostCreatedEvent event) { ... }
```

Exchange: `vithey.events` (topic). Queue per consumer: `notification.<routing-key>`.

## API rules (all services)

- Base path: `/api/v1/...`
- JSON `snake_case`; envelope per `COMMON_CONTEXT.md`
- Controllers return `ResponseEntity<ApiResponse<T>>`
- `@Valid` on all request bodies
- Pagination: `page`, `limit`, `sort` query params
- OpenAPI tag per controller; `bearerAuth` security scheme
- **No Flutter code. API only.**

## config-repo keys per service

| Key | Example |
|-----|---------|
| `server.port` | 8081 |
| `spring.datasource.url` | `jdbc:postgresql://localhost:5432/auth_db` |
| `spring.rabbitmq.host` | localhost |
| `vithey.jwt.secret` | shared with gateway (auth issues, gateway validates) |
| `vithey.minio.endpoint` | file-service only |
| `vithey.ai.provider` | ai-service only |

## Build verification (each service)

1. `mvn -pl services/<name> -am clean verify`
2. Start Eureka + Config + infra
3. `mvn spring-boot:run` — registers in Eureka
4. Swagger: `http://localhost:<port>/swagger-ui.html`
5. Hit endpoints via gateway `http://localhost:8080/api/v1/...`
