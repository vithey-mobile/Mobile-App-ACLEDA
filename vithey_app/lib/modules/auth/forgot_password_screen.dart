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
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';

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
          const OnboardingBackground(
            waveHeightFactor: OnboardingBackground.onboardingFactor,
            authMorph: 1.0,
          ),
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
              child: CustomButton(
                label: AppStrings.back,
                variant: CustomButtonVariant.ghost,
                foregroundColor: Colors.white,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.appColors.heading,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.forgotPasswordSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.muted,
                height: 1.4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
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
            Obx(() {
              if (controller.forgotPasswordError.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.forgotPasswordError.value,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(
              () => _AuthPrimaryButton(
                label: AppStrings.sendResetLink,
                icon: Icons.send_outlined,
                isLoading: controller.isForgotPasswordLoading.value,
                onPressed: () {
                  FormErrorHost.activateFor(controller.forgotPasswordFormKey);
                  controller.requestPasswordReset();
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
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.primary,
        ),
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
        _AuthPrimaryButton(
          label: AppStrings.back,
          icon: Icons.arrow_back,
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
