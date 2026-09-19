package com.vithey.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * Best-effort aggregation for CV generate. Failures return empty data so the
 * generate use-case can answer {@code incomplete_profile} instead of 502.
 */
@Component
public class ProfileContentAggregator {

  private static final Logger log = LoggerFactory.getLogger(ProfileContentAggregator.class);

  private final RestTemplate restTemplate;
  private final ObjectMapper objectMapper;
  private final String profileBaseUrl;
  private final String contentBaseUrl;
  private final int maxPosts;

  public ProfileContentAggregator(
      RestTemplateBuilder restTemplateBuilder,
      ObjectMapper objectMapper,
      @Value("${vithey.ai.profile.base-url:http://user-profile-service:8082}") String profileBaseUrl,
      @Value("${vithey.ai.content.base-url:http://content-service:8084}") String contentBaseUrl,
      @Value("${vithey.ai.cv.max-posts:20}") int maxPosts
  ) {
    this.objectMapper = objectMapper;
    this.profileBaseUrl = trimSlash(profileBaseUrl);
    this.contentBaseUrl = trimSlash(contentBaseUrl);
    this.maxPosts = Math.max(1, Math.min(maxPosts, 50));
    this.restTemplate = restTemplateBuilder
        .setConnectTimeout(Duration.ofSeconds(3))
        .setReadTimeout(Duration.ofSeconds(5))
        .build();
  }

  public Map<String, Object> fetchProfile(UUID userId, String authorizationHeader) {
    try {
      ResponseEntity<String> response = restTemplate.exchange(
          profileBaseUrl + "/api/v1/users/" + userId,
          HttpMethod.GET,
          entity(authorizationHeader, userId),
          String.class
      );
      if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
        return Map.of();
      }
      JsonNode data = objectMapper.readTree(response.getBody()).path("data");
      if (data.isMissingNode() || data.isNull()) {
        return Map.of();
      }
      Map<String, Object> profile = new HashMap<>();
      putText(profile, "full_name", data.path("full_name"));
      putText(profile, "email", data.path("email"));
      putText(profile, "phone", data.path("phone"));
      putText(profile, "location", data.path("university"));
      List<String> skills = new ArrayList<>();
      if (data.path("skills").isArray()) {
        data.path("skills").forEach(skill -> {
          String name = skill.path("name").asText(null);
          if (name != null && !name.isBlank()) {
            skills.add(name.trim());
          }
        });
      }
      profile.put("skills", skills);
      List<Map<String, Object>> education = new ArrayList<>();
      if (data.path("education").isArray()) {
        data.path("education").forEach(line -> {
          String text = line.asText(null);
          if (text != null && !text.isBlank()) {
            education.add(Map.of("institution", text.trim(), "degree", "", "period", ""));
          }
        });
      } else {
        String university = data.path("university").asText("");
        String major = data.path("major").asText("");
        if (!university.isBlank() || !major.isBlank()) {
          education.add(Map.of(
              "institution", university,
              "degree", major,
              "period", data.path("graduation_year").asText("")
          ));
        }
      }
      profile.put("education", education);
      return profile;
    } catch (RestClientException | java.io.IOException exception) {
      log.warn("Profile fetch failed for CV generate: {}", exception.toString());
      return Map.of();
    }
  }

  public List<Map<String, Object>> fetchPosts(UUID userId, String authorizationHeader) {
    try {
      String url = contentBaseUrl + "/api/v1/users/" + userId + "/posts?page=1&limit=" + maxPosts;
      ResponseEntity<String> response = restTemplate.exchange(
          url,
          HttpMethod.GET,
          entity(authorizationHeader, userId),
          String.class
      );
      if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
        return List.of();
      }
      JsonNode data = objectMapper.readTree(response.getBody()).path("data");
      if (!data.isArray()) {
        return List.of();
      }
      List<Map<String, Object>> posts = new ArrayList<>();
      data.forEach(post -> {
        String content = post.path("content").asText("");
        if (content == null || content.isBlank()) {
          return;
        }
        String id = post.path("post_id").asText(null);
        if (id == null || id.isBlank()) {
          id = post.path("id").asText(UUID.randomUUID().toString());
        }
        posts.add(Map.of(
            "source_id", id,
            "source_type", "post",
            "content", content.trim()
        ));
      });
      return posts;
    } catch (RestClientException | java.io.IOException exception) {
      log.warn("Posts fetch failed for CV generate: {}", exception.toString());
      return List.of();
    }
  }

  private static HttpEntity<Void> entity(String authorizationHeader, UUID userId) {
    HttpHeaders headers = new HttpHeaders();
    if (authorizationHeader != null && !authorizationHeader.isBlank()) {
      headers.set(HttpHeaders.AUTHORIZATION, authorizationHeader);
    }
    headers.set("X-User-Id", userId.toString());
    return new HttpEntity<>(headers);
  }

  private static void putText(Map<String, Object> target, String key, JsonNode node) {
    if (node != null && !node.isMissingNode() && !node.isNull()) {
      String value = node.asText(null);
      if (value != null && !value.isBlank()) {
        target.put(key, value.trim());
      }
    }
  }

  private static String trimSlash(String url) {
    return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
  }
}
