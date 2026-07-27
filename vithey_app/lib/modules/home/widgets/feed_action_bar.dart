import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class FeedActionBar extends StatelessWidget {
  const FeedActionBar({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.alignStart = false,
    this.onDark = false,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  /// When true (profile Videos & Posters): Like/Comment left, Share right
  /// (`spaceBetween`). When false (Home feed): equal-width centered actions.
  final bool alignStart;

  /// White / primary styling for black fullscreen overlays.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final idle = onDark
        ? Colors.white.withValues(alpha: 0.85)
        : context.appColors.muted;
    final labelColor =
        onDark ? Colors.white : context.appColors.heading;
    final liked = post.userReacted
        ? AppColors.primary
        : idle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionButton(
            icon: post.userReacted ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: post.reactionCount > 0 ? '${post.reactionCount}' : 'Like',
            color: liked,
            labelColor: post.userReacted ? AppColors.primary : labelColor,
            onTap: onLike,
            expanded: !alignStart,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: post.commentCount > 0 ? '${post.commentCount}' : 'Comment',
            color: idle,
            labelColor: labelColor,
            onTap: onComment,
            expanded: !alignStart,
          ),
          if (alignStart) const Spacer(),
          _ActionButton(
            icon: Icons.share_outlined,
            label: post.shareCount > 0 ? '${post.shareCount}' : 'Share',
            color: idle,
            labelColor: labelColor,
            onTap: onShare,
            expanded: !alignStart,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.labelColor,
    this.expanded = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? labelColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: expanded ? 0 : 10,
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color ?? context.appColors.muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: labelColor ?? color ?? context.appColors.heading,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );

    if (expanded) return Expanded(child: child);
    return child;
  }
}
