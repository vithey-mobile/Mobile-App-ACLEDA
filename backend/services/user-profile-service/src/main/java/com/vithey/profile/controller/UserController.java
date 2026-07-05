package com.vithey.profile.controller;

import com.vithey.profile.dto.request.UpdateAvatarRequest;
import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.security.CurrentUserProvider;
import com.vithey.profile.service.ProfileService;
import com.vithey.profile.service.UserSearchService;
import com.vithey.profile.util.ApiResponseWrapper;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

  private final ProfileService profileService;
  private final UserSearchService userSearchService;
  private final CurrentUserProvider currentUserProvider;

  public UserController(
      ProfileService profileService,
      UserSearchService userSearchService,
      CurrentUserProvider currentUserProvider
  ) {
    this.profileService = profileService;
    this.userSearchService = userSearchService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping("/search")
  ResponseEntity<ApiResponseWrapper<List<com.vithey.profile.dto.response.UserSearchResultResponse>>> searchUsers(
      @RequestParam String search,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(userSearchService.search(search, page, limit));
  }

  @GetMapping("/me")
  ResponseEntity<ApiResponseWrapper<MeProfileResponse>> getMyProfile() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.getMyProfile(userId)));
  }

  @GetMapping("/{userId}")
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> getPublicProfile(@PathVariable UUID userId) {
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.getPublicProfile(userId)));
  }

  @PatchMapping("/me")
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> updateMyProfile(
      @Valid @RequestBody UpdateProfileRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.updateProfile(userId, request)));
  }

  @PatchMapping("/me/avatar")
  ResponseEntity<ApiResponseWrapper<ProfileResponse>> updateMyAvatar(
      @Valid @RequestBody UpdateAvatarRequest request
  ) {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(profileService.updateAvatar(userId, request)));
  }

}
