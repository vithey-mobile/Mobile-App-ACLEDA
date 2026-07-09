import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_result.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/home/widgets/comment_sheet.dart';
import 'package:aub_connect_app/modules/home/widgets/share_sheet.dart';

class HomeController extends GetxController {
  HomeController(this._postRepository, this._jobApplicationRepository);

  final PostRepository _postRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final posts = <FeedPost>[].obs;
  final isInitialLoading = true.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final activeVideoId = RxnString();
  final currentTab = 0.obs;

  int _page = 1;
  final _mutationPosts = <String>{};
  final _mutationAuthors = <String>{};

  PostAuthor get currentUser => Get.find<CurrentUserService>().postAuthor;

  @override
  void onInit() {
    super.onInit();
    fetchInitialFeed();
    if (Get.isRegistered<NotificationRepository>()) {
      Get.find<NotificationRepository>().onAppResumed();
    }
  }

  Future<void> fetchInitialFeed() async {
    isInitialLoading.value = true;
    hasError.value = false;
    _page = 1;
    try {
      final result = await _postRepository.fetchFeed(page: _page);
      posts.assignAll(await _applyLocalState(result.posts));
      hasMore.value = result.hasMore;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> refreshFeed() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    _page = 1;
    try {
      final result = await _postRepository.fetchFeed(page: _page);
      posts.assignAll(await _applyLocalState(result.posts));
      hasMore.value = result.hasMore;
      hasError.value = false;
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isInitialLoading.value) return;
    isLoadingMore.value = true;
    try {
      _page += 1;
      final result = await _postRepository.fetchFeed(page: _page);
      final existingIds = posts.map((p) => p.id).toSet();
      final newPosts = result.posts.where((p) => !existingIds.contains(p.id)).toList();
      posts.addAll(await _applyLocalState(newPosts));
      hasMore.value = result.hasMore;
    } catch (e) {
      _page -= 1;
      Get.snackbar(AppStrings.appName, 'Could not load more posts');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retryFeed() => fetchInitialFeed();

  Future<List<FeedPost>> _applyLocalState(List<FeedPost> items) async {
    Set<String> appliedJobIds = {};
    if (!_jobApplicationRepository.useMockApi) {
      try {
        appliedJobIds = await _jobApplicationRepository.getAppliedJobPostIds();
      } catch (_) {
        appliedJobIds = {};
      }
    }

    return items.map((post) {
      final reacted = _postRepository.isReacted(post.id) || post.userReacted;
      final following = _postRepository.isFollowing(post.author.id) || post.isFollowingAuthor;
      final applied = post.type == PostType.job &&
          (post.applicationState == JobApplicationState.applied || appliedJobIds.contains(post.id));
      return post.copyWith(
        userReacted: reacted,
        isFollowingAuthor: following,
        applicationState: applied ? JobApplicationState.applied : post.applicationState,
      );
    }).toList();
  }

  void _updatePostsById(String postId, FeedPost Function(FeedPost) transform) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index >= 0) posts[index] = transform(posts[index]);
  }

  void _updatePostsByAuthor(String authorId, FeedPost Function(FeedPost) transform) {
    for (var i = 0; i < posts.length; i++) {
      if (posts[i].author.id == authorId) posts[i] = transform(posts[i]);
    }
  }

  Future<void> toggleReaction(String postId) async {
    if (_mutationPosts.contains(postId)) return;
    _mutationPosts.add(postId);

    FeedPost? previous;
    _updatePostsById(postId, (post) {
      previous = post;
      final reacted = !post.userReacted;
      return post.copyWith(
        userReacted: reacted,
        reactionCount: (post.reactionCount + (reacted ? 1 : -1)).clamp(0, 999999),
      );
    });

    try {
      await _postRepository.toggleReaction(postId);
    } catch (_) {
      if (previous != null) _updatePostsById(postId, (_) => previous!);
      Get.snackbar(AppStrings.appName, 'Could not update reaction');
    } finally {
      _mutationPosts.remove(postId);
    }
  }

  Future<void> toggleFollow(String authorId) async {
    if (_mutationAuthors.contains(authorId)) return;
    _mutationAuthors.add(authorId);

    final wasFollowing = _postRepository.isFollowing(authorId);
    _updatePostsByAuthor(authorId, (post) => post.copyWith(isFollowingAuthor: !wasFollowing));

    try {
      await _postRepository.setFollow(authorId, !wasFollowing);
    } catch (_) {
      _updatePostsByAuthor(authorId, (post) => post.copyWith(isFollowingAuthor: wasFollowing));
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    } finally {
      _mutationAuthors.remove(authorId);
    }
  }

  void openComments(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    Get.bottomSheet(
      CommentSheet(
        post: post,
        onCommentAdded: () {
          _updatePostsById(postId, (p) => p.copyWith(commentCount: p.commentCount + 1));
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openShareSheet(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    Get.bottomSheet(
      ShareSheet(
        post: post,
        onShared: () {
          _updatePostsById(postId, (p) => p.copyWith(shareCount: p.shareCount + 1));
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId)?.then((result) async {
      if (result is FeedPost) {
        final index = posts.indexWhere((p) => p.id == result.id);
        if (index >= 0) {
          final normalized = await _applyLocalState([result]);
          posts[index] = normalized.first;
        }
      }
    });
  }

  void openCreatePost({PostType? type}) {
    Get.toNamed(AppRoutes.createPost, arguments: type)?.then((result) {
      if (result is FeedPost) insertCreatedPost(result);
    });
  }

  void insertCreatedPost(FeedPost post) {
    _applyLocalState([post]).then((normalized) {
      posts.removeWhere((p) => p.id == normalized.first.id);
      posts.insert(0, normalized.first);
    });
  }

  void setActiveVideo(String? postId) => activeVideoId.value = postId;

  void openAuthorProfile(String authorId) {
    Get.toNamed(
      AppRoutes.profile,
      arguments: ProfileArgs(userId: authorId),
    );
  }

  void onTabSelected(int index) {
    currentTab.value = index;
    switch (index) {
      case 1:
        FinanceNavigation.openFinanceEntry();
        currentTab.value = 0;
        break;
      case 2:
        openCreatePost();
        currentTab.value = 0;
        break;
      case 3:
        Get.toNamed(AppRoutes.chat);
        currentTab.value = 0;
        break;
      case 4:
        Get.toNamed(
          AppRoutes.profile,
          arguments: ProfileArgs(userId: ProfileRepository.currentUserId),
        );
        currentTab.value = 0;
        break;
    }
  }

  void openJobApplication(String jobPostId) {
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: jobPostId),
    )?.then((result) {
      if (result is ApplyCvResult) {
        _updatePostsById(
          result.jobPostId,
          (p) => p.copyWith(applicationState: JobApplicationState.applied),
        );
      }
    });
  }
}
