import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AccountStatsRow extends StatelessWidget {
  const AccountStatsRow({
    super.key,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.likeCount,
  });

  final int followerCount;
  final int followingCount;
  final int postCount;
  final int likeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: context.appColors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _StatItem(label: 'Followers', value: followerCount),
          _StatItem(label: 'Following', value: followingCount),
          _StatItem(label: 'Posts', value: postCount),
          _StatItem(label: 'Likes', value: likeCount),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            _formatCount(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
