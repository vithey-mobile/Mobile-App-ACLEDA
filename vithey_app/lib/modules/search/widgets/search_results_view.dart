import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/modules/search/widgets/search_empty_state.dart';
import 'package:aub_connect_app/modules/search/widgets/search_job_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_loading_skeleton.dart';
import 'package:aub_connect_app/modules/search/widgets/search_person_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_post_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_section_header.dart';
import 'package:aub_connect_app/modules/search/widgets/search_video_tile.dart';

void _noop() {}

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.query,
    required this.isSearching,
    required this.error,
    required this.people,
    required this.posts,
    required this.jobs,
    required this.videos,
    required this.onRetry,
    required this.onPersonTap,
    required this.onPersonMessage,
    required this.onPostTap,
    required this.onSeeAll,
    this.peopleOnly = false,
  });

  final String query;
  final bool isSearching;
  final String? error;
  final List<UserSearchResult> people;
  final List<PostSearchResult> posts;
  final List<PostSearchResult> jobs;
  final List<PostSearchResult> videos;
  final VoidCallback onRetry;
  final ValueChanged<UserSearchResult> onPersonTap;
  final ValueChanged<UserSearchResult> onPersonMessage;
  final ValueChanged<PostSearchResult> onPostTap;
  final ValueChanged<SearchSeeAllCategory> onSeeAll;
  final bool peopleOnly;

  bool get _hasAny =>
      people.isNotEmpty ||
      posts.isNotEmpty ||
      jobs.isNotEmpty ||
      videos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (query.trim().length == 1) {
      return Center(
        child: Text(
          'Type at least 2 characters',
          style: TextStyle(color: context.appColors.muted),
        ),
      );
    }

    if (error != null && !_hasAny && !isSearching) {
      return _ErrorBanner(message: error!, onRetry: onRetry);
    }

    if (isSearching && !_hasAny) {
      return const SearchLoadingSkeleton();
    }

    if (!_hasAny && !isSearching) {
      return SearchEmptyState(query: peopleOnly ? 'people' : query);
    }

    if (peopleOnly) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (error != null) _ErrorBanner(message: error!, onRetry: onRetry),
          if (people.isNotEmpty) ...[
            const SearchSectionHeader(
                title: 'People', showSeeAll: false, onSeeAll: _noop),
            ...people.map(
              (person) => SearchPersonTile(
                person: person,
                query: query,
                onTap: () => onPersonTap(person),
                onMessage: () => onPersonMessage(person),
              ),
            ),
          ],
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (error != null) _ErrorBanner(message: error!, onRetry: onRetry),
        if (query.trim().length >= 2)
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1A03B4AC),
              child: Icon(Icons.map_outlined, color: AppColors.primary),
            ),
            title: const Text('Places on map'),
            subtitle: Text('Search "$query" near you'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.map, arguments: query.trim()),
          ),
        if (people.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'People',
            showSeeAll: people.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.people),
          ),
          ...people.map(
            (person) => SearchPersonTile(
              person: person,
              query: query,
              onTap: () => onPersonTap(person),
              onMessage: () => onPersonMessage(person),
            ),
          ),
        ],
        if (posts.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Posts',
            showSeeAll: posts.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.posts),
          ),
          ...posts.map(
            (post) => SearchPostTile(
              post: post,
              query: query,
              onTap: () => onPostTap(post),
            ),
          ),
        ],
        if (jobs.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Jobs',
            showSeeAll: jobs.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.jobs),
          ),
          ...jobs.map(
            (job) => SearchJobTile(
              job: job,
              query: query,
              onTap: () => onPostTap(job),
            ),
          ),
        ],
        if (videos.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Videos',
            showSeeAll: videos.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.videos),
          ),
          ...videos.map(
            (video) => SearchVideoTile(
              video: video,
              query: query,
              onTap: () => onPostTap(video),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.heading, fontSize: 13.5),
            ),
          ),
          VitheyTextLink(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}
