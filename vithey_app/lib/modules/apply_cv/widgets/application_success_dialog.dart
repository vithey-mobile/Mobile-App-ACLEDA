import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ApplicationSuccessDialog {
  static Future<void> show({required String jobTitle}) {
    return shad.showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => shad.Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 56),
              const SizedBox(height: 16),
              const shad.Text('Application submitted').large().bold(),
              const SizedBox(height: 8),
              shad.Text('Your CV was sent for $jobTitle.'),
              const SizedBox(height: 20),
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
      ),
    );
  }
}
