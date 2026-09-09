import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/auth_moving_wave_sheet.dart';
import 'package:aub_connect_app/modules/auth/widgets/vithey_genz.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  void _goBack() {
    controller.resetForgotPasswordState();
    FormErrorHost.clearAll();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(solidTeal: true),
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    FormErrorHost.clearAll();
                  },
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: AppLogo(size: 108, onWhiteCircle: true),
                    ),
                  ),
                ),
              ),
              AuthMovingWaveSheet(
                waveHeightFactor: 0.10,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Obx(() {
                    if (controller.forgotPasswordSuccess.value) {
                      return _SuccessBody(onBack: _goBack);
                    }
                    return _ResetFormBody(controller: controller);
                  }),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: VitheyIconButton(
                icon: LucideIcons.arrowLeft,
                tooltip: AppStrings.back,
                onTeal: true,
                onPressed: _goBack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetFormBody extends StatelessWidget {
  const _ResetFormBody({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return FormErrorHost(
      formKey: controller.forgotPasswordFormKey,
      child: Form(
        key: controller.forgotPasswordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.forgotPasswordTitle,
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.forgotPasswordSubtitle,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.appColors.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: controller.forgotPasswordEmailController,
              label: AppStrings.emailAddress,
              hint: 'Email',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              onChanged: (_) {
                if (controller.forgotPasswordError.isNotEmpty) {
                  controller.forgotPasswordError.value = '';
                }
              },
              textInputAction: TextInputAction.done,
            ),
            Obx(() {
              if (controller.forgotPasswordError.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.forgotPasswordError.value,
                  style:
                      context.text.bodySmall?.copyWith(color: AppColors.error),
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(
              () => _AuthPrimaryButton(
                label: AppStrings.sendResetLink,
                icon: LucideIcons.send,
                isLoading: controller.isForgotPasswordLoading.value,
                onPressed: () async {
                  final ok =
                      await FormErrorHost.submit(controller.forgotPasswordFormKey);
                  if (ok) controller.requestPasswordReset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.12,
            ),
          ),
          child: const VitheyIcon(
            LucideIcons.mailCheck,
            size: 44,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.resetLinkSent,
          textAlign: TextAlign.center,
          style: context.text.titleMedium,
        ),
        const SizedBox(height: 24),
        _AuthPrimaryButton(
          label: AppStrings.back,
          icon: LucideIcons.arrowLeft,
          onPressed: onBack,
        ),
      ],
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: label,
        icon: icon,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}
