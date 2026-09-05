package com.vithey.notification.event.payload;

import java.util.UUID;

public record AiResponseReadyEvent(
    UUID threadId,
    UUID userId
) {
}
