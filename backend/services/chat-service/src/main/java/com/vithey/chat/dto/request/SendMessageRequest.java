package com.vithey.chat.dto.request;

import jakarta.validation.constraints.NotBlank;

public record SendMessageRequest(
    @NotBlank String text
) {
}
