package com.vithey.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vithey.ai.exception.ApiException;
import com.vithey.ai.exception.ErrorCode;
import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Component
public class AiCoreClient {

  private final RestTemplate restTemplate;
  private final ObjectMapper objectMapper;
  private final String baseUrl;

  public AiCoreClient(
      RestTemplateBuilder restTemplateBuilder,
      ObjectMapper objectMapper,
      @Value("${vithey.ai.core.base-url:http://localhost:8100}") String baseUrl,
      @Value("${vithey.ai.core.timeout-seconds:60}") long timeoutSeconds
  ) {
    this.objectMapper = objectMapper;
    this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    this.restTemplate = restTemplateBuilder
        .setConnectTimeout(Duration.ofSeconds(Math.min(timeoutSeconds, 10)))
        .setReadTimeout(Duration.ofSeconds(timeoutSeconds))
        .build();
  }

  public GenerateResult generateCv(
      List<Map<String, Object>> posts,
      Map<String, Object> profile,
      String targetRole,
      String language
  ) {
    Map<String, Object> body = new HashMap<>();
    body.put("posts", posts);
    if (profile != null && !profile.isEmpty()) {
      body.put("profile", profile);
    }
    body.put("target_role", targetRole == null ? "" : targetRole);
    body.put("language", language == null || language.isBlank() ? "en" : language);
    body.put("on_error", "skip");

    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);

    try {
      ResponseEntity<String> response = restTemplate.postForEntity(
          baseUrl + "/api/v1/cv/generate",
          new HttpEntity<>(body, headers),
          String.class
      );
      if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
        throw new ApiException(ErrorCode.AI_CORE_UNAVAILABLE, "ai_core returned an error");
      }
      return parse(response.getBody());
    } catch (ApiException exception) {
      throw exception;
    } catch (RestClientException exception) {
      throw new ApiException(ErrorCode.AI_CORE_UNAVAILABLE, "ai_core is unavailable");
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR, "Failed to parse ai_core response");
    }
  }

  private GenerateResult parse(String json) throws Exception {
    JsonNode root = objectMapper.readTree(json);
    if (root.path("success").isBoolean() && !root.path("success").asBoolean()) {
      String message = root.path("error").path("message").asText("ai_core error");
      throw new ApiException(ErrorCode.UPSTREAM_ERROR, message);
    }
    JsonNode data = root.path("data");
    JsonNode cv = data.path("cv");
    JsonNode quality = data.path("quality");
    Integer score = quality.path("score").isMissingNode() ? null : quality.path("score").asInt();
    String grade = quality.path("grade").isMissingNode() ? null : quality.path("grade").asText(null);
    return new GenerateResult(cv, score, grade);
  }

  public record GenerateResult(JsonNode cv, Integer qualityScore, String qualityGrade) {
  }
}
