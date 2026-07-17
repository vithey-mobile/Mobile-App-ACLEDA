import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';

class SearchRecentTile extends StatelessWidget {
  const SearchRecentTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onTogglePin,
    required this.onRemove,
    this.showActions = true,
  });

  final SearchRecentItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onRemove;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle =
        item.isUser ? 'Followers ${_formatCount(item.followerCount)}' : null;

    return Semantics(
      label: [
        item.isUser ? 'Person' : 'Recent search',
        item.title,
        if (subtitle != null) subtitle,
        if (item.isPinned) 'Pinned',
      ].join(', '),
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 7, 12, 7),
            child: Row(
              children: [
                if (item.isUser)
                  UserAvatar(
                    name: item.title,
                    imageUrl: item.avatarUrl,
                    radius: 20,
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.inputFill,
                    child: Icon(
                      Icons.history_rounded,
                      color: colors.muted,
                      size: 21,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: colors.heading,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showActions)
                  IconButton(
                    tooltip: 'More options for ${item.title}',
                    onPressed: () => _showActions(context),
                    icon: item.isPinned
                        ? Transform.rotate(
                            angle: -0.55,
                            child: Icon(
                              Icons.push_pin_rounded,
                              color: colors.muted,
                              size: 22,
                            ),
                          )
                        : Icon(
                            Icons.more_vert_rounded,
                            color: colors.muted,
                            size: 21,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = sheetContext.appColors;
        return Container(
          decoration: BoxDecoration(
            color: colors.cardSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.heading,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RecentSheetAction(
                    icon: item.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    label: item.isPinned ? 'Unpin' : 'Pin',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onTogglePin();
                    },
                  ),
                  _RecentSheetAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove from recent',
                    color: sheetContext.scheme.error,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onRemove();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int? count) {
    if (count == null) return '—';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(count % 1000000 == 0 ? 0 : 1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}K';
    }
    return '$count';
  }
}

class _RecentSheetAction extends StatelessWidget {
  const _RecentSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.appColors.heading;
    final iconWidget =
        icon == Icons.push_pin_rounded || icon == Icons.push_pin_outlined
            ? Transform.rotate(
                angle: -0.55,
                child: Icon(icon, color: foreground, size: 23),
              )
            : Icon(icon, color: foreground, size: 23);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                iconWidget,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
