package com.vithey.ai.dto.response;

import java.util.List;

public record CvDraftResponse(
    String fullName,
    String summary,
    List<String> skills,
    List<String> education,
    List<String> experience,
    List<String> projects,
    String contact,
    String templateId,
    boolean incompleteProfile,
    String incompleteMessage,
    Integer qualityScore,
    String qualityGrade
) {
}
