package com.vithey.career.service;

import com.vithey.career.client.FileServiceClient;
import com.vithey.career.client.UserProfileClient;
import com.vithey.career.dto.response.ApplicantSummaryResponse;
import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.entity.JobApplication;
import com.vithey.career.mapper.JobApplicationMapper;
import feign.FeignException;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class JobApplicationResponseBuilder {

  private final JobApplicationMapper jobApplicationMapper;
  private final UserProfileClient userProfileClient;
  private final FileServiceClient fileServiceClient;

  public JobApplicationResponseBuilder(
      JobApplicationMapper jobApplicationMapper,
      UserProfileClient userProfileClient,
      FileServiceClient fileServiceClient
  ) {
    this.jobApplicationMapper = jobApplicationMapper;
    this.userProfileClient = userProfileClient;
    this.fileServiceClient = fileServiceClient;
  }

  public JobApplicationResponse build(JobApplication application) {
    JobApplicationResponse base = jobApplicationMapper.toBaseResponse(application);
    ApplicantSummaryResponse applicant = resolveApplicant(application.getApplicantId());
    String cvFileName = resolveCvFileName(application.getCvFileId());
    return new JobApplicationResponse(
        base.applicationId(),
        base.jobPostId(),
        applicant,
        base.cvFileId(),
        cvFileName,
        base.status(),
        base.coverNote(),
        base.appliedAt()
    );
  }

  private ApplicantSummaryResponse resolveApplicant(UUID applicantId) {
    var response = userProfileClient.getProfile(applicantId);
    if (response.data() == null) {
      return new ApplicantSummaryResponse(applicantId, "Unknown User");
    }
    return new ApplicantSummaryResponse(response.data().userId(), response.data().fullName());
  }

  private String resolveCvFileName(UUID cvFileId) {
    try {
      var response = fileServiceClient.getFile(cvFileId);
      if (response != null && response.data() != null) {
        return response.data().fileName();
      }
    } catch (FeignException exception) {
      return null;
    }
    return null;
  }
}
