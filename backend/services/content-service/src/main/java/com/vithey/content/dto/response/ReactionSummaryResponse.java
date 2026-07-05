package com.vithey.content.dto.response;

public record ReactionSummaryResponse(
    long reactionCount,
    boolean userReacted
) {
}
