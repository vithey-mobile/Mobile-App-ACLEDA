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
    required this.onOpenApplicants,
    required this.onApply,
    required this.onOpenPost,
    this.onEdit,
    this.onDelete,
  });

  final FeedPost post;
  final bool isOwnProfile;
  final VoidCallback onOpenApplicants;
  final VoidCallback onApply;
  final VoidCallback onOpenPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  void _openPosterPreview(BuildContext context) {
    final url = post.mediaUrl;
    if (url == null || url.isEmpty) return;
    final title = post.jobMeta.title ?? 'Job opening';
    final company = post.jobMeta.description ?? post.author.fullName;
    final employment = post.jobMeta.requirement ?? 'Full-time';
    final location =
        post.content.isNotEmpty ? post.content.split('\n').first : 'Phnom Penh';

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (ctx, _, __) => _JobPosterFullscreen(
          imageUrl: url,
          title: title,
          companyLine: '$company ( $employment )',
          location: location,
          postedAt: RelativeTime.format(post.createdAt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = post.jobMeta.title ?? 'Job opening';
    final company = post.jobMeta.description ?? post.author.fullName;
    final employment = post.jobMeta.requirement ?? 'Full-time';
    final location =
        post.content.isNotEmpty ? post.content.split('\n').first : 'Phnom Penh';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openPosterPreview(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: _PosterImage(
                            url: post.mediaUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 72,
                      child: Text(
                        RelativeTime.format(post.createdAt),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: context.appColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: isOwnProfile ? onOpenApplicants : onOpenPost,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$company ( $employment )',
                            style: TextStyle(
                              color: context.appColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: context.appColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.appColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isOwnProfile)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      color: context.appColors.muted,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.appColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: isOwnProfile
                ? Row(
                    children: [
                      InkWell(
                        onTap: onOpenApplicants,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${post.applicantCount} Application',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onOpenApplicants,
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.muted,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View List >'),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: post.applicationState == JobApplicationState.applied
                        ? Text(
                            'Applied',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFFB0B0B0)
                                  : const Color(0xFF616161),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : TextButton(
                            onPressed: onApply,
                            child: const Text('Apply'),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen poster: image centered; job details float from the bottom.
class _JobPosterFullscreen extends StatelessWidget {
  const _JobPosterFullscreen({
    required this.imageUrl,
    required this.title,
    required this.companyLine,
    required this.location,
    required this.postedAt,
  });

  final String imageUrl;
  final String title;
  final String companyLine;
  final String location;
  final String postedAt;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: _PosterImage(url: imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: topInset + 4,
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 16 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      companyLine,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      postedAt,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.url, required this.fit});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return ColoredBox(
        color: context.appColors.inputFill,
        child: const Icon(Icons.work_outline),
      );
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, __) => ColoredBox(color: context.appColors.inputFill),
      errorWidget: (_, __, ___) => ColoredBox(
        color: context.appColors.inputFill,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
