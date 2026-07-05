package com.vithey.content.dto.request;

import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.UUID;

public record CreateCommentRequest(
    @NotBlank String text,
    List<UUID> mentionUserIds
) {
}
