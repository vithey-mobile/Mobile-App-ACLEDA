package com.vithey.ai.service;

import com.vithey.ai.client.AiCoreClient;
import com.vithey.ai.client.ProfileContentAggregator;
import com.vithey.ai.dto.request.CvGenerateRequest;
import com.vithey.ai.dto.response.CvDraftResponse;
import com.vithey.ai.exception.ApiException;
import com.vithey.ai.exception.ErrorCode;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.util.ApiResponseWrapper;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Service
public class CvGenerateService {

  private final AiCoreClient aiCoreClient;
  private final ProfileContentAggregator aggregator;
  private final Semaphore generateSemaphore;

  public CvGenerateService(
      AiCoreClient aiCoreClient,
      ProfileContentAggregator aggregator,
      @Value("${vithey.ai.cv.max-concurrent:3}") int maxConcurrent
  ) {
    this.aiCoreClient = aiCoreClient;
    this.aggregator = aggregator;
    this.generateSemaphore = new Semaphore(Math.max(1, maxConcurrent), true);
  }

  public ApiResponseWrapper<CvDraftResponse> generate(CurrentUser user, CvGenerateRequest request) {
    boolean acquired;
    try {
      acquired = generateSemaphore.tryAcquire(1, TimeUnit.SECONDS);
    } catch (InterruptedException exception) {
      Thread.currentThread().interrupt();
      throw new ApiException(ErrorCode.AI_BUSY, "CV generate interrupted");
    }
    if (!acquired) {
      throw new ApiException(ErrorCode.AI_BUSY, "AI is busy generating other CVs — try again shortly");
    }

    try {
      String authorization = currentAuthorization();
      Map<String, Object> profile = aggregator.fetchProfile(user.userId(), authorization);
      List<Map<String, Object>> posts = aggregator.fetchPosts(user.userId(), authorization);

      String fullName = stringVal(profile.get("full_name"));
      if (fullName == null || fullName.isBlank()) {
        fullName = user.email() == null ? "" : user.email();
      }

      String templateId = request == null ? null : request.templateId();
      if (posts.isEmpty()) {
        return ApiResponseWrapper.success(StandardCvMapper.incomplete(
            fullName,
            "Add a few posts about your projects or activities, then try Auto-Create CV again.",
            templateId
        ));
      }

      String targetRole = request == null || request.targetRole() == null ? "" : request.targetRole();
      String language = request == null || request.language() == null ? "en" : request.language();

      try {
        AiCoreClient.GenerateResult result = aiCoreClient.generateCv(posts, profile, targetRole, language);
        CvDraftResponse draft = StandardCvMapper.toDraft(
            result.cv(),
            templateId,
            result.qualityScore(),
            result.qualityGrade()
        );
        if ((draft.fullName() == null || draft.fullName().isBlank()) && fullName != null) {
          draft = new CvDraftResponse(
              fullName,
              draft.summary(),
              draft.skills(),
              draft.education(),
              draft.experience(),
              draft.projects(),
              draft.contact(),
              draft.templateId(),
              draft.incompleteProfile(),
              draft.incompleteMessage(),
              draft.qualityScore(),
              draft.qualityGrade()
          );
        }
        return ApiResponseWrapper.success(draft);
      } catch (ApiException exception) {
        // Keep the app usable when the LLM returns invalid JSON / is briefly down.
        return ApiResponseWrapper.success(StandardCvMapper.incomplete(
            fullName,
            "AI could not finish your CV right now. Try again, or fill sections manually.",
            templateId
        ));
      }
    } finally {
      generateSemaphore.release();
    }
  }

  private static String currentAuthorization() {
    ServletRequestAttributes attributes =
        (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
    if (attributes == null) {
      return null;
    }
    HttpServletRequest request = attributes.getRequest();
    return request.getHeader("Authorization");
  }

  private static String stringVal(Object value) {
    return value == null ? null : String.valueOf(value);
  }
}
