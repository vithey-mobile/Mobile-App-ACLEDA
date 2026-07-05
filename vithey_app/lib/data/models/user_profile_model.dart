class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.university,
    this.major,
    this.graduationYear,
    this.telegramLink,
    this.facebookLink,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.isFollowing = false,
  });

  final String id;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String? university;
  final String? major;
  final int? graduationYear;
  final String? telegramLink;
  final String? facebookLink;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final bool isFollowing;

  UserProfileModel copyWith({
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? university,
    String? major,
    int? graduationYear,
    int? followerCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      university: university ?? this.university,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      telegramLink: telegramLink,
      facebookLink: facebookLink,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      graduationYear: json['graduation_year'] as int?,
      telegramLink: json['telegram_link'] as String?,
      facebookLink: json['facebook_link'] as String?,
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }
}

class CvMetadataModel {
  const CvMetadataModel({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    this.downloadUrl,
  });

  final String fileId;
  final String fileName;
  final String mimeType;
  final String? downloadUrl;

  bool get isPdf => mimeType.contains('pdf');
}

enum ApplicationStatus { pending, reviewed, accepted, rejected }

class JobApplicationModel {
  const JobApplicationModel({
    required this.id,
    required this.jobPostId,
    required this.applicantName,
    this.headline,
    this.location,
    required this.appliedAt,
    this.status = ApplicationStatus.pending,
    this.cvFileName,
  });

  final String id;
  final String jobPostId;
  final String applicantName;
  final String? headline;
  final String? location;
  final DateTime appliedAt;
  final ApplicationStatus status;
  final String? cvFileName;

  JobApplicationModel copyWith({ApplicationStatus? status}) {
    return JobApplicationModel(
      id: id,
      jobPostId: jobPostId,
      applicantName: applicantName,
      headline: headline,
      location: location,
      appliedAt: appliedAt,
      status: status ?? this.status,
      cvFileName: cvFileName,
    );
  }
}
