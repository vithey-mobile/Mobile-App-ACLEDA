import 'package:aub_connect_app/core/utils/media_url_resolver.dart';
import 'package:aub_connect_app/data/models/post_author.dart';

enum PostType { poster, video, job }

enum VideoProcessingState { processing, ready, failed }

enum JobLifecycleState { open, closed, expired, full }

enum JobApplicationState { notApplied, applied, checking }

/// Facebook-style post reactions.
enum PostReactionType { like, love, care, haha, wow, sad, angry }

extension PostReactionTypeX on PostReactionType {
  String get emoji => switch (this) {
        PostReactionType.like => '👍',
        PostReactionType.love => '❤️',
        PostReactionType.care => '🤗',
        PostReactionType.haha => '😆',
        PostReactionType.wow => '😮',
        PostReactionType.sad => '😢',
        PostReactionType.angry => '😡',
      };

  String get label => switch (this) {
        PostReactionType.like => 'Like',
        PostReactionType.love => 'Love',
        PostReactionType.care => 'Care',
        PostReactionType.haha => 'Haha',
        PostReactionType.wow => 'Wow',
        PostReactionType.sad => 'Sad',
        PostReactionType.angry => 'Angry',
      };
}

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
    List<String>? mediaUrls,
    this.thumbnailUrl,
    this.durationSeconds = 0,
    this.processingState = VideoProcessingState.ready,
    this.jobMeta = const JobMeta(),
    this.lifecycleState = JobLifecycleState.open,
    this.applicationState = JobApplicationState.notApplied,
    this.applicantCount = 0,
    required this.createdAt,
    this.viewCount = 0,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.userReacted = false,
    this.userReaction,
    this.isFollowingAuthor = false,
    this.currentUserId,
  }) : mediaUrls = List<String>.unmodifiable(
          _normalizeMediaUrls(mediaUrls, mediaUrl),
        );

  final String id;
  final PostType type;
  final PostAuthor author;
  final String content;
  /// Primary / first media URL (backward compatible).
  final String? mediaUrl;
  /// All media URLs for multi-image posts. Empty when there is no media.
  final List<String> mediaUrls;
  final String? thumbnailUrl;
  final int durationSeconds;
  final VideoProcessingState processingState;
  final JobMeta jobMeta;
  final JobLifecycleState lifecycleState;
  final JobApplicationState applicationState;
  final int applicantCount;
  final DateTime createdAt;
  final int viewCount;
  final int reactionCount;
  final int commentCount;
  final int shareCount;
  final bool userReacted;
  final PostReactionType? userReaction;
  final bool isFollowingAuthor;
  final String? currentUserId;

  bool get isOwnPost => currentUserId != null && currentUserId == author.id;

  /// Images/videos to render (never empty when [mediaUrl] is set).
  List<String> get displayMediaUrls => mediaUrls;

  bool get hasMedia => displayMediaUrls.isNotEmpty;

  /// True only for playable reel candidates (video type + non-image media URL).
  bool get isReelVideo {
    if (type != PostType.video) return false;
    final url = (mediaUrl ?? thumbnailUrl)?.trim();
    if (url == null || url.isEmpty) return false;
    return !looksLikeImageUrl(url);
  }

  static bool looksLikeImageUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.heic') ||
        path.endsWith('.bmp');
  }

  static List<String> _normalizeMediaUrls(
    List<String>? mediaUrls,
    String? mediaUrl,
  ) {
    final fromList = (mediaUrls ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (fromList.isNotEmpty) return fromList;
    final single = mediaUrl?.trim();
    if (single != null && single.isNotEmpty) return [single];
    return const [];
  }

  /// Short label for lists / analytics (job title, caption, or type fallback).
  String get displayTitle {
    final jobTitle = jobMeta.title?.trim();
    if (jobTitle != null && jobTitle.isNotEmpty) return jobTitle;
    final text = content.trim();
    if (text.isEmpty) {
      return switch (type) {
        PostType.video => 'Reel',
        PostType.job => 'Job post',
        PostType.poster => 'Poster',
      };
    }
    return text.length > 72 ? '${text.substring(0, 72)}…' : text;
  }

  /// Effective reaction shown in UI (defaults to like when reacted with no type).
  PostReactionType? get activeReaction =>
      userReacted ? (userReaction ?? PostReactionType.like) : null;

  FeedPost copyWith({
    String? content,
    Object? mediaUrl = _unset,
    Object? mediaUrls = _unset,
    Object? thumbnailUrl = _unset,
    int? durationSeconds,
    JobMeta? jobMeta,
    int? viewCount,
    int? reactionCount,
    int? commentCount,
    int? shareCount,
    bool? userReacted,
    Object? userReaction = _unset,
    bool? isFollowingAuthor,
    JobApplicationState? applicationState,
    VideoProcessingState? processingState,
  }) {
    final nextMediaUrl = identical(mediaUrl, _unset)
        ? this.mediaUrl
        : mediaUrl as String?;
    final nextMediaUrls = identical(mediaUrls, _unset)
        ? this.mediaUrls
        : List<String>.from(mediaUrls as List<String>? ?? const []);
    return FeedPost(
      id: id,
      type: type,
      author: author,
      content: content ?? this.content,
      mediaUrl: nextMediaUrl,
      mediaUrls: nextMediaUrls,
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
      viewCount: viewCount ?? this.viewCount,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      userReacted: userReacted ?? this.userReacted,
      userReaction: identical(userReaction, _unset)
          ? this.userReaction
          : userReaction as PostReactionType?,
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

    final singleMedia =
        MediaUrlResolver.resolveUrl(json['media_url'] as String?);
    final rawUrls = json['media_urls'];
    final parsedUrls = <String>[];
    if (rawUrls is List) {
      for (final item in rawUrls) {
        final value = item?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          final resolved = MediaUrlResolver.resolveUrl(value) ?? value;
          parsedUrls.add(resolved);
        }
      }
    }

    final rawThumb = json['thumbnail_url'] as String?;
    final resolvedThumb = MediaUrlResolver.resolveUrl(rawThumb) ?? singleMedia;

    return FeedPost(
      id: json['post_id']?.toString() ?? json['id']?.toString() ?? '',
      type: type,
      author:
          PostAuthor.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      content: json['content'] as String? ?? '',
      mediaUrl: singleMedia ?? (parsedUrls.isNotEmpty ? parsedUrls.first : null),
      mediaUrls: parsedUrls,
      thumbnailUrl: resolvedThumb,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      processingState: videoState,
      jobMeta: JobMeta.fromJson(json['job_meta'] as Map<String, dynamic>?),
      lifecycleState: jobLifecycle,
      applicationState: applicationState,
      applicantCount: json['applicant_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      reactionCount: (json['reaction_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      userReacted: json['user_reacted'] as bool? ?? false,
      userReaction: _parseReaction(json['user_reaction']?.toString()),
      isFollowingAuthor: json['is_following_author'] as bool? ?? false,
      currentUserId: currentUserId,
    );
  }

  static PostReactionType? _parseReaction(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return switch (raw.toLowerCase()) {
      'like' => PostReactionType.like,
      'love' => PostReactionType.love,
      'care' => PostReactionType.care,
      'haha' => PostReactionType.haha,
      'wow' => PostReactionType.wow,
      'sad' => PostReactionType.sad,
      'angry' => PostReactionType.angry,
      _ => null,
    };
  }
}
