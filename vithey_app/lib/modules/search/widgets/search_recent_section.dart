import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_recent_tile.dart';

class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({
    super.key,
    required this.users,
    required this.isLoading,
    required this.onUserTap,
    this.onUserLongPress,
    this.onClearAll,
    this.header,
  });

  final List<SearchRecentUser> users;
  final bool isLoading;
  final ValueChanged<SearchRecentUser> onUserTap;
  final ValueChanged<SearchRecentUser>? onUserLongPress;
  final VoidCallback? onClearAll;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerListTile(),
      );
    }

    if (users.isEmpty) {
      return const EmptyStateWidget(
        title: 'No recent searches',
        subtitle: 'Try searching for people, posts, or jobs',
        icon: Icons.history,
      );
    }

    return ListView(
      children: [
        if (header != null) header!,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.heading,
                ),
              ),
              const Spacer(),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: Text('Clear all', style: TextStyle(color: colors.muted)),
                ),
            ],
          ),
        ),
        ...users.map(
          (user) => SearchRecentTile(
            user: user,
            onTap: () => onUserTap(user),
            onLongPress: onUserLongPress == null ? null : () => onUserLongPress!(user),
          ),
        ),
      ],
    );
  }
}
