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
        const Text('Verification Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _TimelineStep(
          title: 'Application Submitted',
          subtitle: submittedAt != null ? _formatDate(submittedAt!) : 'Completed',
          completed: true,
          active: false,
        ),
        const _TimelineStep(
          title: 'Under Review',
          subtitle: 'In progress…',
          completed: false,
          active: true,
        ),
        const _TimelineStep(
          title: 'Verification Complete',
          subtitle: 'Pending',
          completed: false,
          active: false,
          isLast: true,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.active,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool completed;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.success
        : active
            ? AppColors.warning
            : context.appColors.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed ? Icons.check_circle : active ? Icons.timelapse : Icons.radio_button_unchecked,
              color: color,
            ),
            if (!isLast) Container(width: 2, height: 28, color: context.appColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: context.appColors.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
