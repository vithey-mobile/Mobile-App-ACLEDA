import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';
import 'package:aub_connect_app/modules/auth/onboarding/onboarding_controller.dart';
import 'package:intl/intl.dart';

enum AuthIntent { signIn, register }

class AuthController extends GetxController {
  AuthController(
    this._authRepository, {
    this.fadeContentIn = false,
  });

  final AuthRepository _authRepository;

  /// When true, crossfade from onboarding backdrop into Auth UI.
  final bool fadeContentIn;

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

  /// Intro morph: 0 = onboarding waves, 1 = full teal (Auth).
  final bgMorph = 1.0.obs;

  /// Intro morph: sheet + forms slide/fade in over teal.
  final layoutReveal = 1.0.obs;

  /// Intro morph: auth chrome + forms opacity.
  final contentOpacity = 1.0.obs;

  final isBusy = false.obs;

  DateTime? dateOfBirth;

  GoogleAccountSummary? selectedGoogleAccount;

  /// Keep Google UI visible; set ENABLE_GOOGLE_AUTH=true in .env when ready.
  bool get isGoogleAuthEnabled => Get.find<FeatureFlags>().enableGoogleAuth;

  @override
  void onInit() {
    super.onInit();
    final startOnSignUp = Get.currentRoute == AppRoutes.register;
    authPageIndex.value = startOnSignUp ? 1 : 0;

    if (fadeContentIn) {
      contentOpacity.value = 0;
      layoutReveal.value = 0;
      bgMorph.value = 0;
      _enterFromOnboarding();
    }
  }

  Future<void> _enterFromOnboarding() async {
    await IntroMorph.run(IntroMorph.duration, (t) {
      if (isClosed) return;
      bgMorph.value = t;
      layoutReveal.value = t;
      contentOpacity.value = t;
    });
    if (!isClosed) {
      layoutReveal.value = 1;
      contentOpacity.value = 1;
      bgMorph.value = 1;
    }
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

  /// Leave Auth toward Onboarding (morph when this is the root intro route).
  Future<void> goBack() async {
    if (isBusy.value) return;

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }

    isBusy.value = true;
    await Get.find<LocalStorageService>().setOnboardingCompleted(false);
    IntroMorph.fromAuth = true;
    IntroMorph.initialOnboardingPage = OnboardingController.totalPages - 1;
    Get.offAllNamed(AppRoutes.onboarding);
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
    // UI chooser/confirmation is always available (mock or pre-Auth0).
    // Real provider handoff remains behind adapter / mock auth repository.
    authIntent.value = intent;
    selectedGoogleAccount = null;
    Get.toNamed(AppRoutes.googleAccountChooser);
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

  /// Exit Google UI flow → Sign In / Register.
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
