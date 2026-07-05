package com.vithey.ai.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public record CvSuggestRequest(
    @NotBlank @Size(max = 64) String section,
    @NotBlank @Size(max = 8000) String originalText,
    UUID cvId
) {
}
