import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ApplicationFeedbackSuccess {
  static Future<void> show() {
    return Get.dialog<void>(
      const _ApplicationFeedbackSuccessDialog(),
      barrierDismissible: false,
    );
  }
}

class _ApplicationFeedbackSuccessDialog extends StatelessWidget {
  const _ApplicationFeedbackSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: context.appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SizedBox.expand(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _FeedbackSubmittedHero(),
                  const SizedBox(height: 18),
                  Text(
                    'Feedback Submitted!',
                    style: TextStyle(
                      color: context.appColors.heading,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 310),
                    child: Text(
                      'Your feedback has been submitted successfully to the candidate.',
                      style: TextStyle(
                        color: context.appColors.muted,
                        fontSize: 14,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
              child: Icon(
                Icons.description,
                size: 76,
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
          ),
          const Icon(
            Icons.description,
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
              child: const Icon(Icons.check, color: Colors.white, size: 20),
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
