import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/fixtures/application_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/cv_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';

class ProfileRepository {
  ProfileRepository(
    this._profileService,
    this._postRepository,
    this._jobApplicationRepository,
    this._cvRepository,
    this._currentUser,
    this._flags,
  );

  final ProfileService _profileService;
  final PostRepository _postRepository;
  final JobApplicationRepository _jobApplicationRepository;
  final CvRepository _cvRepository;
  final CurrentUserService _currentUser;
  final FeatureFlags _flags;

  static String get currentUserId {
    if (Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().userId;
    }
    return MockIdentities.mockUserId;
  }

  bool get useMockApi => _flags.useMockApi;

  Future<UserProfileModel> getProfile(String userId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _withFollowState(_mockProfiles[userId] ?? _mockProfiles[_currentUser.userId]!);
    }
    if (userId == currentUserId) {
      return _profileService.getMyProfile();
    }
    return _profileService.getUserProfile(userId);
  }

  Future<List<FeedPost>> getUserPosts({
    required String userId,
    required PostType type,
    required int page,
  }) async {
    final result = await _postRepository.fetchUserPosts(userId: userId, type: type, page: page);
    return result.posts;
  }

  Future<void> toggleFollow(String userId) => _postRepository.setFollow(userId, !_postRepository.isFollowing(userId));

  bool isFollowing(String userId) => _postRepository.isFollowing(userId);

  Future<CvMetadataModel?> getOwnCv() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return CvFixtures.savedCv();
    }
    return _cvRepository.getSavedCv();
  }

  Future<List<JobApplicationModel>> getJobApplicants(String jobPostId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _mockApplicants[jobPostId] ?? _defaultApplicants;
    }
    return _jobApplicationRepository.getApplicantsForJob(jobPostId);
  }

  Future<List<AppliedJobSummary>> getMyAppliedJobs() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return ApplicationFixtures.myAppliedJobs();
    }
    return _jobApplicationRepository.getMyAppliedJobs();
  }

  Future<UserProfileModel> updateProfile({
    String? bio,
    String? location,
    String? workplace,
    String? portfolioUrl,
    String? phone,
    String? email,
    String? university,
    String? major,
    int? graduationYear,
  }) async {
    final fields = <String, dynamic>{
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (workplace != null) 'workplace': workplace,
      if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (university != null) 'university': university,
      if (major != null) 'major': major,
      if (graduationYear != null) 'graduation_year': graduationYear,
    };
    if (fields.isEmpty) {
      return getProfile(currentUserId);
    }
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final current = _mockProfiles[currentUserId]!;
      final updated = current.copyWith(
        bio: bio ?? current.bio,
        location: location ?? current.location,
        workplace: workplace ?? current.workplace,
        portfolioUrl: portfolioUrl ?? current.portfolioUrl,
        phone: phone ?? current.phone,
        email: email ?? current.email,
        university: university ?? current.university,
        major: major ?? current.major,
        graduationYear: graduationYear ?? current.graduationYear,
      );
      _mockProfiles[currentUserId] = updated;
      return updated;
    }
    return _profileService.updateMyProfile(fields);
  }

  Future<String?> getApplicantCvPreviewUrl(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return CvFixtures.previewUrl;
    }
    try {
      final application = await _jobApplicationRepository.getApplicationDetail(applicationId);
      if (application.cvFileName == null) return null;
      return _cvRepository.getApplicantCvDownloadUrl(applicationId);
    } catch (_) {
      return null;
    }
  }

  Future<ApplicantDetailModel> getApplicantDetail(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _buildMockApplicantDetail(applicationId);
    }

    final application = await _jobApplicationRepository.getApplicationDetail(applicationId);
    UserProfileModel? profile;
    final applicantId = application.applicantUserId;
    if (applicantId != null && applicantId.isNotEmpty) {
      try {
        profile = await getProfile(applicantId);
      } catch (_) {}
    }

    return ApplicantDetailModel(
      applicationId: application.applicationId,
      jobPostId: application.jobPostId,
      jobTitle: application.jobTitle,
      applicantUserId: applicantId ?? '',
      applicantName: application.applicantName ?? profile?.fullName ?? 'Applicant',
      headline: application.applicantHeadline ?? profile?.workplace,
      location: application.applicantLocation ?? profile?.location,
      email: application.applicantEmail ?? profile?.email,
      avatarUrl: profile?.avatarUrl,
      status: application.status,
      cvFileName: application.cvFileName,
      experience: _experienceFromProfile(profile),
      education: _educationFromProfile(profile),
    );
  }

  ApplicantDetailModel _buildMockApplicantDetail(String applicationId) {
    final application = _findMockApplication(applicationId);
    final userId = application.applicantUserId ?? 'author-1';
    final profile = _mockProfiles[userId];

    return ApplicantDetailModel(
      applicationId: application.id,
      jobPostId: application.jobPostId,
      jobTitle: application.headline ?? 'Web Developer',
      applicantUserId: userId,
      applicantName: application.applicantName,
      headline: application.headline,
      location: application.location ?? profile?.location,
      email: application.email ?? profile?.email,
      avatarUrl: profile?.avatarUrl,
      status: application.status,
      cvFileName: application.cvFileName,
      experience: _mockExperienceFor(userId),
      education: _mockEducationFor(userId),
    );
  }

  JobApplicationModel _findMockApplication(String applicationId) {
    for (final list in _mockApplicants.values) {
      final match = list.where((a) => a.id == applicationId);
      if (match.isNotEmpty) return match.first;
    }
    return _defaultApplicants.firstWhere(
      (a) => a.id == applicationId,
      orElse: () => _defaultApplicants.first,
    );
  }

  List<ApplicantExperienceEntry> _mockExperienceFor(String userId) =>
      ApplicationFixtures.experienceFor(userId);

  List<ApplicantEducationEntry> _mockEducationFor(String userId) =>
      ApplicationFixtures.educationFor(userId);

  List<ApplicantExperienceEntry> _experienceFromProfile(UserProfileModel? profile) {
    if (profile?.workplace == null) return const [];
    return [
      ApplicantExperienceEntry(
        title: profile!.major ?? 'Professional',
        organization: profile.workplace!,
        period: 'Present',
        description: profile.bio,
      ),
    ];
  }

  List<ApplicantEducationEntry> _educationFromProfile(UserProfileModel? profile) {
    if (profile == null) return const [];
    final school = profile.university;
    if (school == null) return const [];
    return [
      ApplicantEducationEntry(
        degree: profile.major ?? 'Student',
        school: school,
        period: profile.graduationYear?.toString() ?? 'Present',
      ),
    ];
  }

  static final _mockProfiles = Map<String, UserProfileModel>.from(UserFixtures.buildProfiles());

  static final _defaultApplicants = List<JobApplicationModel>.from(ApplicationFixtures.defaultApplicants());

  static final _mockApplicants = Map<String, List<JobApplicationModel>>.from(
    ApplicationFixtures.buildApplicantsByJob(),
  );

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      for (final list in _mockApplicants.values) {
        final index = list.indexWhere((a) => a.id == applicationId);
        if (index >= 0) {
          list[index] = list[index].copyWith(status: status);
          return;
        }
      }
      for (var i = 0; i < _defaultApplicants.length; i++) {
        if (_defaultApplicants[i].id == applicationId) {
          _defaultApplicants[i] = _defaultApplicants[i].copyWith(status: status);
        }
      }
      return;
    }
    await _jobApplicationRepository.updateApplicationStatus(applicationId, status);
  }

  UserProfileModel _withFollowState(UserProfileModel profile) {
    return profile.copyWith(isFollowing: _postRepository.isFollowing(profile.id));
  }
}
