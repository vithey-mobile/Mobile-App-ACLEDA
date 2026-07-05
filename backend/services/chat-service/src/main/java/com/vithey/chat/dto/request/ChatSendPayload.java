package com.vithey.chat.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ChatSendPayload(
    @NotNull UUID conversationId,
    @NotBlank String text
) {
}
