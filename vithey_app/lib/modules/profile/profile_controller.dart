import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_mutation_result.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_result.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/create_post/models/create_post_args.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ProfileController(this._profileRepository, this._jobApplicationRepository);

  final ProfileRepository _profileRepository;
  final JobApplicationRepository _jobApplicationRepository;

  late TabController tabController;
  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final appliedJobs = <AppliedJobSummary>[].obs;
  final appliedJobsLoading = false.obs;
  bool _appliedJobsLoaded = false;

  final tabPosts = <PostType, RxList<FeedPost>>{
    PostType.poster: <FeedPost>[].obs,
    PostType.video: <FeedPost>[].obs,
    PostType.job: <FeedPost>[].obs,
  };

  final tabLoading = <PostType, RxBool>{
    PostType.poster: false.obs,
    PostType.video: false.obs,
    PostType.job: false.obs,
  };

  final tabLoaded = <PostType, bool>{};

  String? _userId;

  bool get isOwnProfile => _userId == ProfileRepository.currentUserId;

  int get tabCount => isOwnProfile ? 5 : 4;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _userId =
        args is ProfileArgs ? args.userId : ProfileRepository.currentUserId;
    tabController = TabController(length: tabCount, vsync: this);
    tabController.addListener(_onTabChanged);
    loadProfile();
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    final index = tabController.index;
    if (isOwnProfile && index == 4) {
      _ensureAppliedJobsLoaded();
      return;
    }
    final type = _typeForTab(index);
    if (type != null) _ensureTabLoaded(type);
  }

  PostType? _typeForTab(int index) {
    return switch (index) {
      1 => PostType.video,
      2 => PostType.poster,
      3 => PostType.job,
      _ => null,
    };
  }

  Future<void> loadProfile() async {
    if (_userId == null) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      var loaded = await _profileRepository.getProfile(_userId!);
      loaded = loaded.copyWith(
          isFollowing: _profileRepository.isFollowing(loaded.id));
      profile.value = loaded;
      _ensureTabLoaded(PostType.video);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() => loadProfile();

  Future<void> _ensureTabLoaded(PostType type) async {
    if (_userId == null || tabLoaded[type] == true || tabLoading[type]!.value) {
      return;
    }
    tabLoading[type]!.value = true;
    try {
      var result = await _profileRepository.getUserPosts(
          userId: _userId!, type: type, page: 1);
      if (type == PostType.job && !isOwnProfile) {
        try {
          final appliedIds =
              await _jobApplicationRepository.getAppliedJobPostIds();
          result = result
              .map(
                (post) => appliedIds.contains(post.id)
                    ? post.copyWith(
                        applicationState: JobApplicationState.applied)
                    : post,
              )
              .toList();
        } catch (_) {}
      }
      tabPosts[type]!.assignAll(result);
      tabLoaded[type] = true;
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load ${_labelForType(type)}');
    } finally {
      tabLoading[type]!.value = false;
    }
  }

  Future<void> _ensureAppliedJobsLoaded() async {
    if (!isOwnProfile || _appliedJobsLoaded || appliedJobsLoading.value) return;
    appliedJobsLoading.value = true;
    try {
      appliedJobs.assignAll(await _profileRepository.getMyAppliedJobs());
      _appliedJobsLoaded = true;
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not load applied jobs');
    } finally {
      appliedJobsLoading.value = false;
    }
  }

  String _labelForType(PostType type) {
    return switch (type) {
      PostType.poster => 'posters',
      PostType.video => 'videos',
      PostType.job => 'jobs',
    };
  }

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null || isOwnProfile) return;

    final following = !current.isFollowing;
    profile.value = current.copyWith(
      isFollowing: following,
      followerCount:
          (current.followerCount + (following ? 1 : -1)).clamp(0, 999999999),
    );

    try {
      await _profileRepository.toggleFollow(current.id);
    } catch (_) {
      profile.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    }
  }

  Future<void> startMessage() async {
    final current = profile.value;
    if (current == null || isOwnProfile) return;
    try {
      final chatRepo = Get.find<ChatRepository>();
      final conversationId =
          await chatRepo.findOrCreateConversation(current.id);
      Get.toNamed(AppRoutes.chatDetail,
          arguments: ChatDetailArgs(conversationId: conversationId));
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open chat');
    }
  }

  void shareProfile() {
    final current = profile.value;
    if (current == null) return;
    Share.share('Check out ${current.fullName} on Vithey App');
  }

  void openEditProfile() => Get.toNamed(AppRoutes.editProfile);

  void openVerifyStudent() => Get.toNamed(AppRoutes.studentVerification);

  void openPreviewOwnCv() => Get.toNamed(AppRoutes.previewOwnCv);

  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId)?.then((result) {
      if (result is PostMutationResult) {
        for (final posts in tabPosts.values) {
          posts.removeWhere((post) => post.id == result.postId);
        }
      } else if (result is FeedPost) {
        _replacePost(result);
      }
    });
  }

  void editPost(FeedPost post) {
    if (!isOwnProfile || !post.isOwnPost) return;
    Get.toNamed(
      AppRoutes.createPost,
      arguments: CreatePostArgs(editingPost: post),
    )?.then((result) {
      if (result is FeedPost) _replacePost(result);
    });
  }

  Future<void> deletePost(BuildContext context, FeedPost post) async {
    if (!isOwnProfile || !post.isOwnPost) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete post?',
      message:
          'This post and its comments will be permanently removed. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep post',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    try {
      await Get.find<PostRepository>().deletePost(post.id);
      tabPosts[post.type]!.removeWhere((item) => item.id == post.id);
      Get.snackbar(AppStrings.appName, 'Post deleted');
    } catch (error) {
      Get.snackbar(AppStrings.appName, error.toString());
    }
  }

  void _replacePost(FeedPost updated) {
    final posts = tabPosts[updated.type]!;
    final index = posts.indexWhere((post) => post.id == updated.id);
    if (index >= 0) posts[index] = updated;
  }

  void openJobApplicants(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.jobApplicants,
      arguments: JobApplicantsArgs(
        jobPostId: jobPost.id,
        jobTitle: jobPost.jobMeta.title ?? 'Job',
      ),
    );
  }

  void applyToJob(String jobPostId) {
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: jobPostId),
    )?.then((result) {
      if (result is ApplyCvResult) {
        final jobs = tabPosts[PostType.job]!;
        final index = jobs.indexWhere((p) => p.id == jobPostId);
        if (index >= 0) {
          jobs[index] = jobs[index]
              .copyWith(applicationState: JobApplicationState.applied);
        }
        _appliedJobsLoaded = false;
        if (tabController.index == 4) {
          _ensureAppliedJobsLoaded();
        }
      }
    });
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
