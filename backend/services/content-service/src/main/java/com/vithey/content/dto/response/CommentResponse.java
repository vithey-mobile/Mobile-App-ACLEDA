package com.vithey.content.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CommentResponse(
    UUID commentId,
    UUID postId,
    AuthorSummaryResponse author,
    String text,
    OffsetDateTime createdAt
) {
}
