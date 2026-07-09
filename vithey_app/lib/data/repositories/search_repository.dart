import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/local/search_recent_store.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/services/post_search_service.dart';
import 'package:aub_connect_app/data/services/user_search_service.dart';

class SearchRepository {
  SearchRepository(
    this._userSearchService,
    this._postSearchService,
    this._recentStore,
    this._flags,
  );

  final UserSearchService _userSearchService;
  final PostSearchService _postSearchService;
  final SearchRecentStore _recentStore;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockSearch;

  static const previewLimit = 3;

  Future<List<SearchRecentUser>> loadRecents() => _recentStore.getRecentUsers();

  Future<void> ensureDefaultRecents() {
    if (!useMockApi) return Future.value();
    return _recentStore.seedDefaultsIfEmpty(_defaultRecents);
  }

  Future<void> addRecentUser(UserSearchResult user) => _recentStore.addRecentFromResult(user);

  Future<void> removeRecentUser(String userId) => _recentStore.removeRecentUser(userId);

  Future<void> clearAllRecents() => _recentStore.clearAll();

  Future<SearchResultsBundle> searchAll(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const SearchResultsBundle();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return _mockSearchAll(trimmed);
    }

    return _searchAllFromApi(trimmed);
  }

  Future<SearchResultsBundle> _searchAllFromApi(String query) async {
    Object? firstError;

    Future<PaginatedResult<UserSearchResult>> peopleSearch() =>
        _userSearchService.search(query: query, limit: previewLimit);

    Future<PaginatedResult<PostSearchResult>> postSearch(PostType type) =>
        _postSearchService.search(query: query, type: type, limit: previewLimit);

    PaginatedResult<UserSearchResult> peopleResult;
    try {
      peopleResult = await peopleSearch();
    } catch (e) {
      firstError ??= e;
      peopleResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> postsResult;
    try {
      postsResult = await postSearch(PostType.poster);
    } catch (e) {
      firstError ??= e;
      postsResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> jobsResult;
    try {
      jobsResult = await postSearch(PostType.job);
    } catch (e) {
      firstError ??= e;
      jobsResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> videosResult;
    try {
      videosResult = await postSearch(PostType.video);
    } catch (e) {
      firstError ??= e;
      videosResult = const PaginatedResult(items: [], hasMore: false);
    }

    final bundle = SearchResultsBundle(
      people: peopleResult.items,
      posts: postsResult.items,
      jobs: jobsResult.items,
      videos: videosResult.items,
    );

    if (bundle.isEmpty && firstError != null) {
      throw firstError;
    }

    return bundle;
  }

  Future<PaginatedResult<UserSearchResult>> searchPeople({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final all = _filterMockUsers(query);
      final start = (page - 1) * limit;
      final slice = all.skip(start).take(limit).toList();
      return PaginatedResult(items: slice, hasMore: start + limit < all.length);
    }
    return _userSearchService.search(query: query, page: page, limit: limit);
  }

  Future<PaginatedResult<PostSearchResult>> searchPosts({
    required String query,
    PostType? type,
    int page = 1,
    int limit = 10,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final all = _filterMockPosts(query, type: type);
      final start = (page - 1) * limit;
      final slice = all.skip(start).take(limit).toList();
      return PaginatedResult(items: slice, hasMore: start + limit < all.length);
    }
    return _postSearchService.search(query: query, type: type, page: page, limit: limit);
  }

  SearchResultsBundle _mockSearchAll(String query) {
    final people = _filterMockUsers(query).take(previewLimit).toList();
    final posters = _filterMockPosts(query, type: PostType.poster).take(previewLimit).toList();
    final jobs = _filterMockPosts(query, type: PostType.job).take(previewLimit).toList();
    final videos = _filterMockPosts(query, type: PostType.video).take(previewLimit).toList();
    return SearchResultsBundle(
      people: people,
      posts: posters,
      jobs: jobs,
      videos: videos,
    );
  }

  List<UserSearchResult> _filterMockUsers(String query) {
    final q = query.toLowerCase();
    return _mockUsers
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            (u.major?.toLowerCase().contains(q) ?? false) ||
            (u.university?.toLowerCase().contains(q) ?? false) ||
            (u.headline?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<PostSearchResult> _filterMockPosts(String query, {PostType? type}) {
    final q = query.toLowerCase();
    return _mockPosts.where((post) {
      if (type != null && post.type != type) return false;
      return post.title.toLowerCase().contains(q) ||
          post.authorName.toLowerCase().contains(q) ||
          (post.jobCompany?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  static final _defaultRecents = <SearchRecentUser>[
    SearchRecentUser(
      userId: 'author-1',
      fullName: 'Heng Liza',
      visitedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SearchRecentUser(
      userId: MockIdentities.mockUserId,
      fullName: 'Khorn Molika',
      visitedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SearchRecentUser(
      userId: 'author-4',
      fullName: 'Moeng Kimheang',
      visitedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static final _mockUsers = <UserSearchResult>[
    const UserSearchResult(
      userId: 'author-1',
      fullName: 'Heng Liza',
      university: 'American University of Phnom Penh',
      major: 'Web Development',
      headline: 'Graphic designer · AUB',
    ),
    UserSearchResult(
      userId: MockIdentities.mockUserId,
      fullName: 'Khorn Molika',
      university: 'ACLEDA University of Business',
      major: 'Computer Science',
      headline: 'Fintech developer',
    ),
    const UserSearchResult(
      userId: 'author-4',
      fullName: 'Moeng Kimheang',
      university: 'American University of Phnom Penh',
      major: 'Computer Science',
      headline: 'Student at AUB',
    ),
    const UserSearchResult(
      userId: 'author-2',
      fullName: 'Molika Khorn',
      university: 'American University of Phnom Penh',
      major: 'Media Communications',
      headline: 'Content creator',
    ),
    const UserSearchResult(
      userId: 'author-3',
      fullName: 'AUB Career Center',
      university: 'American University of Phnom Penh',
      major: 'Career Services',
      headline: 'Official career page',
    ),
    const UserSearchResult(
      userId: 'author-5',
      fullName: 'Heng Sokha',
      university: 'American University of Phnom Penh',
      major: 'Business Administration',
      headline: 'Student at AUB',
    ),
  ];

  static final _mockPosts = <PostSearchResult>[
    PostSearchResult(
      id: 'post-1',
      type: PostType.poster,
      title: 'Workshop poster this Friday — join campus networking',
      authorName: 'Heng Liza',
      thumbnailUrl: 'https://picsum.photos/seed/poster1/120/120',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostSearchResult(
      id: 'post-2',
      type: PostType.video,
      title: 'CCNA topology walkthrough for AUB students',
      authorName: 'Molika Khorn',
      thumbnailUrl: 'https://picsum.photos/seed/vthumb2/160/90',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PostSearchResult(
      id: 'post-3',
      type: PostType.job,
      title: 'Multiple position · Aeon Mall',
      authorName: 'AUB Career Center',
      thumbnailUrl: 'https://picsum.photos/seed/job3/120/120',
      jobCompany: 'Aeon Mall',
      jobLocation: 'Phnom Penh',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PostSearchResult(
      id: 'post-4',
      type: PostType.job,
      title: 'Marketing Intern — summer program',
      authorName: 'AUB Career Center',
      thumbnailUrl: 'https://picsum.photos/seed/job4/120/120',
      jobCompany: 'Global Tech Solutions',
      jobLocation: 'Pur Senchey',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PostSearchResult(
      id: 'post-5',
      type: PostType.video,
      title: 'Student showcase highlights from last week',
      authorName: 'Khorn Molika',
      thumbnailUrl: 'https://picsum.photos/seed/vthumb5/160/90',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PostSearchResult(
      id: 'post-6',
      type: PostType.poster,
      title: 'Heng Liza design portfolio launch event',
      authorName: 'Heng Liza',
      thumbnailUrl: 'https://picsum.photos/seed/poster6/120/120',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];
}
