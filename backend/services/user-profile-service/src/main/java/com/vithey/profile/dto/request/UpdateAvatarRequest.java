package com.vithey.profile.dto.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record UpdateAvatarRequest(
    @NotNull UUID avatarFileId
) {
}
