import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

class ProfileJobCard extends StatelessWidget {
  const ProfileJobCard({
    super.key,
    required this.post,
    required this.isOwnProfile,
    required this.onTap,
    required this.onViewApplicants,
    required this.onApply,
  });

  final FeedPost post;
  final bool isOwnProfile;
  final VoidCallback onTap;
  final VoidCallback onViewApplicants;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final title = post.jobMeta.title ?? 'Job opening';
    final company = post.author.fullName;
    final location = post.content.isNotEmpty ? post.content.split('\n').first : 'Phnom Penh';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: post.mediaUrl != null
                      ? CachedNetworkImage(imageUrl: post.mediaUrl!, fit: BoxFit.cover)
                      : ColoredBox(color: context.appColors.inputFill, child: const Icon(Icons.work_outline)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '$company ( Full-time )',
                      style: TextStyle(color: context.appColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: context.appColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.appColors.muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      RelativeTime.format(post.createdAt),
                      style: TextStyle(color: context.appColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    if (isOwnProfile)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${post.applicantCount} Application',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: onViewApplicants,
                            child: const Text('View List >'),
                          ),
                        ],
                      )
                    else if (post.applicationState == JobApplicationState.applied)
                      const Text('Applied', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))
                    else
                      TextButton(
                        onPressed: onApply,
                        child: const Text('Apply'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
