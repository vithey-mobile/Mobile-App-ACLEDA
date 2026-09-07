import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/modules/auth/intro_ribbon_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';
import 'package:intl/intl.dart';

enum AuthIntent { signIn, register, changeEmail }

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

  Completer<String?>? _emailChangeCompleter;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotPasswordEmailController = TextEditingController();

  /// Auth v2: 0 = Sign In, 1 = Sign Up (synced from intro ribbon).
  final authPageIndex = 0.obs;

  /// Sign Up only: 0 = Part 1 (credentials), 1 = Part 2 (profile).
  final registerStep = 0.obs;

  /// True while Part 1 ↔ Part 2 field slide is running.
  final isRegisterStepAnimating = false.obs;

  final isBusy = false.obs;

  DateTime? dateOfBirth;

  GoogleAccountSummary? selectedGoogleAccount;

  /// Keep Google UI visible; set ENABLE_GOOGLE_AUTH=true in .env when ready.
  bool get isGoogleAuthEnabled => Get.find<FeatureFlags>().enableGoogleAuth;

  @override
  void onInit() {
    super.onInit();
    final startOnSignUp =
        Get.currentRoute == AppRoutes.register || IntroMorph.startOnSignUp;
    authPageIndex.value = startOnSignUp ? 1 : 0;
  }

  void showSignIn() {
    if (isRegisterStepAnimating.value || authPageIndex.value == 0) return;
    clearError();
    registerStep.value = 0;
    if (Get.isRegistered<IntroRibbonController>()) {
      Get.find<IntroRibbonController>().showSignIn();
      return;
    }
    authPageIndex.value = 0;
  }

  void showSignUp() {
    if (isRegisterStepAnimating.value || authPageIndex.value == 1) return;
    clearError();
    registerStep.value = 0;
    if (Get.isRegistered<IntroRibbonController>()) {
      Get.find<IntroRibbonController>().showSignUp();
      return;
    }
    authPageIndex.value = 1;
  }

  /// Leave Auth → slide back on the intro ribbon (or pop if stacked).
  Future<void> goBack() async {
    if (isBusy.value) return;
    if (Get.isRegistered<IntroRibbonController>()) {
      await Get.find<IntroRibbonController>().authBack();
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  void clearError() {
    if (errorMessage.isNotEmpty) errorMessage.value = '';
  }

  String? confirmPasswordValidator(String? value) {
    return Validators.confirmPassword(value, passwordController.text);
  }

  Future<void> goToRegisterPart2() async {
    if (isRegisterStepAnimating.value || registerStep.value == 1) return;
    if (!await FormErrorHost.submit(registerPart1FormKey)) return;
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
    if (!await FormErrorHost.submit(loginFormKey)) return;
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
    if (!await FormErrorHost.submit(registerPart2FormKey)) return;
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
    // UI chooser/confirmation is always available (mock or pre-Auth0).
    // Real provider handoff remains behind adapter / mock auth repository.
    authIntent.value = intent;
    selectedGoogleAccount = null;
    Get.toNamed(AppRoutes.googleAccountChooser);
  }

  /// Opens the same Google chooser used at sign-up, but returns the chosen
  /// email to Account → Edit (does not sign the user out / re-auth session).
  Future<String?> beginGoogleEmailChange() {
    authIntent.value = AuthIntent.changeEmail;
    selectedGoogleAccount = null;
    _emailChangeCompleter = Completer<String?>();
    Get.toNamed(AppRoutes.googleAccountChooser);
    return _emailChangeCompleter!.future;
  }

  Future<void> selectGoogleAccount(GoogleAccountSummary account) async {
    selectedGoogleAccount = account;
    await Get.toNamed(AppRoutes.googleAuthConfirmation);
  }

  /// Success dialog only (3s). Caller fades then navigates to Screen 2.
  Future<void> promptGoogleAccountAdded() async {
    final context = Get.overlayContext;
    if (context != null) {
      showConfirmDialog(
        context: context,
        title: 'Success',
        message: 'New account added successfully.',
        confirmLabel: AppStrings.confirm,
        barrierDismissible: false,
      );
    }
    await Future<void>.delayed(const Duration(seconds: 3));
    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
    selectedGoogleAccount = const GoogleAccountSummary(
      displayName: MockIdentities.mockUserFullName,
      email: 'molika.ops@aub.edu.kh',
    );
  }

  /// Add Account (legacy): dialog then Screen 2.
  Future<void> addGoogleAccount() async {
    await promptGoogleAccountAdded();
    Get.toNamed(AppRoutes.googleAuthConfirmation);
  }

  /// Bottom primary path — confirm with fixture account.
  Future<void> newGoogleSignIn() async {
    await selectGoogleAccount(
      const GoogleAccountSummary(
        displayName: MockIdentities.mockUserFullName,
        email: 'molika.ops@aub.edu.kh',
      ),
    );
  }

  Future<void> completeGoogleAuth() async {
    final account = selectedGoogleAccount;
    if (account == null) return;
    isGoogleLoading.value = true;
    clearError();
    try {
      if (authIntent.value == AuthIntent.changeEmail) {
        _finishEmailChange(account.email);
        return;
      }

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

  /// Cancel confirmation → back to chooser (Screen 1).
  void backToGoogleChooser() {
    if (Get.currentRoute == AppRoutes.googleAuthConfirmation) {
      Get.back();
      return;
    }
    cancelGoogleAuth();
  }

  /// Exit Google UI flow → Sign In / Register, or Account edit for email change.
  void cancelGoogleAuth() {
    selectedGoogleAccount = null;
    if (authIntent.value == AuthIntent.changeEmail) {
      _finishEmailChange(null);
      return;
    }
    Get.until((route) => _isIntroRibbonRoute(route.settings.name));
  }

  static bool _isIntroRibbonRoute(String? name) {
    return name == AppRoutes.login ||
        name == AppRoutes.register ||
        name == AppRoutes.auth ||
        name == AppRoutes.selectLanguage ||
        name == AppRoutes.onboarding;
  }

  void _finishEmailChange(String? email) {
    selectedGoogleAccount = null;
    final completer = _emailChangeCompleter;
    _emailChangeCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(email);
    }
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.settingsEditAccount ||
          route.settings.name == AppRoutes.settingsAccount ||
          route.isFirst,
    );
  }

  Future<void> requestPasswordReset() async {
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
    this.photoUrl,
  });

  final String displayName;
  final String email;
  final String? photoUrl;

  String get firstName {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? displayName : parts.first;
  }
}
