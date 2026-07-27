import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';

class PosterPostCard extends StatelessWidget {
  const PosterPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    this.onAuthorTap,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      headerTrailing: post.isOwnPost
          ? PostOwnerActions(onEdit: onEdit, onDelete: onDelete)
          : _FollowButton(post: post, onFollow: onFollow),
      body: (post.mediaUrl == null || post.mediaUrl!.isEmpty)
          ? null
          : PostMediaImage(url: post.mediaUrl),
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
    return Material(
      color: context.scheme.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onFollow,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 26,
          width: post.isFollowingAuthor ? 66 : 54,
          child: Center(
            child: Text(
              post.isFollowingAuthor ? 'Following' : 'Follow',
              style: TextStyle(
                color: context.scheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
