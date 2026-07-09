import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

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
    if (positions.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.position,
            style: TextStyle(fontWeight: FontWeight.w500, color: context.appColors.heading),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.border),
              ),
            ),
            hint: const Text(AppStrings.selectPosition),
            items: positions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
