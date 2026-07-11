import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/fixtures/comment_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/post_fixtures.dart';
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
  PostRepository(this._postService, this._currentUser, this._flags);

  final PostService _postService;
  final CurrentUserService _currentUser;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockApi;

  final _mockComments = <String, List<CommentModel>>{};
  final _followedAuthors = <String>{};
  final _reactedPosts = <String>{};
  var _mockSeeded = false;

  String get _mockUserId => _currentUser.userId;

  void _ensureMockSeed() {
    if (_mockSeeded) return;
    _mockSeeded = true;
    for (final entry in CommentFixtures.buildComments().entries) {
      _mockComments[entry.key] = List<CommentModel>.from(entry.value);
    }
  }

  Future<FeedPageResult> fetchUserPosts({
    required String userId,
    required PostType type,
    required int page,
    int limit = 10,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _ensureMockSeed();
      final all = PostFixtures.allPosts(
        currentUserId: _mockUserId,
        reactedPosts: _reactedPosts,
        followedAuthors: _followedAuthors,
      );
      List<FeedPost> typed;
      if (userId == _mockUserId) {
        typed = all.where((p) => p.type == type).map((p) {
          return FeedPost(
            id: p.id,
            type: p.type,
            author: PostAuthor(id: _mockUserId, fullName: MockIdentities.mockUserFullName),
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
      _ensureMockSeed();
      if (page > 2) return const FeedPageResult(posts: [], hasMore: false);
      final posts = PostFixtures.feedPage(
        page: page,
        currentUserId: _mockUserId,
        reactedPosts: _reactedPosts,
        followedAuthors: _followedAuthors,
      );
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
      _ensureMockSeed();
      return PostFixtures.findPost(
        postId,
        currentUserId: _mockUserId,
        reactedPosts: _reactedPosts,
        followedAuthors: _followedAuthors,
      );
    }
    return _postService.fetchPost(postId, currentUserId: _mockUserId);
  }

  Future<List<CommentModel>> fetchComments(String postId, {int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _ensureMockSeed();
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
    DateTime? scheduledAt,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final post = FeedPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        author: PostAuthor(id: _mockUserId, fullName: MockIdentities.mockUserFullName),
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
      scheduledAt: scheduledAt,
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
}
