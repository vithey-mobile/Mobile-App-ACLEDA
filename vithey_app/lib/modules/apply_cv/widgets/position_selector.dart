import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PositionSelector extends StatelessWidget {
  const PositionSelector({
    super.key,
    required this.position,
  });

  final String position;

  @override
  Widget build(BuildContext context) {
    if (position.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.position,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: context.appColors.heading),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Position automatically selected from this job post',
            value: position,
            readOnly: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    size: 19,
                    color: context.appColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.heading,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Auto-selected from this job post',
            style: TextStyle(
              color: context.appColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
