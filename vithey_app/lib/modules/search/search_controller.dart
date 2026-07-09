import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/modules/search/utils/search_api_error.dart';

class SearchController extends GetxController {
  SearchController(this._repository);

  final SearchRepository _repository;

  final searchController = TextEditingController();
  final focusNode = FocusNode();

  final query = ''.obs;
  final recentUsers = <SearchRecentUser>[].obs;
  final isLoadingRecents = true.obs;
  final isSearching = false.obs;
  final searchError = RxnString();
  final people = <UserSearchResult>[].obs;
  final posts = <PostSearchResult>[].obs;
  final jobs = <PostSearchResult>[].obs;
  final videos = <PostSearchResult>[].obs;

  Timer? _debounce;
  int _searchGeneration = 0;
  SearchMode mode = SearchMode.browse;

  bool get pickUserForChat => mode == SearchMode.pickUserForChat;

  bool get showResults => query.value.trim().length >= 2;
  bool get showRecent => !showResults;
  bool get hasResults =>
      people.isNotEmpty || posts.isNotEmpty || jobs.isNotEmpty || videos.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadRecents();
    final args = SearchArgs.from(Get.arguments);
    mode = args?.mode ?? SearchMode.browse;
    if (args?.initialQuery != null && args!.initialQuery!.isNotEmpty) {
      searchController.text = args.initialQuery!;
      query.value = args.initialQuery!;
      _scheduleSearch(args.initialQuery!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!focusNode.hasFocus) focusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> _loadRecents() async {
    isLoadingRecents.value = true;
    try {
      await _repository.ensureDefaultRecents();
      recentUsers.assignAll(await _repository.loadRecents());
    } finally {
      isLoadingRecents.value = false;
    }
  }

  void onQueryChanged(String value) {
    query.value = value;
    searchError.value = null;
    _debounce?.cancel();

    if (value.trim().length < 2) {
      people.clear();
      posts.clear();
      jobs.clear();
      videos.clear();
      isSearching.value = false;
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(value.trim()));
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () => _runSearch(value.trim()));
  }

  Future<void> _runSearch(String q) async {
    final generation = ++_searchGeneration;
    isSearching.value = true;
    searchError.value = null;
    try {
      final bundle = await _repository.searchAll(q);
      if (generation != _searchGeneration) return;
      people.assignAll(bundle.people);
      posts.assignAll(bundle.posts);
      jobs.assignAll(bundle.jobs);
      videos.assignAll(bundle.videos);
    } catch (e) {
      if (generation != _searchGeneration) return;
      searchError.value = searchApiErrorMessage(e);
    } finally {
      if (generation == _searchGeneration) {
        isSearching.value = false;
      }
    }
  }

  void clearQuery() {
    searchController.clear();
    onQueryChanged('');
    focusNode.requestFocus();
  }

  Future<void> confirmClearRecents() async {
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Clear recent searches?',
      message: "This won't affect your account history.",
      confirmLabel: 'Clear',
    );
    if (confirmed != true) return;
    await _repository.clearAllRecents();
    recentUsers.clear();
  }

  Future<void> openRecentUser(SearchRecentUser user) async {
    if (pickUserForChat) {
      await _startChatWithUser(user.userId, user.fullName);
      return;
    }
    await _repository.addRecentUser(user.toSearchResult());
    await _loadRecents();
    Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(userId: user.userId));
  }

  Future<void> removeRecentUser(SearchRecentUser user) async {
    await _repository.removeRecentUser(user.userId);
    recentUsers.removeWhere((u) => u.userId == user.userId);
  }

  Future<void> openPerson(UserSearchResult user) async {
    if (pickUserForChat) {
      await messagePerson(user);
      return;
    }
    await _repository.addRecentUser(user);
    await _loadRecents();
    Get.toNamed(AppRoutes.profile, arguments: ProfileArgs(userId: user.userId));
  }

  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId);
  }

  Future<void> messagePerson(UserSearchResult user) async {
    try {
      await _startChatWithUser(user.userId, user.fullName);
      if (!pickUserForChat) {
        await _repository.addRecentUser(user);
        await _loadRecents();
      }
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open chat');
    }
  }

  Future<void> _startChatWithUser(String userId, String fullName) async {
    final chatRepo = Get.find<ChatRepository>();
    final conversationId = await chatRepo.findOrCreateConversation(userId);
    if (pickUserForChat) {
      Get.until((route) => route.settings.name == AppRoutes.chat);
      Get.toNamed(AppRoutes.chatDetail, arguments: ChatDetailArgs(conversationId: conversationId));
      return;
    }
    Get.toNamed(AppRoutes.chatDetail, arguments: ChatDetailArgs(conversationId: conversationId));
  }

  void openSeeAll(SearchSeeAllCategory category) {
    if (pickUserForChat && category != SearchSeeAllCategory.people) return;
    Get.toNamed(
      AppRoutes.searchSeeAll,
      arguments: SearchSeeAllArgs(category: category, query: query.value.trim()),
    );
  }

  void retrySearch() => _runSearch(query.value.trim());
}
