import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/services/post_service.dart';

class FeedPageResult {
  const FeedPageResult({required this.posts, required this.hasMore});

  final List<FeedPost> posts;
  final bool hasMore;
}

class PostRepository {
  PostRepository(this._postService);

  final PostService _postService;

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  final _mockComments = <String, List<CommentModel>>{};
  final _followedAuthors = <String>{};
  final _reactedPosts = <String>{};

  static const _mockUserId = 'mock-user';

  Future<FeedPageResult> fetchUserPosts({
    required String userId,
    required PostType type,
    required int page,
    int limit = 10,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final all = <FeedPost>[];
      for (var p = 0; p < 2; p++) {
        all.addAll(_buildMockFeed(page: p));
      }
      List<FeedPost> typed;
      if (userId == _mockUserId) {
        typed = all.where((p) => p.type == type).map((p) {
          return FeedPost(
            id: p.id,
            type: p.type,
            author: const PostAuthor(id: _mockUserId, fullName: 'Vithey User'),
            content: p.content,
            mediaUrl: p.mediaUrl,
            thumbnailUrl: p.thumbnailUrl,
            durationSeconds: p.durationSeconds,
            jobMeta: p.jobMeta,
            applicantCount: p.applicantCount,
            createdAt: p.createdAt,
            reactionCount: p.reactionCount,
            commentCount: p.commentCount,
            shareCount: p.shareCount,
            currentUserId: _mockUserId,
          );
        }).toList();
      } else {
        typed = all.where((p) => p.author.id == userId && p.type == type).toList();
      }
      final start = (page - 1) * limit;
      final slice = typed.skip(start).take(limit).toList();
      return FeedPageResult(posts: slice, hasMore: start + limit < typed.length);
    }

    final posts = await _postService.getUserPosts(
      userId: userId,
      type: type,
      page: page,
      limit: limit,
      currentUserId: _mockUserId,
    );
    return FeedPageResult(posts: posts, hasMore: posts.length >= limit);
  }

  Future<FeedPageResult> fetchFeed({required int page, int limit = 10}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (page > 2) return const FeedPageResult(posts: [], hasMore: false);
      final posts = _buildMockFeed(page: page);
      return FeedPageResult(posts: posts, hasMore: page < 2);
    }

    final posts = await _postService.fetchFeed(page: page, limit: limit, currentUserId: _mockUserId);
    return FeedPageResult(posts: posts, hasMore: posts.length >= limit);
  }

  Future<void> toggleReaction(String postId) async {
    if (useMockApi) {
      if (_reactedPosts.contains(postId)) {
        _reactedPosts.remove(postId);
      } else {
        _reactedPosts.add(postId);
      }
      return;
    }
    await _postService.toggleReaction(postId);
  }

  bool isReacted(String postId) => _reactedPosts.contains(postId);

  Future<void> setFollow(String authorId, bool follow) async {
    if (useMockApi) {
      if (follow) {
        _followedAuthors.add(authorId);
      } else {
        _followedAuthors.remove(authorId);
      }
      return;
    }
    if (follow) {
      await _postService.followUser(authorId);
    } else {
      await _postService.unfollowUser(authorId);
    }
  }

  bool isFollowing(String authorId) => _followedAuthors.contains(authorId);

  Future<FeedPost?> fetchPost(String postId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      for (var page = 0; page < 2; page++) {
        for (final item in _buildMockFeed(page: page)) {
          if (item.id == postId) return item;
        }
      }
      return null;
    }
    return _postService.fetchPost(postId, currentUserId: _mockUserId);
  }

  Future<List<CommentModel>> fetchComments(String postId, {int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return List<CommentModel>.from(_mockComments[postId] ?? []);
    }
    return _postService.fetchComments(postId: postId, page: page, limit: 20);
  }

  Future<CommentModel> createComment({
    required String postId,
    required String text,
    required PostAuthor currentUser,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final comment = CommentModel(
        id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        author: currentUser,
        text: text,
        createdAt: DateTime.now(),
      );
      _mockComments.putIfAbsent(postId, () => []).insert(0, comment);
      return comment;
    }
    return _postService.createComment(postId: postId, text: text);
  }

  Future<FeedPost> createPost({
    required PostType type,
    required String content,
    String? mediaFileId,
    JobMeta? jobMeta,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final post = FeedPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        author: const PostAuthor(id: _mockUserId, fullName: 'Vithey User'),
        content: content,
        mediaUrl: type == PostType.video
            ? 'https://picsum.photos/seed/video/600/340'
            : 'https://picsum.photos/seed/poster/600/400',
        thumbnailUrl: 'https://picsum.photos/seed/thumb/600/340',
        durationSeconds: type == PostType.video ? 125 : 0,
        jobMeta: jobMeta ?? const JobMeta(title: 'New Job Opening'),
        createdAt: DateTime.now(),
        currentUserId: _mockUserId,
      );
      return post;
    }

    return _postService.createPost(
      type: type.name.toUpperCase(),
      content: content,
      mediaFileId: mediaFileId,
      jobMeta: jobMeta != null
          ? {
              if (jobMeta.title != null) 'title': jobMeta.title,
              if (jobMeta.description != null) 'description': jobMeta.description,
            }
          : null,
      currentUserId: _mockUserId,
    );
  }

  Future<void> sharePublicly(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> savePrivately(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  List<FeedPost> _buildMockFeed({required int page}) {
    final base = page * 3;
    return [
      _mockPoster(id: 'post-${base + 1}', authorName: 'Heng Liza', seed: base + 1),
      _mockVideo(id: 'post-${base + 2}', authorName: 'Molika Khorn', seed: base + 2),
      _mockJob(id: 'post-${base + 3}', authorName: 'AUB Career Center', seed: base + 3),
    ];
  }

  FeedPost _mockPoster({required String id, required String authorName, required int seed}) {
    return FeedPost(
      id: id,
      type: PostType.poster,
      author: PostAuthor(id: 'author-$seed', fullName: authorName),
      content: 'Campus event this Friday! Join us for workshops and networking.',
      mediaUrl: 'https://picsum.photos/seed/poster$seed/600/420',
      createdAt: DateTime.now().subtract(Duration(hours: seed)),
      reactionCount: 12 + seed,
      commentCount: 3 + seed,
      shareCount: seed,
      userReacted: _reactedPosts.contains(id),
      isFollowingAuthor: _followedAuthors.contains('author-$seed'),
      currentUserId: _mockUserId,
    );
  }

  FeedPost _mockVideo({required String id, required String authorName, required int seed}) {
    return FeedPost(
      id: id,
      type: PostType.video,
      author: PostAuthor(id: 'author-$seed', fullName: authorName),
      content: 'Highlights from last week\'s student showcase.',
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vthumb$seed/600/340',
      durationSeconds: 95 + seed,
      createdAt: DateTime.now().subtract(Duration(hours: seed * 2)),
      reactionCount: 45 + seed,
      commentCount: 8,
      shareCount: 2,
      userReacted: _reactedPosts.contains(id),
      isFollowingAuthor: _followedAuthors.contains('author-$seed'),
      currentUserId: _mockUserId,
    );
  }

  FeedPost _mockJob({required String id, required String authorName, required int seed}) {
    return FeedPost(
      id: id,
      type: PostType.job,
      author: PostAuthor(id: 'author-$seed', fullName: authorName),
      content: 'Job announcement! We are hiring interns for the summer program.',
      mediaUrl: 'https://picsum.photos/seed/job$seed/600/400',
      jobMeta: const JobMeta(
        title: 'Marketing Intern',
        description: 'Support campus campaigns and social media.',
        deadline: null,
      ),
      applicantCount: 5 + seed,
      createdAt: DateTime.now().subtract(Duration(days: seed)),
      reactionCount: 20,
      commentCount: 4,
      shareCount: 1,
      userReacted: _reactedPosts.contains(id),
      isFollowingAuthor: _followedAuthors.contains('author-$seed'),
      currentUserId: _mockUserId,
    );
  }
}
