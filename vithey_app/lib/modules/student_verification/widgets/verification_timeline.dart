import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VerificationTimeline extends StatelessWidget {
  const VerificationTimeline({super.key, this.submittedAt});

  final DateTime? submittedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 12),
        _TimelineStep(
          title: 'Application Submitted',
          subtitle: submittedAt != null ? _formatDate(submittedAt!) : 'Completed',
          tone: _StepTone.completed,
        ),
        const _TimelineStep(
          title: 'Under Review',
          subtitle: 'In progressing...',
          tone: _StepTone.active,
        ),
        const _TimelineStep(
          title: 'Verification Complete',
          subtitle: 'Pending',
          tone: _StepTone.idle,
          isLast: true,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

enum _StepTone { completed, active, idle }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.tone,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final _StepTone tone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData icon;
    switch (tone) {
      case _StepTone.completed:
        iconColor = AppColors.success;
        icon = Icons.check_circle_outline;
      case _StepTone.active:
        iconColor = const Color(0xFFFF8A50);
        icon = Icons.access_time_outlined;
      case _StepTone.idle:
        iconColor = context.appColors.muted;
        icon = Icons.info_outline;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 18,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: context.appColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.appColors.heading,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.appColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
