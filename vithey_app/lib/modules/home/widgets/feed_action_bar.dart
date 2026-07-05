import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionButton(
            icon: post.userReacted ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: post.reactionCount > 0 ? '${post.reactionCount}' : 'Like',
            color: post.userReacted ? AppColors.primary : AppColors.authMuted,
            onTap: onLike,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: post.commentCount > 0 ? '${post.commentCount}' : 'Comment',
            onTap: onComment,
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: post.shareCount > 0 ? '${post.shareCount}' : 'Share',
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color ?? AppColors.authMuted),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color ?? AppColors.authHeading, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
