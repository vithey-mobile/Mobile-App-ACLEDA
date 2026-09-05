package com.vithey.gateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.cloud.gateway.filter.ratelimit.RedisRateLimiter;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayRouteConfig {

  @Bean
  RouteLocator vitheyRoutes(
      RouteLocatorBuilder routes,
      RedisRateLimiter redisRateLimiter,
      KeyResolver rateLimitKeyResolver
  ) {
    return routes.routes()
        .route("chat-websocket", route -> route
            .order(-1)
            .path("/ws/chat", "/ws/chat/**")
            .uri("lb://chat-service"))
        .route("auth-service", route -> route
            .order(0)
            .path("/api/v1/auth/**", "/api/v1/students/verify")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://auth-service"))
        .route("career-user-cv", route -> route
            .order(0)
            .path("/api/v1/users/me/cv", "/api/v1/users/me/cv/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://career-service"))
        .route("content-user-social", route -> route
            .order(0)
            .path(
                "/api/v1/users/*/follow",
                "/api/v1/users/*/followers",
                "/api/v1/users/*/following",
                "/api/v1/users/*/posts"
            )
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://content-service"))
        .route("file-service", route -> route
            .order(0)
            .path("/api/v1/files/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://file-service"))
        .route("content-service", route -> route
            .order(0)
            .path("/api/v1/posts/**", "/api/v1/comments/**", "/api/v1/reactions/**", "/api/v1/follows/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://content-service"))
        .route("career-service", route -> route
            .order(0)
            .path("/api/v1/jobs/**", "/api/v1/job-applications/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://career-service"))
        .route("finance-service", route -> route
            .order(0)
            .path("/api/v1/fees/**", "/api/v1/payments/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://finance-service"))
        .route("chat-service", route -> route
            .order(0)
            .path(
                "/api/v1/conversations/**",
                "/api/v1/messages/**",
                "/api/v1/message-requests/**",
                "/api/v1/users/*/report"
            )
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://chat-service"))
        .route("notification-service", route -> route
            .order(0)
            .path("/api/v1/notifications/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://notification-service"))
        .route("ai-service", route -> route
            .order(0)
            .path("/api/v1/ai/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://ai-service"))
        .route("user-profile-service", route -> route
            .order(1)
            .path("/api/v1/users/**")
            .filters(filters -> filters.requestRateLimiter(config -> {
              config.setRateLimiter(redisRateLimiter);
              config.setKeyResolver(rateLimitKeyResolver);
            }))
            .uri("lb://user-profile-service"))
        .build();
  }
}
