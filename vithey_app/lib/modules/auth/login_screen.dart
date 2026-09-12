import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/oauth_button.dart';
import 'package:aub_connect_app/modules/auth/widgets/register_step_slider.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Full auth frame: ribbon wave + logo + form + back.
class AuthRibbonFrame extends StatelessWidget {
  const AuthRibbonFrame({
    super.key,
    required this.profile,
    required this.form,
    required this.onBack,
  });

  final WaveRibbonProfile profile;
  final Widget form;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;
    final tealBandH = (screenH * OnboardingBackground.tealBandHeightFraction(profile))
        .clamp(140.0, 260.0);
    final formWidth = screenW < 420 ? screenW : 420.0;
    final isCompact = screenH < 720;
    final logoSize = isCompact ? 76.0 : 96.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        OnboardingBackground(profile: profile),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: tealBandH,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              FormErrorHost.clearAll();
                            },
                            child: Center(
                              child: AppLogo(
                                size: logoSize,
                                onWhiteCircle: true,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: SizedBox(
                            width: formWidth,
                            child: form,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: CustomButton(
              label: AppStrings.back,
              variant: CustomButtonVariant.ghost,
              foregroundColor: AppColors.accentLight,
              onPressed: onBack,
            ),
          ),
        ),
      ],
    );
  }
}

/// Auth Sign In form (used by intro ribbon continuum).
class AuthSignInForm extends GetView<AuthController> {
  const AuthSignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: FormErrorHost(
        formKey: controller.loginFormKey,
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.welcomeBack,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.appColors.heading,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: controller.emailController,
                label: AppStrings.emailAddress,
                hint: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                onChanged: (_) => controller.clearError(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.passwordController,
                label: AppStrings.password,
                hint: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.password,
                onChanged: (_) => controller.clearError(),
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: AppStrings.forgotPassword,
                  variant: CustomButtonVariant.ghost,
                  foregroundColor: context.scheme.primary,
                  onPressed: () {
                    FormErrorHost.clearAll();
                    Get.toNamed(AppRoutes.forgotPassword);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.errorMessage.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                );
              }),
              Obx(
                () => _AuthPrimaryButton(
                  label: AppStrings.signIn,
                  icon: Icons.login,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.login,
                ),
              ),
              const SizedBox(height: 16),
              const SocialDivider(label: AppStrings.signInWith, fontSize: 12),
              const SizedBox(height: 14),
              Obx(
                () => OAuthButton(
                  label: AppStrings.continueWithGoogle,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: () {
                    FormErrorHost.clearAll();
                    controller.beginGoogleAuth(intent: AuthIntent.signIn);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.muted,
                    ),
                  ),
                  CustomButton(
                    label: AppStrings.signUp,
                    variant: CustomButtonVariant.ghost,
                    foregroundColor: context.scheme.primary,
                    onPressed: () {
                      FormErrorHost.clearAll();
                      controller.showSignUp();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auth Sign Up form (used by intro ribbon continuum).
class AuthSignUpForm extends GetView<AuthController> {
  const AuthSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.createAccount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.appColors.heading,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          RegisterStepSlider(
            part1: FormErrorHost(
              formKey: controller.registerPart1FormKey,
              child: Form(
                key: controller.registerPart1FormKey,
                child: const _RegisterPart1Fields(),
              ),
            ),
            part2: FormErrorHost(
              formKey: controller.registerPart2FormKey,
              child: Form(
                key: controller.registerPart2FormKey,
                child: const _RegisterPart2Fields(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Obx(() {
            if (controller.errorMessage.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            );
          }),
          Obx(() {
            final step = controller.registerStep.value;
            final loading = controller.isLoading.value;
            if (step == 0) {
              return _AuthPrimaryButton(
                label: AppStrings.next,
                icon: Icons.arrow_forward,
                isLoading: false,
                onPressed: controller.goToRegisterPart2,
              );
            }
            return _AuthPrimaryButton(
              label: AppStrings.signUp,
              icon: Icons.person_add_alt_1,
              isLoading: loading,
              onPressed: controller.register,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final step = controller.registerStep.value;
            return SocialDivider(
              label: step == 0 ? AppStrings.signInWith : null,
              fontSize: 12,
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final step = controller.registerStep.value;
            if (step == 0) {
              return OAuthButton(
                label: AppStrings.continueWithGoogle,
                isLoading: controller.isGoogleLoading.value,
                onPressed: () {
                  FormErrorHost.clearAll();
                  controller.beginGoogleAuth(intent: AuthIntent.register);
                },
              );
            }
            return CustomButton(
              label: AppStrings.back,
              variant: CustomButtonVariant.outline,
              onPressed: () {
                FormErrorHost.clearAll();
                controller.goToRegisterPart1();
              },
            );
          }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.hasAccount,
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.muted,
                ),
              ),
              CustomButton(
                label: AppStrings.signIn,
                variant: CustomButtonVariant.ghost,
                foregroundColor: context.scheme.primary,
                onPressed: () {
                  FormErrorHost.clearAll();
                  controller.showSignIn();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPart1Fields extends GetView<AuthController> {
  const _RegisterPart1Fields();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: controller.emailController,
          label: AppStrings.emailAddress,
          hint: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.passwordController,
          label: AppStrings.password,
          hint: 'Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: Validators.password,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.confirmPasswordController,
          label: AppStrings.confirmPassword,
          hint: 'Confirm Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: controller.confirmPasswordValidator,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class _RegisterPart2Fields extends GetView<AuthController> {
  const _RegisterPart2Fields();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: controller.fullNameController,
          label: AppStrings.fullName,
          hint: 'Username',
          prefixIcon: Icons.person_outline,
          validator: Validators.fullName,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.phoneController,
          label: AppStrings.phoneNumber,
          hint: '012345678',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.dateOfBirthController,
          label: AppStrings.dateOfBirth,
          hint: 'Date of Birth',
          prefixIcon: Icons.calendar_today_outlined,
          readOnly: true,
          validator: Validators.dateOfBirth,
          onTap: () => controller.pickDateOfBirth(context),
          textInputAction: TextInputAction.done,
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
