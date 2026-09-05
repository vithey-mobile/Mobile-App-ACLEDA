import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/application_fixtures.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/modules/jobs/models/application_detail_model.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';

enum JobEligibility {
  eligible,
  alreadyApplied,
  ownJob,
  closed,
  notFound,
  notJob,
}

class JobEligibilityResult {
  const JobEligibilityResult({
    required this.eligibility,
    this.job,
    this.message,
    this.existingApplicationId,
  });

  final JobEligibility eligibility;
  final FeedPost? job;
  final String? message;
  final String? existingApplicationId;
}

class JobApplicationRepository {
  JobApplicationRepository(
      this._postRepository, this._applicationService, this._flags);

  final PostRepository _postRepository;
  final JobApplicationService _applicationService;
  final FeatureFlags _flags;

  static final _mockAppliedJobs = <String>{};
  static final _mockApplicationDetails = <String, ApplicationDetailModel>{};
  static const _mockSeedVersion = 3;
  static int _loadedMockSeedVersion = 0;

  bool get useMockApi => _flags.useMockApi;

  void _ensureMockSeed() {
    if (_loadedMockSeedVersion == _mockSeedVersion) return;
    _loadedMockSeedVersion = _mockSeedVersion;
    _mockAppliedJobs
      ..clear()
      ..addAll(ApplicationFixtures.seedAppliedJobPostIds());
    _mockApplicationDetails
      ..clear()
      ..addAll(ApplicationFixtures.buildApplicationDetails());
  }

  /// Clears in-memory mock apply state (useful after hot reload).
  static void resetMockApplyState() {
    _loadedMockSeedVersion = 0;
    _mockAppliedJobs.clear();
    _mockApplicationDetails.clear();
  }

  Future<JobEligibilityResult> loadJobEligibility(String jobPostId) async {
    if (useMockApi) _ensureMockSeed();
    final job = await _postRepository.fetchPost(jobPostId);
    if (job == null) {
      return const JobEligibilityResult(
        eligibility: JobEligibility.notFound,
        message: 'This job is no longer available',
      );
    }
    if (job.type != PostType.job) {
      return JobEligibilityResult(
        eligibility: JobEligibility.notJob,
        job: job,
        message: 'This post is not a job listing',
      );
    }
    if (job.isOwnPost) {
      return JobEligibilityResult(
        eligibility: JobEligibility.ownJob,
        job: job,
        message: 'You posted this job. Manage applicants from your profile.',
      );
    }
    if (job.lifecycleState != JobLifecycleState.open) {
      return JobEligibilityResult(
        eligibility: JobEligibility.closed,
        job: job,
        message: 'This job is no longer accepting applications',
      );
    }

    final alreadyAppliedLocally =
        job.applicationState == JobApplicationState.applied ||
            _mockAppliedJobs.contains(jobPostId);
    final appliedOnServer =
        !useMockApi && await _applicationService.hasApplied(jobPostId);

    if (alreadyAppliedLocally || appliedOnServer) {
      final applicationId = await findApplicationIdForJob(jobPostId);
      return JobEligibilityResult(
        eligibility: JobEligibility.alreadyApplied,
        job: job.copyWith(applicationState: JobApplicationState.applied),
        message: 'Application already submitted',
        existingApplicationId: applicationId,
      );
    }

    return JobEligibilityResult(eligibility: JobEligibility.eligible, job: job);
  }

  Future<String?> findApplicationIdForJob(String jobPostId) async {
    if (useMockApi) {
      _ensureMockSeed();
      return _mockApplicationIdForJob(jobPostId);
    }
    try {
      final applications = await _applicationService.listApplications(
          jobPostId: jobPostId, limit: 1);
      if (applications.isEmpty) return null;
      return applications.first.applicationId;
    } on JobApplicationServiceException {
      return null;
    }
  }

  Future<ApplyCvResult> submitApplication({
    required String jobPostId,
    required String cvFileId,
    String? applicationNote,
    String? jobTitle,
    String? organization,
    String? cvFileName,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _mockAppliedJobs.add(jobPostId);
      final applicationId = 'app-${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      _mockApplicationDetails[applicationId] = ApplicationDetailModel(
        applicationId: applicationId,
        jobPostId: jobPostId,
        jobTitle: jobTitle ?? 'Job Position',
        organization: organization,
        status: ApplicationStatus.pending,
        appliedAt: now,
        cvFileName: cvFileName,
      );
      return ApplyCvResult(
        jobPostId: jobPostId,
        applicationId: applicationId,
      );
    }

    try {
      final response = await _applicationService.createApplication(
        jobPostId: jobPostId,
        cvFileId: cvFileId,
        applicationNote: applicationNote,
      );
      return ApplyCvResult(
        jobPostId: response.jobPostId,
        applicationId: response.applicationId,
      );
    } on JobApplicationServiceException catch (error) {
      if (error.isConflict) {
        final existing = await _applicationService.listApplications(
            jobPostId: jobPostId, limit: 1);
        if (existing.isNotEmpty) {
          return ApplyCvResult(
            jobPostId: jobPostId,
            applicationId: existing.first.applicationId,
          );
        }
      }
      rethrow;
    }
  }

  Future<ApplicationDetailModel> getApplicationDetail(
      String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _ensureMockSeed();
      final cached = _mockApplicationDetails[applicationId];
      if (cached != null) return cached;
      return ApplicationDetailModel(
        applicationId: applicationId,
        jobPostId: 'unknown',
        jobTitle: 'Web Developer',
        organization: 'Aeon Mall',
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    final response = await _applicationService.getApplication(applicationId);
    final job = await _postRepository.fetchPost(response.jobPostId);
    return _mapToDetail(response, job: job);
  }

  Future<List<JobApplicationModel>> getApplicantsForJob(
      String jobPostId) async {
    if (useMockApi) {
      _ensureMockSeed();
      return List<JobApplicationModel>.from(
        ApplicationFixtures.buildApplicantsByJob()[jobPostId] ??
            ApplicationFixtures.defaultApplicants(),
      );
    }
    final applications =
        await _applicationService.listApplications(jobPostId: jobPostId);
    return applications.asMap().entries.map((entry) {
      final index = entry.key;
      final app = entry.value;
      return JobApplicationModel(
        id: app.applicationId,
        jobPostId: app.jobPostId,
        applicantName: app.applicantName ?? 'Applicant',
        applicantUserId: app.applicantUserId,
        headline: app.applicantHeadline,
        location: app.applicantLocation,
        email: app.applicantEmail,
        appliedAt: app.appliedAt ?? DateTime.now(),
        status: app.mappedStatus,
        cvFileName: app.cvFileName,
        rank: index + 1,
      );
    }).toList();
  }

  Future<List<AppliedJobSummary>> getMyAppliedJobs() async {
    if (useMockApi) {
      _ensureMockSeed();
      return ApplicationFixtures.myAppliedJobs();
    }
    final applications = await _applicationService.listApplications();
    final summaries = <AppliedJobSummary>[];
    for (final app in applications) {
      final job = await _postRepository.fetchPost(app.jobPostId);
      summaries.add(
        AppliedJobSummary(
          id: app.applicationId,
          jobPostId: app.jobPostId,
          jobTitle: app.jobTitle ?? job?.jobMeta.title ?? job?.content ?? 'Job',
          company: app.organization ?? job?.author.fullName ?? '',
          employmentType: job?.jobMeta.requirement,
          location: job?.content.isNotEmpty == true ? job!.content.split('\n').first : null,
          mediaUrl: job?.mediaUrl,
          status: app.mappedStatus,
          appliedAt: app.appliedAt ?? DateTime.now(),
        ),
      );
    }
    return summaries;
  }

  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status) async {
    if (useMockApi) {
      setMockApplicationStatus(applicationId, status);
      return;
    }
    await _applicationService.updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );
  }

  Future<Set<String>> getAppliedJobPostIds() async {
    if (useMockApi) {
      _ensureMockSeed();
      return Set<String>.from(_mockAppliedJobs);
    }
    final applications = await _applicationService.listApplications();
    return applications.map((app) => app.jobPostId).toSet();
  }

  Future<bool> hasUserApplied(String jobPostId) async {
    if (useMockApi) {
      _ensureMockSeed();
      return _mockAppliedJobs.contains(jobPostId);
    }
    return _applicationService.hasApplied(jobPostId);
  }

  String? _mockApplicationIdForJob(String jobPostId) {
    for (final entry in _mockApplicationDetails.entries) {
      if (entry.value.jobPostId == jobPostId) return entry.key;
    }
    return null;
  }

  ApplicationDetailModel _mapToDetail(JobApplicationResponse response,
      {FeedPost? job}) {
    final status = response.mappedStatus;
    return ApplicationDetailModel(
      applicationId: response.applicationId,
      jobPostId: response.jobPostId,
      jobTitle:
          response.jobTitle ?? job?.jobMeta.title ?? job?.content ?? 'Job',
      organization: response.organization ?? job?.author.fullName,
      status: status,
      appliedAt: response.appliedAt ?? DateTime.now(),
      reviewStartedAt: response.reviewStartedAt ??
          (status == ApplicationStatus.reviewed ? response.appliedAt : null),
      decidedAt: response.decidedAt ??
          (status == ApplicationStatus.accepted ||
                  status == ApplicationStatus.rejected
              ? response.appliedAt
              : null),
      reviewerNote: response.reviewerNote,
      cvFileName: response.cvFileName,
      applicantUserId: response.applicantUserId,
      applicantName: response.applicantName,
      applicantHeadline: response.applicantHeadline,
      applicantLocation: response.applicantLocation,
      applicantEmail: response.applicantEmail,
    );
  }

  /// Demo helper — cycles mock status for testing UI variants.
  void setMockApplicationStatus(
      String applicationId, ApplicationStatus status) {
    _ensureMockSeed();
    final existing = _mockApplicationDetails[applicationId];
    if (existing == null) return;
    final now = DateTime.now();
    _mockApplicationDetails[applicationId] = ApplicationDetailModel(
      applicationId: existing.applicationId,
      jobPostId: existing.jobPostId,
      jobTitle: existing.jobTitle,
      organization: existing.organization,
      status: status,
      appliedAt: existing.appliedAt,
      reviewStartedAt: status != ApplicationStatus.pending
          ? existing.reviewStartedAt ?? now.subtract(const Duration(hours: 6))
          : null,
      decidedAt: status == ApplicationStatus.accepted ||
              status == ApplicationStatus.rejected
          ? now
          : null,
      reviewerNote: status == ApplicationStatus.accepted
          ? 'Thank you for your interest. Please check your email to receive interview time and location.'
          : status == ApplicationStatus.rejected
              ? "Thank you for your interest. I'm so sorry to inform you didn't pass our selection. However, we openly welcome you again next time."
              : null,
      cvFileName: existing.cvFileName,
    );
  }
}
