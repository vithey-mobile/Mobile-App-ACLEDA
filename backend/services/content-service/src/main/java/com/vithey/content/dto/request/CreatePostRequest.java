package com.vithey.content.dto.request;

import com.vithey.content.entity.PostType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public record CreatePostRequest(
    @NotNull PostType type,
    String content,
    UUID mediaFileId,
    @Valid JobMetaRequest jobMeta
) {

  public record JobMetaRequest(
      String title,
      String description,
      String requirement,
      LocalDate deadline
  ) {
  }
}
