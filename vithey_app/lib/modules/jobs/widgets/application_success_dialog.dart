import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_dialog.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplicationSuccessDialog {
  static Future<void> show({required String jobTitle}) {
    final context = Get.context;
    if (context == null) return Future.value();

    return showVitheyDialog<void>(
      context: context,
      barrierDismissible: false,
      child: Builder(
        builder: (dialogContext) {
          final colors = dialogContext.appColors;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VitheyIcon(
                LucideIcons.circleCheck,
                color: AppColors.success,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                'Application submitted',
                textAlign: TextAlign.center,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your CV was sent for $jobTitle.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: colors.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
