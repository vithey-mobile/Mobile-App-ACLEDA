package com.vithey.ai.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.vithey.ai.dto.response.CvDraftResponse;
import org.junit.jupiter.api.Test;

class StandardCvMapperTest {

  private final ObjectMapper mapper = new ObjectMapper();

  @Test
  void mapsStandardCvToFlatDraft() {
    ObjectNode cv = mapper.createObjectNode();
    ObjectNode contact = cv.putObject("contact");
    contact.put("full_name", "Sok Dara");
    contact.put("email", "dara@aub.edu.kh");
    contact.put("phone", "012");
    cv.put("summary", "Student builder");
    ArrayNode skills = cv.putArray("skills");
    ObjectNode group = skills.addObject();
    group.put("category", "Mobile");
    group.putArray("items").add("Flutter").add("Dart");
    ArrayNode education = cv.putArray("education");
    ObjectNode edu = education.addObject();
    edu.put("degree", "BSc");
    edu.put("institution", "RUPP");
    edu.put("period", "2022-2026");
    ArrayNode experience = cv.putArray("experience");
    ObjectNode exp = experience.addObject();
    exp.put("title", "Intern");
    exp.put("organization", "ACLEDA");
    exp.put("period", "2025");
    exp.put("summary", "Built tools");
    ArrayNode projects = cv.putArray("projects");
    ObjectNode project = projects.addObject();
    project.put("name", "Pickup App");
    project.put("summary", "Recycling routes");

    CvDraftResponse draft = StandardCvMapper.toDraft(cv, "classic", 90, "good");

    assertThat(draft.fullName()).isEqualTo("Sok Dara");
    assertThat(draft.summary()).isEqualTo("Student builder");
    assertThat(draft.skills()).anyMatch(s -> s.contains("Flutter"));
    assertThat(draft.education()).anyMatch(s -> s.contains("RUPP"));
    assertThat(draft.experience()).anyMatch(s -> s.contains("ACLEDA"));
    assertThat(draft.projects()).anyMatch(s -> s.contains("Pickup"));
    assertThat(draft.contact()).contains("dara@aub.edu.kh");
    assertThat(draft.qualityScore()).isEqualTo(90);
    assertThat(draft.incompleteProfile()).isFalse();
  }

  @Test
  void incompleteDraftFlagsMessage() {
    CvDraftResponse draft = StandardCvMapper.incomplete("Sok", "Need posts", null);
    assertThat(draft.incompleteProfile()).isTrue();
    assertThat(draft.incompleteMessage()).contains("posts");
  }
}
