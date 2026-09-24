package com.vithey.content.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.vithey.content.entity.PostType;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Schema(name = "PostResponse")
public record PostResponse(
    @Schema(example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890") UUID postId,
    AuthorSummaryResponse author,
    @Schema(example = "JOB") PostType type,
    @Schema(example = "We are hiring") String content,
    @Schema(example = "http://localhost:19000/vithey/poster.png") String mediaUrl,
    JobMetaResponse jobMeta,
    @Schema(example = "3") long reactionCount,
    @Schema(example = "1") long commentCount,
    @Schema(example = "true") boolean userReacted,
    @JsonProperty("is_following_author") @Schema(example = "false") boolean isFollowingAuthor,
    @Schema(example = "2026-07-28T02:00:00Z") OffsetDateTime createdAt,
    @Schema(example = "2026-07-29T10:00:00Z") OffsetDateTime scheduledAt
) {

  @Schema(name = "JobMetaResponse")
  public record JobMetaResponse(
      @Schema(example = "Flutter Intern") String title,
      @Schema(example = "Build mobile features") String description,
      @Schema(example = "Year 3+ CS") String requirement,
      @Schema(example = "2026-08-01") LocalDate deadline,
      @Schema(example = "30") Integer cvLimit
  ) {
    public JobMetaResponse(String title, String description, String requirement, LocalDate deadline) {
      this(title, description, requirement, deadline, null);
    }
  }
}
