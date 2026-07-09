import 'package:aub_connect_app/data/models/feed_post.dart';

class UserSearchResult {
  const UserSearchResult({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.university,
    this.major,
    this.headline,
    this.presenceLabel = 'last seen recently',
  });

  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? university;
  final String? major;
  final String? headline;
  final String presenceLabel;

  String get subtitle {
    if (headline != null && headline!.trim().isNotEmpty) return headline!;
    if (major != null && university != null) return '$major · $university';
    if (major != null) return major!;
    if (university != null) return university!;
    return presenceLabel;
  }

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      headline: json['headline'] as String?,
    );
  }
}

class PostSearchResult {
  const PostSearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.authorName,
    this.thumbnailUrl,
    this.createdAt,
    this.jobCompany,
    this.jobLocation,
  });

  final String id;
  final PostType type;
  final String title;
  final String authorName;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final String? jobCompany;
  final String? jobLocation;

  factory PostSearchResult.fromFeedPost(FeedPost post) {
    final title = post.type == PostType.job
        ? (post.jobMeta.title ?? post.content)
        : post.content;
    return PostSearchResult(
      id: post.id,
      type: post.type,
      title: title,
      authorName: post.author.fullName,
      thumbnailUrl: post.thumbnailUrl ?? post.mediaUrl,
      createdAt: post.createdAt,
      jobCompany: post.author.fullName,
      jobLocation: post.jobMeta.description,
    );
  }
}

class SearchRecentUser {
  const SearchRecentUser({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.visitedAt,
    this.presenceLabel = 'last seen recently',
  });

  final String userId;
  final String fullName;
  final String? avatarUrl;
  final DateTime visitedAt;
  final String presenceLabel;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'visited_at': visitedAt.toIso8601String(),
        'presence_label': presenceLabel,
      };

  factory SearchRecentUser.fromJson(Map<String, dynamic> json) {
    return SearchRecentUser(
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      visitedAt: DateTime.tryParse(json['visited_at'] as String? ?? '') ?? DateTime.now(),
      presenceLabel: json['presence_label'] as String? ?? 'last seen recently',
    );
  }

  UserSearchResult toSearchResult() => UserSearchResult(
        userId: userId,
        fullName: fullName,
        avatarUrl: avatarUrl,
        presenceLabel: presenceLabel,
      );
}

class SearchResultsBundle {
  const SearchResultsBundle({
    this.people = const [],
    this.posts = const [],
    this.jobs = const [],
    this.videos = const [],
  });

  final List<UserSearchResult> people;
  final List<PostSearchResult> posts;
  final List<PostSearchResult> jobs;
  final List<PostSearchResult> videos;

  bool get isEmpty => people.isEmpty && posts.isEmpty && jobs.isEmpty && videos.isEmpty;
}

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}
