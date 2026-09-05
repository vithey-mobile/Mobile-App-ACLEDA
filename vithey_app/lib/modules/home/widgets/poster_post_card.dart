import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PosterPostCard extends StatelessWidget {
  const PosterPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
    this.onAuthorTap,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      headerTrailing: post.isOwnPost ? null : _FollowButton(post: post, onFollow: onFollow),
      body: PostMediaImage(url: post.mediaUrl),
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onBodyTap: onOpen,
      onAuthorTap: onAuthorTap,
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.post, required this.onFollow});

  final FeedPost post;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onFollow,
      style: TextButton.styleFrom(
        foregroundColor: post.isFollowingAuthor ? context.appColors.muted : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(post.isFollowingAuthor ? 'Following' : 'Follow'),
    );
  }
}
