package com.vithey.profile.service;

import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.util.ApiResponseWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class UserSearchService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;

  private final ProfileRepository profileRepository;
  private final ProfileMapper profileMapper;

  public UserSearchService(ProfileRepository profileRepository, ProfileMapper profileMapper) {
    this.profileRepository = profileRepository;
    this.profileMapper = profileMapper;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<java.util.List<UserSearchResultResponse>> search(String search, int page, int limit) {
    String trimmed = search == null ? "" : search.trim();
    if (!StringUtils.hasText(trimmed) || trimmed.length() < 2) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "search must be at least 2 characters");
    }

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);
    Page<UserSearchResultResponse> results = profileRepository.searchByFullName(trimmed, pageable)
        .map(profileMapper::toSearchResult);

    int totalPages = results.getTotalPages();
    return ApiResponseWrapper.paginated(
        results.getContent(),
        new ApiResponseWrapper.Meta(safePage, safeLimit, results.getTotalElements(), totalPages)
    );
  }
}
