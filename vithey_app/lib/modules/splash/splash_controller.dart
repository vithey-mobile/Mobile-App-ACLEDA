import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  SplashController(
    this._secureStorage,
    this._localStorage,
    this._authRepository,
  );

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final AuthRepository _authRepository;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final start = DateTime.now();
    final hasToken = await _secureStorage.hasAccessToken();
    final onboardingDone = await _localStorage.isOnboardingCompleted();

    if (hasToken) {
      final valid = await _authRepository.validateSession();
      await _waitMinimum(start);
      if (valid) {
        await AuthNavigation.goAfterAuth();
        return;
      }
      await _secureStorage.clearTokens();
    } else {
      await _waitMinimum(start);
    }

    if (!onboardingDone) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _waitMinimum(DateTime start) async {
    const minDuration = Duration(milliseconds: 1500);
    final elapsed = DateTime.now().difference(start);
    if (elapsed < minDuration) {
      await Future<void>.delayed(minDuration - elapsed);
    }
  }
}
