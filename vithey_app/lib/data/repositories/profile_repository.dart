import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';

class ProfileRepository {
  ProfileRepository(this._profileService, this._postRepository);

  final ProfileService _profileService;
  final PostRepository _postRepository;

  static const currentUserId = 'mock-user';

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  Future<UserProfileModel> getProfile(String userId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _mockProfiles[userId] ?? _mockProfiles[currentUserId]!;
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
    return null;
  }

  Future<List<JobApplicationModel>> getJobApplicants(String jobPostId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _mockApplicants[jobPostId] ?? _defaultApplicants;
    }
    return [];
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
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
  }

  UserProfileModel _withFollowState(UserProfileModel profile) {
    return profile.copyWith(isFollowing: _postRepository.isFollowing(profile.id));
  }

  static final _mockProfiles = <String, UserProfileModel>{
    currentUserId: const UserProfileModel(
      id: currentUserId,
      fullName: 'Vithey User',
      bio: 'AUB student passionate about design, tech, and campus community.',
      university: 'American University of Phnom Penh',
      major: 'Computer Science',
      graduationYear: 2026,
      telegramLink: 'https://t.me/vitheyuser',
      facebookLink: 'https://facebook.com/vitheyuser',
      followerCount: 128,
      followingCount: 96,
      postCount: 12,
    ),
    'author-1': const UserProfileModel(
      id: 'author-1',
      fullName: 'Heng Liza',
      bio: 'Graphic designer and campus event organizer.',
      university: 'American University of Phnom Penh',
      major: 'Graphic Design',
      graduationYear: 2025,
      followerCount: 340,
      followingCount: 210,
      postCount: 24,
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
      applicantName: 'Sok Pisey',
      headline: 'CS Student',
      location: 'Phnom Penh',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      cvFileName: 'Sok_Pisey_CV.pdf',
    ),
    JobApplicationModel(
      id: 'app-2',
      jobPostId: 'post-3',
      applicantName: 'Chan Dara',
      headline: 'Marketing Major',
      location: 'Phnom Penh',
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      cvFileName: 'Chan_Dara_CV.pdf',
      status: ApplicationStatus.reviewed,
    ),
  ];

  static final _mockApplicants = <String, List<JobApplicationModel>>{};
}
