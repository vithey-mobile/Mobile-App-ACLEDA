package com.vithey.profile.dto.request;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.util.Map;

public record UpdateProfileRequest(
    @Size(max = 160) String fullName,
    @Size(max = 2000) String bio,
    @Size(max = 500) String telegramLink,
    @Size(max = 500) String facebookLink,
    @Size(max = 160) String university,
    @Size(max = 160) String major,
    @Min(1900) @Max(2100) Integer graduationYear
) {
}
