package com.vithey.ai.service;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.support.QueryEnricher;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Demo Profile M defaults to {@code stub} (no GDCE). Use {@code general} only
 * when {@code GENERAL_SERVICE_URL} points at a real retrieval host.
 */
@Service
public class ChatReplyService {

  private final GeneralRetrievalClient generalRetrievalClient;
  private final String mode;

  public ChatReplyService(
      GeneralRetrievalClient generalRetrievalClient,
      @Value("${vithey.ai.chat.mode:stub}") String mode
  ) {
    this.generalRetrievalClient = generalRetrievalClient;
    this.mode = mode == null ? "stub" : mode.trim();
  }

  public boolean isStubMode() {
    return !"general".equalsIgnoreCase(mode);
  }

  public String reply(String userMessage, AiTopic topic, String sessionId) {
    if (isStubMode()) {
      return TopicStubReplies.forTopic(topic, userMessage);
    }
    String query = QueryEnricher.enrich(userMessage, topic);
    return generalRetrievalClient.retrieve(query, sessionId);
  }
}
