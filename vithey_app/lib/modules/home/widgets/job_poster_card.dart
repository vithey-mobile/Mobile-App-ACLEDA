import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class JobPosterCard extends StatelessWidget {
  const JobPosterCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onApply,
    required this.onOpen,
    this.onViewApplicants,
    this.onAuthorTap,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onOpen;
  final VoidCallback? onViewApplicants;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      headerTrailing: _JobActionButton(post: post, onApply: onApply, onViewApplicants: onViewApplicants),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.jobMeta.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Text(
                post.jobMeta.title!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          PostMediaImage(url: post.mediaUrl),
        ],
      ),
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onBodyTap: onOpen,
      onAuthorTap: onAuthorTap,
    );
  }
}

class _JobActionButton extends StatelessWidget {
  const _JobActionButton({
    required this.post,
    required this.onApply,
    this.onViewApplicants,
  });

  final FeedPost post;
  final VoidCallback onApply;
  final VoidCallback? onViewApplicants;

  @override
  Widget build(BuildContext context) {
    if (post.isOwnPost) {
      return TextButton(
        onPressed: onViewApplicants,
        child: Text('Applicants (${post.applicantCount})'),
      );
    }

    switch (post.applicationState) {
      case JobApplicationState.applied:
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text('Applied', style: TextStyle(color: context.appColors.muted, fontWeight: FontWeight.w600)),
        );
      case JobApplicationState.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case JobApplicationState.notApplied:
        if (post.lifecycleState != JobLifecycleState.open) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Closed', style: TextStyle(color: context.appColors.muted)),
          );
        }
        return TextButton(
          onPressed: onApply,
          child: const Text('Apply'),
        );
    }
  }
}
