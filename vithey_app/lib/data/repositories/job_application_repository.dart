import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_result.dart';

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
  });

  final JobEligibility eligibility;
  final FeedPost? job;
  final String? message;
}

class JobApplicationRepository {
  JobApplicationRepository(this._postRepository, this._applicationService);

  final PostRepository _postRepository;
  final JobApplicationService _applicationService;

  static final _mockAppliedJobs = <String>{};

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  Future<JobEligibilityResult> loadJobEligibility(String jobPostId) async {
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
    if (job.applicationState == JobApplicationState.applied || _mockAppliedJobs.contains(jobPostId)) {
      return JobEligibilityResult(
        eligibility: JobEligibility.alreadyApplied,
        job: job,
        message: 'Application already submitted',
      );
    }
    if (!useMockApi) {
      final applied = await _applicationService.hasApplied(jobPostId);
      if (applied) {
        return JobEligibilityResult(
          eligibility: JobEligibility.alreadyApplied,
          job: job,
          message: 'Application already submitted',
        );
      }
    }
    return JobEligibilityResult(eligibility: JobEligibility.eligible, job: job);
  }

  Future<ApplyCvResult> submitApplication({
    required String jobPostId,
    required String cvFileId,
    String? applicationNote,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _mockAppliedJobs.add(jobPostId);
      return ApplyCvResult(
        jobPostId: jobPostId,
        applicationId: 'app-${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    final response = await _applicationService.createApplication(
      jobPostId: jobPostId,
      cvFileId: cvFileId,
      applicationNote: applicationNote,
    );
    return ApplyCvResult(
      jobPostId: response.jobPostId,
      applicationId: response.applicationId,
    );
  }
}
