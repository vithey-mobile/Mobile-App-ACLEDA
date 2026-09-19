package com.vithey.ai.dto.request;

import jakarta.validation.constraints.Size;

public record CvGenerateRequest(
    @Size(max = 200) String targetRole,
    @Size(max = 8) String language,
    @Size(max = 64) String templateId
) {
}
