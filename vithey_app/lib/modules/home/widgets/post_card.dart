import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/post_author_header.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.headerTrailing,
    required this.body,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBodyTap,
    this.onAuthorTap,
  });

  final FeedPost post;
  final Widget? headerTrailing;
  final Widget body;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBodyTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostAuthorHeader(post: post, trailing: headerTrailing, onAuthorTap: onAuthorTap),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(post.content),
            ),
          GestureDetector(onTap: onBodyTap, child: body),
          FeedActionBar(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}

class PostMediaImage extends StatelessWidget {
  const PostMediaImage({super.key, this.url, this.height = 220});

  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        height: height,
        color: context.appColors.inputFill,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: context.appColors.muted),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        height: height,
        color: context.appColors.inputFill,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        height: height,
        color: context.appColors.inputFill,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
