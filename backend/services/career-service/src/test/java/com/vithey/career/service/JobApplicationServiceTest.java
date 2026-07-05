package com.vithey.career.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.career.dto.request.ApplyJobRequest;
import com.vithey.career.event.publisher.JobApplicationEventPublisher;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.repository.JobApplicationRepository;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class JobApplicationServiceTest {

  @Mock
  private JobApplicationRepository jobApplicationRepository;

  @Mock
  private UpstreamValidationService upstreamValidationService;

  @Mock
  private JobApplicationResponseBuilder responseBuilder;

  @Mock
  private JobApplicationEventPublisher eventPublisher;

  @InjectMocks
  private JobApplicationService jobApplicationService;

  @Test
  void apply_rejectsDuplicateApplication() {
    UUID applicantId = UUID.randomUUID();
    UUID jobPostId = UUID.randomUUID();
    UUID cvFileId = UUID.randomUUID();
    ApplyJobRequest request = new ApplyJobRequest(jobPostId, cvFileId, "Interested");

    when(jobApplicationRepository.existsByJobPostIdAndApplicantId(jobPostId, applicantId)).thenReturn(true);

    ApiException exception = assertThrows(
        ApiException.class,
        () -> jobApplicationService.apply(applicantId, request)
    );

    assertEquals(ErrorCode.CONFLICT, exception.getErrorCode());
    verify(jobApplicationRepository, never()).save(any());
    verify(eventPublisher, never()).publishSubmitted(any());
  }
}
