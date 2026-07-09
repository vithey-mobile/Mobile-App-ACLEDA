import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/auth_wave_header.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthWaveHeader(heightFactor: 0.22),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Obx(() {
                  if (controller.forgotPasswordSuccess.value) {
                    return Column(
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.resetLinkSent,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.appColors.heading,
                              ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: AppStrings.back,
                            icon: Icons.arrow_back,
                            onPressed: () {
                              controller.resetForgotPasswordState();
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Form(
                    key: controller.forgotPasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.forgotPasswordTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: context.appColors.heading,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.forgotPasswordSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.appColors.muted, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: controller.forgotPasswordEmailController,
                          label: AppStrings.emailAddress,
                          hint: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          onChanged: (_) {
                            if (controller.forgotPasswordError.isNotEmpty) {
                              controller.forgotPasswordError.value = '';
                            }
                          },
                          textInputAction: TextInputAction.done,
                        ),
                        if (controller.forgotPasswordError.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            controller.forgotPasswordError.value,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 16),
                        CustomButton(
                          label: AppStrings.sendResetLink,
                          icon: Icons.send_outlined,
                          isLoading: controller.isForgotPasswordLoading.value,
                          onPressed: controller.requestPasswordReset,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            controller.resetForgotPasswordState();
                            Get.back();
                          },
                          child: const Text(AppStrings.back),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
