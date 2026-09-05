# Map Service — Folder Structure

Target output:

```text
backend/services/map-service/
├── pom.xml
├── Dockerfile
├── docker-compose.yml              # map-service + map-postgres only
└── src/
    ├── main/
    │   ├── java/com/vithey/map/
    │   │   ├── MapServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RedisConfig.java
    │   │   │   ├── OpenApiConfig.java
    │   │   │   └── GooglePlacesConfig.java
    │   │   ├── controller/
    │   │   │   ├── PlaceSearchController.java
    │   │   │   ├── PlaceDetailController.java
    │   │   │   ├── PlaceFavoriteController.java
    │   │   │   └── PlaceHistoryController.java
    │   │   ├── service/
    │   │   │   ├── NearbySearchService.java
    │   │   │   ├── TextSearchService.java
    │   │   │   ├── PlaceDetailService.java
    │   │   │   ├── AutocompleteService.java
    │   │   │   ├── PlaceFavoriteService.java
    │   │   │   ├── PlaceHistoryService.java
    │   │   │   └── PlaceCacheService.java
    │   │   ├── client/
    │   │   │   └── GooglePlacesClient.java
    │   │   ├── repository/
    │   │   │   ├── PlaceFavoriteRepository.java
    │   │   │   └── PlaceSearchHistoryRepository.java
    │   │   ├── entity/
    │   │   │   ├── PlaceFavorite.java
    │   │   │   └── PlaceSearchHistory.java
    │   │   ├── dto/request/
    │   │   │   ├── NearbySearchRequest.java
    │   │   │   ├── TextSearchRequest.java
    │   │   │   └── SaveFavoriteRequest.java
    │   │   ├── dto/response/
    │   │   │   ├── PlaceCardResponse.java
    │   │   │   ├── PlaceSearchResultResponse.java
    │   │   │   ├── PlaceDetailResponse.java
    │   │   │   └── AutocompleteSuggestionResponse.java
    │   │   ├── mapper/PlaceMapper.java
    │   │   ├── filter/PlaceFilterSpec.java
    │   │   ├── geo/Haversine.java
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/
    │       ├── bootstrap.yml
    │       ├── application-dev.yml
    │       └── db/migration/
    │           └── V1__init_map_schema.sql
    └── test/java/com/vithey/map/
        ├── NearbySearchServiceTest.java
        ├── PlaceFavoriteServiceTest.java
        ├── PlaceCacheServiceTest.java
        └── GooglePlacesClientTest.java
```

## Required dependencies

Spring Web, WebFlux (WebClient), JPA, PostgreSQL, Flyway, Validation, Security, Eureka Client, Config Client, Redis, Resilience4j, MapStruct, Lombok, springdoc, spring-boot-starter-test, Mockito, Testcontainers (optional).

## Config keys (Config Server / env)

| Key | Purpose |
| --- | --- |
| `GOOGLE_PLACES_API_KEY` | Server key for Places API (New) |
| `MAP_DB_URL` / username / password | PostgreSQL |
| `REDIS_HOST` / `REDIS_PORT` | Cache |
| `VITHEY_JWT_SECRET` | Same as other services (prod) |
