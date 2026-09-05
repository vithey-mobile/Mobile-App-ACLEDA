package com.vithey.profile.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

@Schema(name = "UpdateProfileRequest", example = """
    {
      "full_name": "Jane Doe",
      "bio": "AUB CS student",
      "telegram_link": "https://t.me/jane",
      "facebook_link": "https://facebook.com/jane",
      "university": "AUB",
      "major": "Computer Science",
      "graduation_year": 2026
    }
    """)
public record UpdateProfileRequest(
    @Schema(example = "Jane Doe", maxLength = 160) @Size(max = 160) String fullName,
    @Schema(example = "AUB CS student", maxLength = 2000) @Size(max = 2000) String bio,
    @Schema(example = "https://t.me/jane", maxLength = 500) @Size(max = 500) String telegramLink,
    @Schema(example = "https://facebook.com/jane", maxLength = 500) @Size(max = 500) String facebookLink,
    @Schema(example = "AUB", maxLength = 160) @Size(max = 160) String university,
    @Schema(example = "Computer Science", maxLength = 160) @Size(max = 160) String major,
    @Schema(example = "2026", minimum = "1900", maximum = "2100")
    @Min(1900) @Max(2100) Integer graduationYear
) {
}
