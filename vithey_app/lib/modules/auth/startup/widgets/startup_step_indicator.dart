import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class StartupStepIndicator extends StatelessWidget {
  const StartupStepIndicator({super.key, required this.currentStep});

  /// Zero-based step index (0–2).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${currentStep + 1} of 3',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final active = index == currentStep;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : context.appColors.border,
            ),
          );
        }),
      ),
    );
  }
}
