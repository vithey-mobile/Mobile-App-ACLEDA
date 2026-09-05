package com.vithey.career.dto.response;

import java.util.UUID;

public record PostSummaryResponse(
    UUID postId,
    String type,
    AuthorSummaryResponse author
) {

  public record AuthorSummaryResponse(UUID userId) {
  }
}
