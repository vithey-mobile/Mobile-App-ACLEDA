import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:intl/intl.dart';

enum AuthIntent { signIn, register }

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final loginFormKey = GlobalKey<FormState>();
  final registerPart1FormKey = GlobalKey<FormState>();
  final registerPart2FormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isForgotPasswordLoading = false.obs;
  final forgotPasswordSuccess = false.obs;
  final errorMessage = ''.obs;
  final forgotPasswordError = ''.obs;
  final authIntent = AuthIntent.signIn.obs;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotPasswordEmailController = TextEditingController();

  /// Auth v2: 0 = Sign In, 1 = Sign Up. Switch only via footer toggle buttons.
  final authPageIndex = 0.obs;

  /// True while the Sign In ↔ Sign Up height morph is running.
  final isPanelAnimating = false.obs;

  /// Sign Up only: 0 = Part 1 (credentials), 1 = Part 2 (profile).
  final registerStep = 0.obs;

  /// True while Part 1 ↔ Part 2 field slide is running.
  final isRegisterStepAnimating = false.obs;

  DateTime? dateOfBirth;

  GoogleAccountSummary? selectedGoogleAccount;

  /// Keep Google UI visible; set ENABLE_GOOGLE_AUTH=true in .env when ready.
  bool get isGoogleAuthEnabled => Get.find<FeatureFlags>().enableGoogleAuth;

  @override
  void onInit() {
    super.onInit();
    final startOnSignUp = Get.currentRoute == AppRoutes.register;
    authPageIndex.value = startOnSignUp ? 1 : 0;
  }

  void showSignIn() {
    if (isPanelAnimating.value ||
        isRegisterStepAnimating.value ||
        authPageIndex.value == 0) {
      return;
    }
    clearError();
    registerStep.value = 0;
    authPageIndex.value = 0;
  }

  void showSignUp() {
    if (isPanelAnimating.value ||
        isRegisterStepAnimating.value ||
        authPageIndex.value == 1) {
      return;
    }
    clearError();
    registerStep.value = 0;
    authPageIndex.value = 1;
  }

  void clearError() {
    if (errorMessage.isNotEmpty) errorMessage.value = '';
  }

  String? confirmPasswordValidator(String? value) {
    return Validators.confirmPassword(value, passwordController.text);
  }

  Future<void> goToRegisterPart2() async {
    if (isRegisterStepAnimating.value || registerStep.value == 1) return;
    if (!(registerPart1FormKey.currentState?.validate() ?? false)) return;
    clearError();
    registerStep.value = 1;
  }

  void goToRegisterPart1() {
    if (isRegisterStepAnimating.value ||
        isLoading.value ||
        registerStep.value == 0) {
      return;
    }
    clearError();
    registerStep.value = 0;
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initial = dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    dateOfBirth = picked;
    dateOfBirthController.text = DateFormat('dd MMM yyyy').format(picked);
    clearError();
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
    if (registerStep.value != 1) return;
    if (!(registerPart2FormKey.currentState?.validate() ?? false)) return;
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
    Get.until((route) =>
        route.settings.name == AppRoutes.login ||
        route.settings.name == AppRoutes.register ||
        route.settings.name == AppRoutes.auth);
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
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
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
