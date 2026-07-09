import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';

enum AuthIntent { signIn, register }

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isForgotPasswordLoading = false.obs;
  final forgotPasswordSuccess = false.obs;
  final errorMessage = ''.obs;
  final forgotPasswordError = ''.obs;
  final authIntent = AuthIntent.signIn.obs;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotPasswordEmailController = TextEditingController();

  GoogleAccountSummary? selectedGoogleAccount;

  /// Keep Google UI visible; set ENABLE_GOOGLE_AUTH=true in .env when ready.
  bool get isGoogleAuthEnabled => Get.find<FeatureFlags>().enableGoogleAuth;

  void clearError() {
    if (errorMessage.isNotEmpty) errorMessage.value = '';
  }

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await AuthNavigation.goAfterAuth();
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );
      await AuthNavigation.goAfterAuth(isNewUser: true);
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  void beginGoogleAuth({required AuthIntent intent}) {
    if (!isGoogleAuthEnabled) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.googleAuthComingSoon,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        messageText: Text(
          '${AppStrings.googleAuthComingSoon}\n${AppStrings.googleAuthEnvHint}',
          style: const TextStyle(color: Colors.white),
        ),
      );
      return;
    }
    authIntent.value = intent;
    Get.toNamed(AppRoutes.googleAccountChooser);
  }

  Future<void> selectGoogleAccount(GoogleAccountSummary account) async {
    selectedGoogleAccount = account;
    Get.toNamed(AppRoutes.googleAuthConfirmation);
  }

  Future<void> completeGoogleAuth() async {
    final account = selectedGoogleAccount;
    if (account == null) return;
    isGoogleLoading.value = true;
    clearError();
    try {
      await _authRepository.completeGoogleAuth(
        email: account.email,
        displayName: account.displayName,
      );
      final isRegister = authIntent.value == AuthIntent.register;
      await AuthNavigation.goAfterAuth(isNewUser: isRegister);
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void cancelGoogleAuth() {
    selectedGoogleAccount = null;
    Get.until((route) => route.settings.name == AppRoutes.login || route.settings.name == AppRoutes.register);
  }

  Future<void> requestPasswordReset() async {
    if (!(forgotPasswordFormKey.currentState?.validate() ?? false)) return;
    isForgotPasswordLoading.value = true;
    forgotPasswordError.value = '';
    try {
      await _authRepository.requestPasswordReset(
        email: forgotPasswordEmailController.text.trim(),
      );
      forgotPasswordSuccess.value = true;
    } on AuthServiceException catch (e) {
      forgotPasswordError.value = e.message;
    } catch (_) {
      forgotPasswordError.value = AppStrings.errorGeneric;
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  void resetForgotPasswordState() {
    forgotPasswordSuccess.value = false;
    forgotPasswordError.value = '';
    forgotPasswordEmailController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}

class GoogleAccountSummary {
  const GoogleAccountSummary({
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;
}
