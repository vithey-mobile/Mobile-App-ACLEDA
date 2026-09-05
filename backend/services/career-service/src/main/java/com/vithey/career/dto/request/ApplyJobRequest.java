package com.vithey.career.dto.request;

import com.vithey.career.entity.ApplicationStatus;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ApplyJobRequest(
    @NotNull UUID jobPostId,
    @NotNull UUID cvFileId,
    String coverNote
) {
}
