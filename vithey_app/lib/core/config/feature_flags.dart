import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/environment.dart';

/// Central feature flags — repositories must read mock/real mode from here only.
class FeatureFlags {
  FeatureFlags({AppConfig? config}) : _config = config ?? AppConfig.instance;

  final AppConfig _config;

  static bool _isFalse(String? value) => value?.toLowerCase() == 'false';
  static bool _isTrue(String? value) => value?.toLowerCase() == 'true';

  /// Global API mock fallback when individual module flags are unset.
  /// Always off in production builds.
  bool get useMockApi =>
      !isProduction && !_isFalse(dotenv.env['USE_MOCK_API']);

  bool get useMockAuth =>
      !isProduction && _isTrue(dotenv.env['USE_MOCK_AUTH']);

  bool get useMockAi {
    if (isProduction) return false;
    final mockAi = dotenv.env['USE_MOCK_AI'];
    if (mockAi != null) return !_isFalse(mockAi);
    return useMockApi;
  }

  bool get useMockSearch {
    if (isProduction) return false;
    final mockSearch = dotenv.env['USE_MOCK_SEARCH'];
    if (mockSearch != null) return !_isFalse(mockSearch);
    return useMockApi;
  }

  bool get useMockChat =>
      !isProduction &&
      (_isTrue(dotenv.env['USE_MOCK_CHAT']) || useMockApi);

  bool get useMockNotifications =>
      !isProduction &&
      (_isTrue(dotenv.env['USE_MOCK_NOTIFICATIONS']) || useMockApi);

  bool get useMockMap {
    if (isProduction) return false;
    final mockMap = dotenv.env['USE_MOCK_MAP'];
    if (mockMap != null) return !_isFalse(mockMap);
    return useMockApi;
  }

  bool get enableGoogleAuth => _isTrue(dotenv.env['ENABLE_GOOGLE_AUTH']);

  bool get fcmEnabled => _isTrue(dotenv.env['FCM_ENABLED']);

  bool get useRealApi => !useMockApi;

  bool get isProduction => _config.environment.isProduction;

  /// Demo-only controls (mock status cycle, etc.) — hidden in production builds.
  bool get showMockDevTools => !isProduction && useMockApi;

  /// Dev-only: Splash always opens Onboarding, ignoring token / completed flag.
  /// Set `FORCE_SHOW_ONBOARDING=false` in `.env` when done testing.
  bool get forceShowOnboarding =>
      !isProduction && _isTrue(dotenv.env['FORCE_SHOW_ONBOARDING']);

  /// Dev-only: after Auth always open Startup, ignoring `startup_completed`.
  /// Set `FORCE_SHOW_STARTUP=false` when done testing.
  bool get forceShowStartup =>
      !isProduction && _isTrue(dotenv.env['FORCE_SHOW_STARTUP']);

  /// Dev-only: walk the full funnel every cold start / hot restart:
  /// Splash → Onboarding → Auth → Startup → Home.
  /// Clears session + completed flags, then starts at Onboarding.
  bool get forceDevFunnel =>
      !isProduction && _isTrue(dotenv.env['FORCE_DEV_FUNNEL']);

  AppEnvironment get environment => _config.environment;
}
