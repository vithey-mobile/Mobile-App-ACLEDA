import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_dialog.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplicationFeedbackSuccess {
  static Future<void> show() {
    return showVitheyDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      child: const _ApplicationFeedbackSuccessDialog(),
    );
  }
}

class _ApplicationFeedbackSuccessDialog extends StatelessWidget {
  const _ApplicationFeedbackSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _FeedbackSubmittedHero(),
        const SizedBox(height: 18),
        Text(
          'Feedback Submitted!',
          style: context.text.titleLarge?.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your feedback has been submitted successfully to the candidate.',
          style: context.text.bodyMedium?.copyWith(
            color: context.appColors.muted,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeedbackSubmittedHero extends StatelessWidget {
  const _FeedbackSubmittedHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 22,
            top: 30,
            child: Transform.rotate(
              angle: -0.08,
              child: VitheyIcon(
                LucideIcons.fileText,
                size: 76,
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
          ),
          const VitheyIcon(
            LucideIcons.fileText,
            size: 82,
            color: AppColors.info,
          ),
          Positioned(
            right: 12,
            top: 60,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const VitheyIcon(LucideIcons.check, color: Colors.white, size: 20),
            ),
          ),
          Positioned(
            bottom: 12,
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  width: 3,
                  height: 14 + (index * 6),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
