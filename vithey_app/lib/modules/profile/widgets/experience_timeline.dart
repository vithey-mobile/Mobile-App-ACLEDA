import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';

class ExperienceTimeline extends StatelessWidget {
  const ExperienceTimeline({
    super.key,
    required this.title,
    required this.entries,
    this.useEducationIcon = false,
  });

  final String title;
  final List<dynamic> entries;
  final bool useEducationIcon;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...entries.map((entry) {
          if (entry is ApplicantExperienceEntry) {
            return _TimelineEntry(
              nodeIcon: Icons.work_outline,
              title: entry.title,
              subtitle: entry.organization,
              period: entry.period,
              description: entry.description,
            );
          }
          if (entry is ApplicantEducationEntry) {
            return _TimelineEntry(
              nodeIcon: Icons.school_outlined,
              title: entry.degree,
              subtitle: entry.school,
              period: entry.period,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class _TimelineEntry extends StatefulWidget {
  const _TimelineEntry({
    required this.nodeIcon,
    required this.title,
    required this.subtitle,
    required this.period,
    this.description,
  });

  final IconData nodeIcon;
  final String title;
  final String subtitle;
  final String period;
  final String? description;

  @override
  State<_TimelineEntry> createState() => _TimelineEntryState();
}

class _TimelineEntryState extends State<_TimelineEntry> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description;
    final hasLongDescription = description != null && description.length > 120;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: context.appColors.border,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(widget.nodeIcon, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(color: context.appColors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.period,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: _expanded || !hasLongDescription ? null : 3,
                      overflow: _expanded || !hasLongDescription ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (hasLongDescription)
                      TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(_expanded ? 'Show less' : 'Show more'),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
