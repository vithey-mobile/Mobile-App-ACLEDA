package com.vithey.ai.service;

import com.vithey.ai.entity.AiTopic;

final class TopicStubReplies {

  private TopicStubReplies() {
  }

  static String forTopic(AiTopic topic, String userMessage) {
    AiTopic safe = topic == null ? AiTopic.STUDENT : topic;
    String hint = truncate(userMessage, 120);
    return switch (safe) {
      case CV -> """
          ## CV tips (demo stub)

          Here are quick Vithey demo tips for your question:
          > %s

          1. Lead with a **2–3 line summary** tied to the role you want.
          2. Turn posts/projects into **bullet results** (what you built + tools + outcome).
          3. Keep skills honest — match the job post language.
          4. Use **Auto-Create CV** in the app to draft from your profile and posts.

          _Demo mode: Vithey AI replies are stubs (no GDCE). CV generate uses DeepSeek via ai_core._
          """.formatted(hint);
      case JOB -> """
          ## Job apply tips (demo stub)

          About: _%s_

          - Read the job post skills and mirror the strongest matches on your CV.
          - Pick 2–3 projects that prove those skills.
          - Write a short note: why this role + what you can ship in 30 days.

          _Demo stub — peer chat and career APIs are live; this assistant is not calling an LLM._
          """.formatted(hint);
      case INTERVIEW -> """
          ## Interview prep (demo stub)

          Question focus: _%s_

          Practice out loud:
          1. **Tell me about yourself** (60–90s, role-targeted).
          2. One project story: problem → action → result.
          3. One question for them about the team or stack.

          _Demo stub reply._
          """.formatted(hint);
      case FINANCE -> """
          ## Student finance (demo stub)

          You asked: _%s_

          For live fee/payment data, open the **Finance** screens in Vithey (finance-service).
          This assistant cannot move money — it only gives general study tips in demo mode.

          _Demo stub — no RAG / no GDCE._
          """.formatted(hint);
      case STUDENT -> """
          ## Student help (demo stub)

          You said: _%s_

          Vithey can help with feed, jobs, peer chat, map, and Auto-Create CV.
          Ask a more specific topic (CV / JOB / INTERVIEW / FINANCE) for tailored stub tips.

          _Demo mode: stub replies only._
          """.formatted(hint);
    };
  }

  private static String truncate(String message, int max) {
    if (message == null || message.isBlank()) {
      return "(no message)";
    }
    String normalized = message.strip().replace('\n', ' ');
    if (normalized.length() <= max) {
      return normalized;
    }
    return normalized.substring(0, max - 1).strip() + "…";
  }
}
