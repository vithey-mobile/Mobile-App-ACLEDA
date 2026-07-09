import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/repositories/comment_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_result.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';

class PostDetailController extends GetxController {
  PostDetailController(
    this._postRepository,
    this._commentRepository,
    this._jobApplicationRepository,
  );

  final PostRepository _postRepository;
  final CommentRepository _commentRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final post = Rxn<FeedPost>();
  final comments = <CommentModel>[].obs;
  final isLoading = true.obs;
  final isCommentsLoading = false.obs;
  final isSending = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final mentionQuery = ''.obs;
  final showMentions = false.obs;

  final commentController = TextEditingController();
  final commentFocus = FocusNode();

  String? _postId;
  int _commentPage = 1;
  bool _hasMoreComments = true;

  @override
  void onInit() {
    super.onInit();
    _postId = Get.arguments as String?;
    commentController.addListener(_onCommentChanged);
    loadPost();
  }

  Future<void> loadPost() async {
    if (_postId == null) {
      hasError.value = true;
      errorMessage.value = 'Post not found';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    try {
      final loaded = await _postRepository.fetchPost(_postId!);
      if (loaded == null) {
        hasError.value = true;
        errorMessage.value = 'Post unavailable';
        return;
      }
      post.value = await _normalize(loaded);
      await loadComments(reset: true);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments({bool reset = false}) async {
    if (_postId == null || isCommentsLoading.value) return;
    if (!reset && !_hasMoreComments) return;

    if (reset) {
      _commentPage = 1;
      _hasMoreComments = true;
      comments.clear();
    }

    isCommentsLoading.value = true;
    try {
      final items = await _commentRepository.fetchComments(
        postId: _postId!,
        page: _commentPage,
      );
      if (items.isEmpty) {
        _hasMoreComments = false;
      } else {
        final existing = comments.map((c) => c.id).toSet();
        comments.addAll(items.where((c) => !existing.contains(c.id)));
        _commentPage += 1;
      }
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<FeedPost> _normalize(FeedPost item) async {
    var normalized = item.copyWith(
      userReacted: _postRepository.isReacted(item.id) || item.userReacted,
      isFollowingAuthor: _postRepository.isFollowing(item.author.id) || item.isFollowingAuthor,
    );
    if (normalized.type == PostType.job &&
        !normalized.isOwnPost &&
        normalized.applicationState != JobApplicationState.applied) {
      try {
        final applied = await _jobApplicationRepository.hasUserApplied(normalized.id);
        if (applied) {
          normalized = normalized.copyWith(applicationState: JobApplicationState.applied);
        }
      } catch (_) {}
    }
    return normalized;
  }

  Future<void> toggleLike() async {
    final current = post.value;
    if (current == null) return;

    final reacted = !current.userReacted;
    post.value = current.copyWith(
      userReacted: reacted,
      reactionCount: (current.reactionCount + (reacted ? 1 : -1)).clamp(0, 999999),
    );

    try {
      await _postRepository.toggleReaction(current.id);
    } catch (_) {
      post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update reaction');
    }
  }

  Future<void> toggleFollow() async {
    final current = post.value;
    if (current == null || current.isOwnPost) return;

    final following = !current.isFollowingAuthor;
    post.value = current.copyWith(isFollowingAuthor: following);

    try {
      await _postRepository.setFollow(current.author.id, following);
    } catch (_) {
      post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    }
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || isSending.value || _postId == null) return;

    isSending.value = true;
    showMentions.value = false;

    final temp = CommentModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      postId: _postId!,
      author: Get.find<CurrentUserService>().postAuthor,
      text: text,
      createdAt: DateTime.now(),
      isPending: true,
    );
    comments.insert(0, temp);
    commentController.clear();

    final current = post.value;
    if (current != null) {
      post.value = current.copyWith(commentCount: current.commentCount + 1);
    }

    try {
      final saved = await _commentRepository.createComment(
        postId: _postId!,
        text: text,
        currentUser: Get.find<CurrentUserService>().postAuthor,
      );
      final index = comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) comments[index] = saved;
    } catch (_) {
      final index = comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) {
        comments[index] = temp.copyWith(isPending: false, isFailed: true);
      }
      if (current != null) post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not post comment');
    } finally {
      isSending.value = false;
    }
  }

  void mentionUser(PostAuthor user) {
    final handle = user.fullName.replaceAll(' ', '');
    final text = commentController.text;
    final atIndex = text.lastIndexOf('@');
    if (atIndex >= 0) {
      commentController.text = '${text.substring(0, atIndex)}@$handle ';
    } else {
      commentController.text = '$text@$handle ';
    }
    commentController.selection = TextSelection.collapsed(offset: commentController.text.length);
    showMentions.value = false;
    mentionQuery.value = '';
    commentFocus.requestFocus();
  }

  void applyJob() {
    final current = post.value;
    if (current == null || current.type != PostType.job) return;
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: current.id, jobPreview: current),
    )?.then((result) {
      if (result is ApplyCvResult) {
        post.value = current.copyWith(applicationState: JobApplicationState.applied);
      }
    });
  }

  void _onCommentChanged() {
    final text = commentController.text;
    final match = RegExp(r'@(\w*)$').firstMatch(text);
    if (match != null) {
      mentionQuery.value = match.group(1) ?? '';
      showMentions.value = true;
    } else {
      showMentions.value = false;
      mentionQuery.value = '';
    }
  }

  List<PostAuthor> get filteredMentionUsers =>
      _commentRepository.searchMentionUsers(mentionQuery.value);

  @override
  void onClose() {
    commentController.removeListener(_onCommentChanged);
    commentController.dispose();
    commentFocus.dispose();
    super.onClose();
  }
}
