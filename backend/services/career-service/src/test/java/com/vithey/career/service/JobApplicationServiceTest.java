package com.vithey.career.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.career.dto.request.ApplyJobRequest;
import com.vithey.career.dto.request.UpdateApplicationStatusRequest;
import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.entity.ApplicationStatus;
import com.vithey.career.entity.JobApplication;
import com.vithey.career.event.publisher.JobApplicationEventPublisher;
import com.vithey.career.exception.ApiException;
import com.vithey.career.exception.ErrorCode;
import com.vithey.career.repository.JobApplicationRepository;
import com.vithey.career.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

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
        () -> jobApplicationService.apply(applicantId, request, null)
    );

    assertEquals(ErrorCode.CONFLICT, exception.getErrorCode());
    verify(jobApplicationRepository, never()).save(any());
    verify(eventPublisher, never()).publishSubmitted(any());
  }

  @Test
  void apply_returnsExistingApplicationWhenIdempotencyKeyMatches() {
    UUID applicantId = UUID.randomUUID();
    UUID jobPostId = UUID.randomUUID();
    UUID cvFileId = UUID.randomUUID();
    ApplyJobRequest request = new ApplyJobRequest(jobPostId, cvFileId, "Interested");
    JobApplication existing = new JobApplication();
    existing.setId(UUID.randomUUID());
    existing.setJobPostId(jobPostId);
    existing.setApplicantId(applicantId);
    existing.setIdempotencyKey("key-1");

    when(jobApplicationRepository.findByApplicantIdAndIdempotencyKey(applicantId, "key-1"))
        .thenReturn(Optional.of(existing));
    when(responseBuilder.build(existing)).thenReturn(sampleResponse(existing));

    JobApplicationResponse response = jobApplicationService.apply(applicantId, request, "key-1");

    assertEquals(existing.getId(), response.applicationId());
    verify(jobApplicationRepository, never()).save(any());
    verify(upstreamValidationService, never()).requireJobPost(any());
  }

  @Test
  void listApplications_withJobPostId_returnsApplicantOwnApplicationWhenNotPoster() {
    UUID applicantId = UUID.randomUUID();
    UUID jobPostId = UUID.randomUUID();
    JobApplication application = new JobApplication();
    application.setId(UUID.randomUUID());
    application.setJobPostId(jobPostId);
    application.setApplicantId(applicantId);
    application.setCvFileId(UUID.randomUUID());
    application.setStatus(ApplicationStatus.PENDING);
    application.setAppliedAt(OffsetDateTime.now(ZoneOffset.UTC));
    application.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));

    Page<JobApplication> page = new PageImpl<>(List.of(application), PageRequest.of(0, 20), 1);
    when(upstreamValidationService.isJobPoster(jobPostId, applicantId)).thenReturn(false);
    when(jobApplicationRepository.findByJobPostIdAndApplicantIdOrderByAppliedAtDesc(
        eq(jobPostId),
        eq(applicantId),
        any(PageRequest.class)
    )).thenReturn(page);
    when(responseBuilder.build(application)).thenReturn(sampleResponse(application));

    ApiResponseWrapper<List<JobApplicationResponse>> result = jobApplicationService.listApplications(
        applicantId,
        jobPostId,
        1,
        20
    );

    assertEquals(1, result.data().size());
    verify(jobApplicationRepository, never()).findByJobPostIdOrderByAppliedAtDesc(any(), any());
  }

  @Test
  void listApplications_withJobPostId_returnsAllApplicantsForPoster() {
    UUID posterId = UUID.randomUUID();
    UUID jobPostId = UUID.randomUUID();
    JobApplication application = new JobApplication();
    application.setId(UUID.randomUUID());
    application.setJobPostId(jobPostId);

    Page<JobApplication> page = new PageImpl<>(List.of(application), PageRequest.of(0, 20), 1);
    when(upstreamValidationService.isJobPoster(jobPostId, posterId)).thenReturn(true);
    when(jobApplicationRepository.findByJobPostIdOrderByAppliedAtDesc(eq(jobPostId), any(PageRequest.class)))
        .thenReturn(page);
    when(responseBuilder.build(application)).thenReturn(sampleResponse(application));

    ApiResponseWrapper<List<JobApplicationResponse>> result = jobApplicationService.listApplications(
        posterId,
        jobPostId,
        1,
        20
    );

    assertEquals(1, result.data().size());
    verify(jobApplicationRepository, never()).findByJobPostIdAndApplicantIdOrderByAppliedAtDesc(any(), any(), any());
  }

  @Test
  void updateStatus_setsTimelineFieldsAndReviewerNote() {
    UUID posterId = UUID.randomUUID();
    UUID applicationId = UUID.randomUUID();
    JobApplication application = new JobApplication();
    application.setId(applicationId);
    application.setJobPostId(UUID.randomUUID());
    application.setApplicantId(UUID.randomUUID());
    application.setStatus(ApplicationStatus.PENDING);
    application.setAppliedAt(OffsetDateTime.now(ZoneOffset.UTC));
    application.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));

    when(jobApplicationRepository.findById(applicationId)).thenReturn(Optional.of(application));
    when(jobApplicationRepository.save(any(JobApplication.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(responseBuilder.build(application)).thenReturn(sampleResponse(application));

    jobApplicationService.updateStatus(
        applicationId,
        posterId,
        new UpdateApplicationStatusRequest(ApplicationStatus.ACCEPTED, "Welcome aboard")
    );

    ArgumentCaptor<JobApplication> captor = ArgumentCaptor.forClass(JobApplication.class);
    verify(jobApplicationRepository).save(captor.capture());
    JobApplication saved = captor.getValue();
    assertEquals(ApplicationStatus.ACCEPTED, saved.getStatus());
    assertNotNull(saved.getDecidedAt());
    assertEquals("Welcome aboard", saved.getReviewerNote());
  }

  private JobApplicationResponse sampleResponse(JobApplication application) {
    return new JobApplicationResponse(
        application.getId(),
        application.getJobPostId(),
        "Web Developer",
        "Aeon Mall",
        null,
        UUID.randomUUID(),
        "cv.pdf",
        application.getStatus() != null ? application.getStatus() : ApplicationStatus.PENDING,
        null,
        application.getAppliedAt(),
        application.getReviewStartedAt(),
        application.getDecidedAt(),
        application.getReviewerNote()
    );
  }
}
