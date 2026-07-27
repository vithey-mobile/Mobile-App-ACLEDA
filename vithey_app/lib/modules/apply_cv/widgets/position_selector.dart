import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Position field matching Apply CV Screen 1 — always visible when a title exists.
class PositionSelector extends StatelessWidget {
  const PositionSelector({
    super.key,
    required this.positions,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final List<String> positions;
  final String? selected;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (positions.isEmpty) return const SizedBox.shrink();

    final value = selected ?? positions.first;
    final canChange = enabled && positions.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.position,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.appColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: positions.contains(value) ? value : positions.first,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.appColors.muted,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            hint: const Text(AppStrings.selectPosition),
            items: positions
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(
                      p,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.appColors.heading,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: canChange ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
