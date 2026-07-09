package com.vithey.profile.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public record UpdateProfileRequest(
    @Size(max = 160) String fullName,
    @Size(max = 2000) String bio,
    @Size(max = 500) String telegramLink,
    @Size(max = 500) String facebookLink,
    @Size(max = 160) String university,
    @Size(max = 160) String major,
    @Min(1900) @Max(2100) Integer graduationYear,
    @Size(max = 160) String location,
    LocalDate dateOfBirth,
    @Size(max = 160) String workplace,
    @Size(max = 500) String portfolioUrl,
    @Size(max = 32) String phone,
    @Email @Size(max = 160) String email,
    @Valid List<SkillRequest> skills,
    List<@Size(max = 160) String> education,
    Map<String, String> fieldVisibility
) {
}
