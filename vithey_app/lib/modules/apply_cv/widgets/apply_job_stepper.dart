import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ApplyJobStepper extends StatelessWidget {
  const ApplyJobStepper({
    super.key,
    required this.currentStep,
  });

  /// 0 = upload, 1 = review, 2 = success (visual only on wizard)
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          _StepNode(active: currentStep >= 0, completed: currentStep > 0),
          Expanded(child: _StepLine(active: currentStep >= 1)),
          _StepNode(active: currentStep >= 1, completed: currentStep > 1),
          Expanded(child: _StepLine(active: currentStep >= 2)),
          _StepNode(active: currentStep >= 2, completed: false),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.active, required this.completed});

  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : context.appColors.border;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.primary : Colors.transparent,
        border: Border.all(color: color, width: 2),
      ),
      child: completed
          ? const Icon(Icons.check, size: 8, color: Colors.white)
          : null,
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? AppColors.primary : context.appColors.border,
    );
  }
}
