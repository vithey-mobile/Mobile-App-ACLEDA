import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/auth_panel_switcher.dart';
import 'package:aub_connect_app/modules/auth/widgets/oauth_button.dart';
import 'package:aub_connect_app/modules/auth/widgets/register_step_slider.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';

/// Auth v2 shell:
/// - Wave → solid teal morph from Onboarding (shared painter)
/// - Light-teal wave band (~10% screen) + white body (hugs form content)
/// - Toggle animation: sheet grows up / shrinks down to hug each form
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        final bgMorph = controller.bgMorph.value.clamp(0.0, 1.0);
        final layout = controller.layoutReveal.value.clamp(0.0, 1.0);
        final content = controller.contentOpacity.value.clamp(0.0, 1.0);
        final busy = controller.isBusy.value;
        final sheetSlide =
            MediaQuery.sizeOf(context).height * 0.35 * (1.0 - layout);

        return Stack(
          fit: StackFit.expand,
          children: [
            OnboardingBackground(
              waveHeightFactor: OnboardingBackground.onboardingFactor,
              authMorph: bgMorph,
            ),
            Opacity(
              opacity: content,
              child: IgnorePointer(
                ignoring: busy,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                                child: Obx(() {
                                  final animating =
                                      controller.isPanelAnimating.value;
                                  return AnimatedOpacity(
                                    opacity: animating ? 0.9 : 1.0,
                                    duration: const Duration(milliseconds: 420),
                                    curve: Curves.easeInOut,
                                    child: const AppLogo(
                                      size: 108,
                                      onWhiteCircle: true,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, sheetSlide),
                          child: Opacity(
                            opacity: layout,
                            child: const AuthPanelSwitcher(
                              signInForm: _SignInForm(),
                              signUpForm: _SignUpForm(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SafeArea(
                        child: TextButton(
                          onPressed: busy ? null : controller.goBack,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accentLight,
                            minimumSize: const Size(44, 44),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            AppStrings.back,
                            style: TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Legacy route target — opens the same Auth shell on the Sign Up panel.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.authPageIndex.value != 1) {
        auth.showSignUp();
      }
    });
    return const LoginScreen();
  }
}

class _SignInForm extends GetView<AuthController> {
  const _SignInForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
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
                child: TextButton(
                  onPressed: () {
                    FormErrorHost.clearAll();
                    Get.toNamed(AppRoutes.forgotPassword);
                  },
                style: TextButton.styleFrom(
                  foregroundColor: context.scheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: const Size(44, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.scheme.primary,
                  ),
                ),
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
                  onPressed: () {
                    FormErrorHost.activateFor(controller.loginFormKey);
                    controller.login();
                  },
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
                  TextButton(
                    onPressed: () {
                      FormErrorHost.clearAll();
                      controller.showSignUp();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: context.scheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      minimumSize: const Size(44, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.scheme.primary,
                      ),
                    ),
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

class _SignUpForm extends GetView<AuthController> {
  const _SignUpForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
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
          // Fields slide inside this padded lane (clipped ΓÇö never to screen edge).
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
          Obx(() {
            final step = controller.registerStep.value;
            final loading = controller.isLoading.value;
            if (step == 0) {
              return _AuthPrimaryButton(
                label: AppStrings.next,
                icon: Icons.arrow_forward,
                isLoading: false,
                onPressed: () {
                  FormErrorHost.activateFor(controller.registerPart1FormKey);
                  controller.goToRegisterPart2();
                },
              );
            }
            return _AuthPrimaryButton(
              label: AppStrings.signUp,
              icon: Icons.person_add_alt_1,
              isLoading: loading,
              onPressed: () {
                FormErrorHost.activateFor(controller.registerPart2FormKey);
                controller.register();
              },
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final step = controller.registerStep.value;
            // Part 1: labeled divider; Part 2: line only ΓÇö same vertical chrome.
            return SocialDivider(
              label: step == 0 ? AppStrings.signInWith : null,
              fontSize: 12,
            );
          }),
          const SizedBox(height: 12),
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
            return AuthOutlineButton(
              label: AppStrings.back,
              onPressed: () {
                FormErrorHost.clearAll();
                controller.goToRegisterPart1();
              },
              leading: Icon(
                Icons.arrow_back,
                size: 20,
                color: context.appColors.heading,
              ),
            );
          }),
          const SizedBox(height: 8),
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
              TextButton(
                onPressed: () {
                  FormErrorHost.clearAll();
                  controller.showSignIn();
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.scheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: const Size(44, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.signIn,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.scheme.primary,
                  ),
                ),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
    final primary = context.scheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.accentLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accentLight,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.accentLight),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: kAuthButtonFontSize,
                      fontWeight: kAuthButtonFontWeight,
                      color: AppColors.accentLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
