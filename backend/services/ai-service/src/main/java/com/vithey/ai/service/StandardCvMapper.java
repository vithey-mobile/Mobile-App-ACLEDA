package com.vithey.ai.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.vithey.ai.dto.response.CvDraftResponse;
import java.util.ArrayList;
import java.util.List;

final class StandardCvMapper {

  private StandardCvMapper() {
  }

  static CvDraftResponse toDraft(JsonNode cv, String templateId, Integer qualityScore, String qualityGrade) {
    JsonNode contact = cv.path("contact");
    String fullName = text(contact.path("full_name"));
    List<String> contactParts = new ArrayList<>();
    addIfPresent(contactParts, text(contact.path("email")));
    addIfPresent(contactParts, text(contact.path("phone")));
    addIfPresent(contactParts, text(contact.path("linkedin")));
    addIfPresent(contactParts, text(contact.path("github")));
    addIfPresent(contactParts, text(contact.path("website")));
    String contactLine = String.join(" | ", contactParts);

    List<String> skills = new ArrayList<>();
    cv.path("skills").forEach(group -> {
      String category = text(group.path("category"));
      List<String> items = new ArrayList<>();
      group.path("items").forEach(item -> {
        String value = item.asText(null);
        if (value != null && !value.isBlank()) {
          items.add(value.trim());
        }
      });
      if (!items.isEmpty()) {
        if (category != null && !category.isBlank()) {
          skills.add(category + ": " + String.join(", ", items));
        } else {
          skills.addAll(items);
        }
      }
    });

    List<String> education = new ArrayList<>();
    cv.path("education").forEach(item -> education.add(joinNonBlank(
        text(item.path("degree")),
        text(item.path("institution")),
        text(item.path("period"))
    )));

    List<String> experience = new ArrayList<>();
    cv.path("experience").forEach(item -> experience.add(joinNonBlank(
        text(item.path("title")),
        text(item.path("organization")),
        text(item.path("period")),
        text(item.path("summary"))
    )));

    List<String> projects = new ArrayList<>();
    cv.path("projects").forEach(item -> projects.add(joinNonBlank(
        text(item.path("name")),
        text(item.path("summary")),
        text(item.path("role"))
    )));

    String summary = text(cv.path("summary"));
    return new CvDraftResponse(
        fullName == null ? "" : fullName,
        summary == null ? "" : summary,
        skills,
        education.stream().filter(s -> !s.isBlank()).toList(),
        experience.stream().filter(s -> !s.isBlank()).toList(),
        projects.stream().filter(s -> !s.isBlank()).toList(),
        contactLine,
        templateId,
        false,
        null,
        qualityScore,
        qualityGrade
    );
  }

  static CvDraftResponse incomplete(String fullName, String message, String templateId) {
    return new CvDraftResponse(
        fullName == null ? "" : fullName,
        "",
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        "",
        templateId,
        true,
        message,
        null,
        null
    );
  }

  private static void addIfPresent(List<String> target, String value) {
    if (value != null && !value.isBlank()) {
      target.add(value.trim());
    }
  }

  private static String text(JsonNode node) {
    if (node == null || node.isMissingNode() || node.isNull()) {
      return null;
    }
    String value = node.asText(null);
    return value == null || value.isBlank() ? null : value.trim();
  }

  private static String joinNonBlank(String... parts) {
    List<String> values = new ArrayList<>();
    for (String part : parts) {
      if (part != null && !part.isBlank()) {
        values.add(part.trim());
      }
    }
    return String.join(" — ", values);
  }
}
