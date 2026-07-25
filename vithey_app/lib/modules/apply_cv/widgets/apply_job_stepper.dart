import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// 3-step progress matching Apply CV Screen 1–2.
/// Step 0: node1 filled + line teal; node2 soft teal; rest gray.
class ApplyJobStepper extends StatelessWidget {
  const ApplyJobStepper({
    super.key,
    required this.currentStep,
  });

  /// 0 = upload, 1 = review, 2 = success (visual only on wizard)
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final soft = primary.withValues(alpha: 0.35);
    final idle = context.appColors.border;

    return Semantics(
      label: 'Step ${currentStep + 1} of 3',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 4, 48, 20),
        child: Row(
          children: [
            _StepNode(
              fill: primary,
              border: primary,
              filled: true,
            ),
            Expanded(child: _StepLine(color: primary)),
            _StepNode(
              fill: currentStep >= 1 ? primary : Colors.transparent,
              border: currentStep >= 1 ? primary : soft,
              filled: currentStep >= 1,
            ),
            Expanded(child: _StepLine(color: currentStep >= 1 ? primary : idle)),
            _StepNode(
              fill: currentStep >= 2 ? primary : Colors.transparent,
              border: currentStep >= 2 ? primary : idle,
              filled: currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.fill,
    required this.border,
    required this.filled,
  });

  final Color fill;
  final Color border;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? fill : Colors.transparent,
        border: Border.all(color: border, width: 2.5),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
