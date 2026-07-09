import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
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
      return const CvMetadataModel(
        fileId: 'cv-1',
        fileName: 'Vithey_User_CV.pdf',
        mimeType: 'application/pdf',
        downloadUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      );
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
      return [];
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
      return _mockCvPreviewUrl;
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

  List<ApplicantExperienceEntry> _mockExperienceFor(String userId) {
    if (userId == 'author-1') {
      return const [
        ApplicantExperienceEntry(
          title: 'Principal Strategist',
          organization: 'Global Tech Solutions',
          period: '2021 - Present',
          description:
              'Led cross-functional product initiatives and mentored junior developers on campus hiring programs.',
        ),
        ApplicantExperienceEntry(
          title: 'Senior Product Designer',
          organization: 'FinStream Group',
          period: '2018 - 2021',
          description: 'Designed mobile banking experiences and collaborated with engineering on Flutter prototypes.',
        ),
      ];
    }
    return const [
      ApplicantExperienceEntry(
        title: 'Marketing Intern',
        organization: 'Aeon Mall',
        period: '2024 - Present',
        description: 'Supported campaign analytics and social content for youth-focused retail events.',
      ),
    ];
  }

  List<ApplicantEducationEntry> _mockEducationFor(String userId) {
    if (userId == 'author-1') {
      return const [
        ApplicantEducationEntry(
          degree: 'B.S. Web Development',
          school: 'American University of Phnom Penh',
          period: '2018 - 2022',
        ),
      ];
    }
    return const [
      ApplicantEducationEntry(
        degree: 'B.A. Marketing',
        school: 'American University of Phnom Penh',
        period: '2022 - 2026',
      ),
    ];
  }

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

  static const _mockCvPreviewUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

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

  static final _mockProfiles = <String, UserProfileModel>{
    MockIdentities.mockUserId: UserProfileModel(
      id: MockIdentities.mockUserId,
      fullName: 'Khorn Molika',
      bio: 'Main character of my life is no one else but me.',
      university: 'ACLEDA University of Business',
      major: 'Computer Science',
      graduationYear: 2026,
      telegramLink: 'https://t.me/khornmolika',
      facebookLink: 'https://facebook.com/khornmolika',
      followerCount: 40000,
      followingCount: 3800,
      likeCount: 128000,
      postCount: 31,
      location: 'Kambol, Phnom Penh',
      dateOfBirth: DateTime(2004, 8, 1),
      workplace: 'Fintech Center',
      education: const [
        'Champuvorn High School',
        'ACLEDA University of Business',
        'Institute of Science and Technology Advanced',
      ],
      portfolioUrl: 'https://www.khornmolika.com',
      phone: '098 765 432',
      email: 'khornmolika@gmail.com',
      skills: const [
        ProfileSkill(name: 'Flutter', proficiency: 75),
        ProfileSkill(name: 'HTML', proficiency: 50),
        ProfileSkill(name: 'Springboot', proficiency: 60),
        ProfileSkill(name: 'React', proficiency: 80),
      ],
    ),
    'author-1': UserProfileModel(
      id: 'author-1',
      fullName: 'Heng Liza',
      bio: 'Main character of my life is no one else but me.',
      university: 'American University of Phnom Penh',
      major: 'Web Development',
      graduationYear: 2025,
      followerCount: 8000,
      followingCount: 1000,
      likeCount: 10000,
      postCount: 24,
      location: 'Pur Senchey, Phnom Penh',
      dateOfBirth: DateTime(2005, 9, 1),
      workplace: 'Global Tech Solutions',
      skills: const [
        ProfileSkill(name: 'Flutter', proficiency: 75),
        ProfileSkill(name: 'HTML', proficiency: 50),
        ProfileSkill(name: 'Springboot', proficiency: 60),
        ProfileSkill(name: 'React', proficiency: 80),
      ],
    ),
    'author-2': const UserProfileModel(
      id: 'author-2',
      fullName: 'Molika Khorn',
      bio: 'Content creator sharing student life and career tips.',
      university: 'American University of Phnom Penh',
      major: 'Media Communications',
      graduationYear: 2026,
      followerCount: 512,
      followingCount: 180,
      postCount: 31,
    ),
    'author-3': const UserProfileModel(
      id: 'author-3',
      fullName: 'AUB Career Center',
      bio: 'Official career opportunities and hiring announcements for AUB students.',
      university: 'American University of Phnom Penh',
      major: 'Career Services',
      followerCount: 890,
      followingCount: 12,
      postCount: 18,
    ),
  };

  static final _defaultApplicants = <JobApplicationModel>[
    JobApplicationModel(
      id: 'app-1',
      jobPostId: 'post-3',
      applicantName: 'Heng Liza',
      applicantUserId: 'author-1',
      headline: 'Web Developer',
      location: 'Pur Senchey, Phnom Penh',
      email: 'hengliza81@gmail.com',
      appliedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      cvFileName: 'Heng_Liza_CV.pdf',
      rank: 1,
    ),
    JobApplicationModel(
      id: 'app-2',
      jobPostId: 'post-3',
      applicantName: 'Chan Dara',
      applicantUserId: 'author-2',
      headline: 'Marketing Major',
      location: 'Phnom Penh',
      email: 'chandara@example.com',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      cvFileName: 'Chan_Dara_CV.pdf',
      status: ApplicationStatus.reviewed,
      rank: 2,
    ),
  ];

  static final _mockApplicants = <String, List<JobApplicationModel>>{};
}
