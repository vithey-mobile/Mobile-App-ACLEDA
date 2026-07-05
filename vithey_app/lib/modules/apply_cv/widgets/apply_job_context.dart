import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';

class ApplyJobContext extends StatelessWidget {
  const ApplyJobContext({
    super.key,
    required this.job,
    required this.eligibility,
    required this.isLoading,
    required this.onRetry,
  });

  final FeedPost? job;
  final JobEligibilityResult? eligibility;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(width: 180),
            SizedBox(height: 8),
            _SkeletonLine(width: 120),
          ],
        ),
      );
    }

    if (job == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Could not load job details', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final title = job!.jobMeta.title ?? 'Job opportunity';
    final status = eligibility?.message;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applying for $title',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.authHeading),
          ),
          const SizedBox(height: 4),
          Text(job!.author.fullName, style: const TextStyle(color: AppColors.authMuted)),
          if (job!.jobMeta.description != null && job!.jobMeta.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(job!.jobMeta.description!, style: const TextStyle(height: 1.4)),
          ],
          if (status != null && eligibility?.eligibility != JobEligibility.eligible) ...[
            const SizedBox(height: 12),
            Text(status, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.authInputFill,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
