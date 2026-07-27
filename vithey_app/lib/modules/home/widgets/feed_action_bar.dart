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
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        children: [
          _ActionButton(
            icon: post.userReacted
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: '${post.reactionCount}',
            color:
                post.userReacted ? AppColors.primary : context.appColors.muted,
            onTap: onLike,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: '${post.commentCount}',
            onTap: onComment,
          ),
          _ActionButton(
            icon: Icons.link_rounded,
            label: '${post.shareCount}',
            onTap: onShare,
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color ?? context.appColors.muted),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? context.appColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
