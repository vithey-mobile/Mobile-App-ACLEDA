import 'dart:async';

import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';

class SplashController extends GetxController {
  SplashController(
    this._secureStorage,
    this._localStorage,
  );

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  static const _splashDuration = Duration(seconds: 2);

  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final routeFuture = _resolveNextRouteLocal();
    final timerFuture = Future<void>.delayed(_splashDuration);

    String route = AppRoutes.onboarding;
    try {
      route = await routeFuture.timeout(
        _splashDuration,
        onTimeout: () => AppRoutes.onboarding,
      );
    } catch (_) {
      route = AppRoutes.login;
    }

    await timerFuture;
    _go(route);
  }

  void _go(String route) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(route);
  }

  Future<String> _resolveNextRouteLocal() async {
    final token = await _secureStorage.readAccessToken().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => null,
    );
    if (token != null && token.startsWith('mock')) {
      unawaited(_secureStorage.clearTokens());
    }

    final hasToken = token != null && token.isNotEmpty && !token.startsWith('mock');
    final onboardingDone = await _localStorage.isOnboardingCompleted().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => false,
    );

    if (hasToken) {
      final startupDone = await _localStorage.isStartupCompleted().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => false,
      );
      if (startupDone) {
        unawaited(AuthNavigation.bootstrapNotificationsIfNeeded());
      }
      return startupDone ? AppRoutes.home : AppRoutes.startupSkills;
    }

    if (!onboardingDone) {
      return AppRoutes.onboarding;
    }
    return AppRoutes.login;
  }
}
