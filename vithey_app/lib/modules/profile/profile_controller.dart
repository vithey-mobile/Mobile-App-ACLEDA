import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_result.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

enum ProfileTab { about, posters, videos, jobs }

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  ProfileController(this._profileRepository);

  final ProfileRepository _profileRepository;

  late TabController tabController;
  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final selectedTab = ProfileTab.about.obs;

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

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedTab.value = ProfileTab.values[tabController.index];
        _ensureTabLoaded(_typeForTab(tabController.index));
      }
    });

    final args = Get.arguments;
    _userId = args is ProfileArgs ? args.userId : ProfileRepository.currentUserId;
    loadProfile();
  }

  PostType _typeForTab(int index) {
    switch (index) {
      case 1:
        return PostType.poster;
      case 2:
        return PostType.video;
      case 3:
        return PostType.job;
      default:
        return PostType.poster;
    }
  }

  Future<void> loadProfile() async {
    if (_userId == null) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      var loaded = await _profileRepository.getProfile(_userId!);
      loaded = loaded.copyWith(isFollowing: _profileRepository.isFollowing(loaded.id));
      profile.value = loaded;
      _ensureTabLoaded(PostType.poster);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() => loadProfile();

  Future<void> _ensureTabLoaded(PostType type) async {
    if (_userId == null || tabLoaded[type] == true || tabLoading[type]!.value) return;
    tabLoading[type]!.value = true;
    try {
      final result = await _profileRepository.getUserPosts(userId: _userId!, type: type, page: 1);
      tabPosts[type]!.assignAll(result);
      tabLoaded[type] = true;
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load ${_labelForType(type)}');
    } finally {
      tabLoading[type]!.value = false;
    }
  }

  String _labelForType(PostType type) {
    switch (type) {
      case PostType.poster:
        return 'posters';
      case PostType.video:
        return 'videos';
      case PostType.job:
        return 'jobs';
    }
  }

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null || isOwnProfile) return;

    final following = !current.isFollowing;
    profile.value = current.copyWith(
      isFollowing: following,
      followerCount: (current.followerCount + (following ? 1 : -1)).clamp(0, 999999),
    );

    try {
      await _profileRepository.toggleFollow(current.id);
    } catch (_) {
      profile.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    }
  }

  void startMessage() {
    Get.snackbar(AppStrings.appName, 'Chat messaging coming in Step 8');
  }

  void openPreviewOwnCv() => Get.toNamed(AppRoutes.previewOwnCv);

  void openPost(String postId) => Get.toNamed(AppRoutes.postDetail, arguments: postId);

  void openJobApplicants(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.jobApplicants,
      arguments: JobApplicantsArgs(
        jobPostId: jobPost.id,
        jobTitle: jobPost.jobMeta.title,
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
          jobs[index] = jobs[index].copyWith(applicationState: JobApplicationState.applied);
        }
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
