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
  bool get useMockApi => !_isFalse(dotenv.env['USE_MOCK_API']);

  bool get useMockAuth => _isTrue(dotenv.env['USE_MOCK_AUTH']);

  bool get useMockAi {
    final mockAi = dotenv.env['USE_MOCK_AI'];
    if (mockAi != null) return !_isFalse(mockAi);
    return useMockApi;
  }

  bool get useMockSearch {
    final mockSearch = dotenv.env['USE_MOCK_SEARCH'];
    if (mockSearch != null) return !_isFalse(mockSearch);
    return useMockApi;
  }

  bool get useMockChat =>
      _isTrue(dotenv.env['USE_MOCK_CHAT']) || useMockApi;

  bool get useMockNotifications =>
      _isTrue(dotenv.env['USE_MOCK_NOTIFICATIONS']) || useMockApi;

  bool get enableGoogleAuth => _isTrue(dotenv.env['ENABLE_GOOGLE_AUTH']);

  bool get fcmEnabled => _isTrue(dotenv.env['FCM_ENABLED']);

  bool get useRealApi => !useMockApi;

  bool get isProduction => _config.environment.isProduction;

  /// Demo-only controls (mock status cycle, etc.) — hidden in production builds.
  bool get showMockDevTools => !isProduction && useMockApi;

  AppEnvironment get environment => _config.environment;
}
