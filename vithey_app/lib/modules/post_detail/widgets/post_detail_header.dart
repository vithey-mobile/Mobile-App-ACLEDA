import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PostDetailHeader extends StatelessWidget {
  const PostDetailHeader({
    super.key,
    required this.post,
    required this.onFollow,
  });

  final FeedPost post;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          UserAvatar(name: post.author.fullName, imageUrl: post.author.avatarUrl, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.author.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(RelativeTime.format(post.createdAt), style: TextStyle(color: context.appColors.muted, fontSize: 12)),
              ],
            ),
          ),
          if (!post.isOwnPost)
            TextButton(
              onPressed: onFollow,
              child: Text(post.isFollowingAuthor ? 'Following' : 'Follow'),
            ),
        ],
      ),
    );
  }
}
