package com.vithey.ai.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import java.util.Map;

public final class GeneralClientDtos {

  private GeneralClientDtos() {
  }

  public record RetrieveRequest(
      String query,
      @JsonProperty("session_id") String sessionId,
      @JsonProperty("generate_answer") boolean generateAnswer,
      @JsonProperty("top_k") int topK
  ) {
  }

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record RetrieveResponse(
      String status,
      @JsonProperty("final_answer") String finalAnswer,
      String clarification,
      List<DocumentResult> documents,
      @JsonProperty("session_id") String sessionId,
      String error
  ) {
  }

  @JsonIgnoreProperties(ignoreUnknown = true)
  public record DocumentResult(
      String id,
      String content,
      double score,
      String source,
      Map<String, Object> metadata
  ) {
  }
}
