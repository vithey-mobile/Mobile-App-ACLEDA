import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_create_tile.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_grid_tile.dart';

/// Profile → Reels: Facebook-style 3-column grid + filter chips + Create tile.
class ProfileReelsTab extends StatefulWidget {
  const ProfileReelsTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  State<ProfileReelsTab> createState() => _ProfileReelsTabState();
}

enum _ReelFilter { all, liked, shared, popular }

class _ProfileReelsTabState extends State<ProfileReelsTab> {
  _ReelFilter _filter = _ReelFilter.all;

  List<FeedPost> _applyFilter(List<FeedPost> posts) {
    switch (_filter) {
      case _ReelFilter.all:
        return posts;
      case _ReelFilter.liked:
        return posts.where((p) => p.userReacted || p.reactionCount > 0).toList();
      case _ReelFilter.shared:
        return posts.where((p) => p.shareCount > 0).toList();
      case _ReelFilter.popular:
        final sorted = List<FeedPost>.from(posts)
          ..sort((a, b) => b.reactionCount.compareTo(a.reactionCount));
        return sorted.where((p) => p.reactionCount > 0).toList();
    }
  }

  void _openCreateReel() {
    Get.toNamed(
      AppRoutes.createPost,
      arguments: const CreatePostArgs(initialType: PostType.video),
    );
  }

  void _openReel(BuildContext context, FeedPost post, ProfileTabsHost host) {
    showMediaFullscreen(
      context,
      post,
      onLike: () {},
      onComment: () => host.openPost(post.id),
      onShare: () {},
      showShareAction: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = resolveProfileTabsHost(widget.host);
    final colors = context.appColors;

    return Obx(() {
      if (host.tabLoading[PostType.video]!.value &&
          host.tabPosts[PostType.video]!.isEmpty) {
        return const LoadingWidget();
      }

      final allPosts = host.tabPosts[PostType.video]!.toList();
      final posts = _applyFilter(allPosts);
      final showCreate = host.isOwnProfile;
      final emptyAfterFilter = posts.isEmpty && allPosts.isNotEmpty;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: _ReelFilterChips(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
            ),
          ),
          if (allPosts.isEmpty && !showCreate)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: 'Nothing here yet',
                subtitle: 'No Reels yet',
                icon: Icons.video_collection_outlined,
              ),
            )
          else if (allPosts.isEmpty && showCreate)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildListDelegate([
                  ProfileReelCreateTile(onTap: _openCreateReel),
                ]),
              ),
            )
          else if (emptyAfterFilter)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: 'No matching reels',
                subtitle: 'Try another filter',
                icon: Icons.filter_list_off_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (showCreate && index == 0) {
                      return ProfileReelCreateTile(onTap: _openCreateReel);
                    }
                    final postIndex = showCreate ? index - 1 : index;
                    final post = posts[postIndex];
                    return ProfileReelGridTile(
                      post: post,
                      onTap: () => _openReel(context, post, host),
                    );
                  },
                  childCount: posts.length + (showCreate ? 1 : 0),
                ),
              ),
            ),
          // Thin divider color under grid feels like FB gaps.
          SliverToBoxAdapter(
            child: ColoredBox(
              color: colors.bodyBackground,
              child: const SizedBox(height: 0),
            ),
          ),
        ],
      );
    });
  }
}

class _ReelFilterChips extends StatelessWidget {
  const _ReelFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final _ReelFilter selected;
  final ValueChanged<_ReelFilter> onSelected;

  static const _items = <(_ReelFilter, String, IconData)>[
    (_ReelFilter.all, 'All', Icons.grid_view_rounded),
    (_ReelFilter.liked, 'Liked', Icons.thumb_up_alt_outlined),
    (_ReelFilter.shared, 'Shared', Icons.share_outlined),
    (_ReelFilter.popular, 'Popular', Icons.visibility_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, label, icon) = _items[index];
          final isSelected = selected == id;
          final bg = isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : colors.cardSurface;
          final fg = isSelected ? AppColors.primary : colors.heading;
          final border = isSelected ? AppColors.primary : colors.border;

          return Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
