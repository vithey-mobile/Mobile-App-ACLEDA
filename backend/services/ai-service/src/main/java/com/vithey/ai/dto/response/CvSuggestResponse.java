package com.vithey.ai.dto.response;

import java.util.UUID;

public record CvSuggestResponse(
    String suggestedText,
    UUID interactionId
) {
}
