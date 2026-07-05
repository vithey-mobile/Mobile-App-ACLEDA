package com.vithey.profile.dto.request;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import jakarta.validation.constraints.Size;
import java.util.Map;

public record UpdateSettingsRequest(
    AppLanguage language,
    AppTheme theme,
    Map<String, Object> notifications,
    Map<String, Object> privacy,
    @Size(max = 512) String fcmToken
) {
}
