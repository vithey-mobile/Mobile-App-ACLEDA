import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/auth_wave_header.dart';
import 'package:aub_connect_app/modules/auth/widgets/oauth_button.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthWaveHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.welcomeBack,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.authHeading,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
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
                        hint: AppStrings.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: Validators.password,
                        onChanged: (_) => controller.clearError(),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: AppStrings.signIn,
                              icon: Icons.login,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                            ),
                          )),
                      const SizedBox(height: 20),
                      const SocialDivider(label: AppStrings.signInWith),
                      const SizedBox(height: 16),
                      Obx(() => OAuthButton(
                            label: AppStrings.continueWithGoogle,
                            isLoading: controller.isGoogleLoading.value,
                            onPressed: () => controller.beginGoogleAuth(intent: AuthIntent.signIn),
                          )),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(AppStrings.noAccount, style: TextStyle(color: AppColors.authMuted)),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.register),
                            child: const Text(AppStrings.signUp, style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthWaveHeader(heightFactor: 0.29),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: controller.registerFormKey,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.createAccount,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.authHeading,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
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
                        hint: AppStrings.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: Validators.password,
                        onChanged: (_) => controller.clearError(),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: AppStrings.signUp,
                              icon: Icons.person_add_alt_1,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.register,
                            ),
                          )),
                      const SizedBox(height: 20),
                      const SocialDivider(label: AppStrings.signInWith),
                      const SizedBox(height: 16),
                      Obx(() => OAuthButton(
                            label: AppStrings.continueWithGoogle,
                            isLoading: controller.isGoogleLoading.value,
                            onPressed: () => controller.beginGoogleAuth(intent: AuthIntent.register),
                          )),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(AppStrings.hasAccount, style: TextStyle(color: AppColors.authMuted)),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text(AppStrings.signIn, style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
