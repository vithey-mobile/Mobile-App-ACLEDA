package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record PostSharedEvent(
    UUID shareId,
    UUID postId,
    UUID originalAuthorId,
    UUID actorId,
    OffsetDateTime createdAt
) {
}
