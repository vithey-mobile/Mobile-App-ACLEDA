# Infrastructure Endpoints

Infrastructure has no business APIs.

## Eureka Server

| Method | URL | Purpose |
| --- | --- | --- |
| `GET` | `http://localhost:8761/actuator/health` | Eureka health |
| `GET` | `http://localhost:8761` | Eureka dashboard |
| `GET` | `http://localhost:8761/eureka/apps` | Registered apps |

## Config Server

| Method | URL | Purpose |
| --- | --- | --- |
| `GET` | `http://localhost:8888/actuator/health` | Config Server health |
| `GET` | `http://localhost:8888/{service}/default` | Merged default config |
| `GET` | `http://localhost:8888/{service}/dev` | Merged dev profile config |

Service config names:

```text
api-gateway
auth-service
user-profile-service
file-service
content-service
career-service
finance-service
chat-service
notification-service
ai-service
```
