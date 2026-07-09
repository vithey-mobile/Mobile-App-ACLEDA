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
    this.likeCount = 0,
    this.isFollowing = false,
    this.skills = const [],
    this.location,
    this.dateOfBirth,
    this.workplace,
    this.education = const [],
    this.portfolioUrl,
    this.phone,
    this.email,
    this.isStudentVerified = false,
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
  final int likeCount;
  final bool isFollowing;
  final List<ProfileSkill> skills;
  final String? location;
  final DateTime? dateOfBirth;
  final String? workplace;
  final List<String> education;
  final String? portfolioUrl;
  final String? phone;
  final String? email;
  final bool isStudentVerified;

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
    int? likeCount,
    bool? isFollowing,
    List<ProfileSkill>? skills,
    String? location,
    DateTime? dateOfBirth,
    String? workplace,
    List<String>? education,
    String? portfolioUrl,
    String? phone,
    String? email,
    bool? isStudentVerified,
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
      likeCount: likeCount ?? this.likeCount,
      isFollowing: isFollowing ?? this.isFollowing,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      workplace: workplace ?? this.workplace,
      education: education ?? this.education,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isStudentVerified: isStudentVerified ?? this.isStudentVerified,
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
      likeCount: json['like_count'] as int? ?? json['stats']?['likes'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      location: json['location'] as String?,
    );
  }
}

class ProfileSkill {
  const ProfileSkill({
    required this.name,
    required this.proficiency,
  });

  final String name;
  final int proficiency;

  factory ProfileSkill.fromJson(Map<String, dynamic> json) {
    return ProfileSkill(
      name: json['name'] as String? ?? '',
      proficiency: json['proficiency'] as int? ?? 0,
    );
  }
}

class AppliedJobSummary {
  const AppliedJobSummary({
    required this.id,
    required this.jobPostId,
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.appliedAt,
  });

  final String id;
  final String jobPostId;
  final String jobTitle;
  final String company;
  final ApplicationStatus status;
  final DateTime appliedAt;
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
    this.applicantUserId,
    this.headline,
    this.location,
    this.email,
    required this.appliedAt,
    this.status = ApplicationStatus.pending,
    this.cvFileName,
    this.rank = 1,
  });

  final String id;
  final String jobPostId;
  final String applicantName;
  final String? applicantUserId;
  final String? headline;
  final String? location;
  final String? email;
  final DateTime appliedAt;
  final ApplicationStatus status;
  final String? cvFileName;
  final int rank;

  JobApplicationModel copyWith({ApplicationStatus? status}) {
    return JobApplicationModel(
      id: id,
      jobPostId: jobPostId,
      applicantName: applicantName,
      applicantUserId: applicantUserId,
      headline: headline,
      location: location,
      email: email,
      appliedAt: appliedAt,
      status: status ?? this.status,
      cvFileName: cvFileName,
      rank: rank,
    );
  }
}
