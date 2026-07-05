package com.vithey.content.dto.response;

import com.vithey.content.entity.PostType;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PostResponse(
    UUID postId,
    AuthorSummaryResponse author,
    PostType type,
    String content,
    String mediaUrl,
    JobMetaResponse jobMeta,
    long reactionCount,
    long commentCount,
    boolean userReacted,
    OffsetDateTime createdAt
) {

  public record JobMetaResponse(
      String title,
      String description,
      String requirement,
      LocalDate deadline
  ) {
  }
}
