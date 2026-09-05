package com.vithey.ai.support;

import com.vithey.ai.entity.AiTopic;
import java.util.Map;

public final class QueryEnricher {

  private static final Map<AiTopic, String> TOPIC_PREFIX = Map.of(
      AiTopic.CV, "CV and resume writing: ",
      AiTopic.JOB, "Job search and career: ",
      AiTopic.INTERVIEW, "Job interview preparation: ",
      AiTopic.STUDENT, "Student career guidance: ",
      AiTopic.FINANCE, "Personal finance for students: "
  );

  private QueryEnricher() {
  }

  public static String enrich(String message, AiTopic topic) {
    if (topic == null) {
      return message;
    }
    return TOPIC_PREFIX.getOrDefault(topic, "") + message;
  }
}
