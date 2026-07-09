import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

class ProfileVideoCard extends StatelessWidget {
  const ProfileVideoCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  final FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = post.jobMeta.title?.isNotEmpty == true
        ? post.jobMeta.title!
        : (post.content.length > 40 ? '${post.content.substring(0, 40)}…' : post.content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (post.thumbnailUrl != null)
                    CachedNetworkImage(imageUrl: post.thumbnailUrl!, fit: BoxFit.cover)
                  else
                    Container(color: context.appColors.inputFill),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  const Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white54,
                      child: Icon(Icons.play_arrow, size: 36, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.appColors.muted, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    RelativeTime.format(post.createdAt),
                    style: TextStyle(color: context.appColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
