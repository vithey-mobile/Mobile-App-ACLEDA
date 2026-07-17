import 'package:aub_connect_app/data/models/post_author.dart';

enum PostType { poster, video, job }

enum VideoProcessingState { processing, ready, failed }

enum JobLifecycleState { open, closed, expired, full }

enum JobApplicationState { notApplied, applied, checking }

class JobMeta {
  const JobMeta({
    this.title,
    this.description,
    this.requirement,
    this.deadline,
  });

  final String? title;
  final String? description;
  final String? requirement;
  final DateTime? deadline;

  factory JobMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const JobMeta();
    return JobMeta(
      title: json['title'] as String?,
      description: json['description'] as String?,
      requirement: json['requirement'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
    );
  }
}

class FeedPost {
  static const Object _unset = Object();

  FeedPost({
    required this.id,
    required this.type,
    required this.author,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.durationSeconds = 0,
    this.processingState = VideoProcessingState.ready,
    this.jobMeta = const JobMeta(),
    this.lifecycleState = JobLifecycleState.open,
    this.applicationState = JobApplicationState.notApplied,
    this.applicantCount = 0,
    required this.createdAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.userReacted = false,
    this.isFollowingAuthor = false,
    this.currentUserId,
  });

  final String id;
  final PostType type;
  final PostAuthor author;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final VideoProcessingState processingState;
  final JobMeta jobMeta;
  final JobLifecycleState lifecycleState;
  final JobApplicationState applicationState;
  final int applicantCount;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;
  final int shareCount;
  final bool userReacted;
  final bool isFollowingAuthor;
  final String? currentUserId;

  bool get isOwnPost => currentUserId != null && currentUserId == author.id;

  FeedPost copyWith({
    String? content,
    Object? mediaUrl = _unset,
    Object? thumbnailUrl = _unset,
    int? durationSeconds,
    JobMeta? jobMeta,
    int? reactionCount,
    int? commentCount,
    int? shareCount,
    bool? userReacted,
    bool? isFollowingAuthor,
    JobApplicationState? applicationState,
    VideoProcessingState? processingState,
  }) {
    return FeedPost(
      id: id,
      type: type,
      author: author,
      content: content ?? this.content,
      mediaUrl:
          identical(mediaUrl, _unset) ? this.mediaUrl : mediaUrl as String?,
      thumbnailUrl: identical(thumbnailUrl, _unset)
          ? this.thumbnailUrl
          : thumbnailUrl as String?,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      processingState: processingState ?? this.processingState,
      jobMeta: jobMeta ?? this.jobMeta,
      lifecycleState: lifecycleState,
      applicationState: applicationState ?? this.applicationState,
      applicantCount: applicantCount,
      createdAt: createdAt,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      userReacted: userReacted ?? this.userReacted,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      currentUserId: currentUserId,
    );
  }

  static PostType _parseType(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'VIDEO':
        return PostType.video;
      case 'JOB':
        return PostType.job;
      default:
        return PostType.poster;
    }
  }

  factory FeedPost.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    final type = _parseType(json['type'] as String?);
    final processing = json['processing_state'] as String?;
    VideoProcessingState videoState = VideoProcessingState.ready;
    if (processing != null) {
      switch (processing.toUpperCase()) {
        case 'PROCESSING':
          videoState = VideoProcessingState.processing;
          break;
        case 'FAILED':
          videoState = VideoProcessingState.failed;
          break;
      }
    }

    final lifecycle = json['lifecycle_state'] as String?;
    JobLifecycleState jobLifecycle = JobLifecycleState.open;
    if (lifecycle != null) {
      switch (lifecycle.toUpperCase()) {
        case 'CLOSED':
          jobLifecycle = JobLifecycleState.closed;
          break;
        case 'EXPIRED':
          jobLifecycle = JobLifecycleState.expired;
          break;
        case 'FULL':
          jobLifecycle = JobLifecycleState.full;
          break;
      }
    }

    final appState = json['application_state'] as String?;
    JobApplicationState applicationState = JobApplicationState.notApplied;
    if (json['has_applied'] == true || appState?.toUpperCase() == 'APPLIED') {
      applicationState = JobApplicationState.applied;
    }

    return FeedPost(
      id: json['post_id']?.toString() ?? json['id']?.toString() ?? '',
      type: type,
      author:
          PostAuthor.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      content: json['content'] as String? ?? '',
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl:
          json['thumbnail_url'] as String? ?? json['media_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      processingState: videoState,
      jobMeta: JobMeta.fromJson(json['job_meta'] as Map<String, dynamic>?),
      lifecycleState: jobLifecycle,
      applicationState: applicationState,
      applicantCount: json['applicant_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      reactionCount: (json['reaction_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      userReacted: json['user_reacted'] as bool? ?? false,
      isFollowingAuthor: json['is_following_author'] as bool? ?? false,
      currentUserId: currentUserId,
    );
  }
}
