import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 72,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined, size: 40, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Feedback Submitted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your feedback already submitted successfully to the candidate.',
              style: TextStyle(color: context.appColors.muted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: shad.Button.primary(
                onPressed: () => Get.back(),
                child: const shad.Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
