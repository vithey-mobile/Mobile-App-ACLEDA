class ProfileArgs {
  const ProfileArgs({required this.userId});

  final String userId;
}

class JobApplicantsArgs {
  const JobApplicantsArgs({required this.jobPostId, this.jobTitle});

  final String jobPostId;
  final String? jobTitle;
}

class ApplicantCvArgs {
  const ApplicantCvArgs({
    required this.applicationId,
    required this.applicantName,
    this.cvFileName,
  });

  final String applicationId;
  final String applicantName;
  final String? cvFileName;
}
