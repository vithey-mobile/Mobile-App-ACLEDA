package com.vithey.ai.client;

import com.vithey.ai.exception.ApiException;
import com.vithey.ai.exception.ErrorCode;
import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Component
public class GeneralRetrievalClient {

  private final RestTemplate restTemplate;
  private final String baseUrl;
  private final int topK;

  public GeneralRetrievalClient(
      RestTemplateBuilder restTemplateBuilder,
      @Value("${vithey.ai.general.base-url}") String baseUrl,
      @Value("${vithey.ai.general.timeout-seconds:90}") long timeoutSeconds,
      @Value("${vithey.ai.general.top-k:10}") int topK
  ) {
    this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    this.topK = topK;
    this.restTemplate = restTemplateBuilder
        .setConnectTimeout(Duration.ofSeconds(timeoutSeconds))
        .setReadTimeout(Duration.ofSeconds(timeoutSeconds))
        .build();
  }

  public String retrieve(String query, String sessionId) {
    GeneralClientDtos.RetrieveRequest request = new GeneralClientDtos.RetrieveRequest(
        query,
        sessionId,
        true,
        topK
    );

    try {
      ResponseEntity<GeneralClientDtos.RetrieveResponse> response = restTemplate.postForEntity(
          baseUrl + "/retrieval/retrieve",
          request,
          GeneralClientDtos.RetrieveResponse.class
      );

      if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
        throw new ApiException(ErrorCode.UPSTREAM_ERROR, "General AI service returned an error");
      }

      return extractReply(response.getBody());
    } catch (RestClientException exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR, "General AI service is unavailable");
    }
  }

  private String extractReply(GeneralClientDtos.RetrieveResponse body) {
    if (body.finalAnswer() != null && !body.finalAnswer().isBlank()) {
      return body.finalAnswer().trim();
    }
    if (body.clarification() != null && !body.clarification().isBlank()) {
      return body.clarification().trim();
    }
    if (body.documents() != null && !body.documents().isEmpty()) {
      String content = body.documents().getFirst().content();
      if (content != null && !content.isBlank()) {
        return content.trim();
      }
    }
    return "Sorry, I could not find an answer right now. Please try again.";
  }
}
