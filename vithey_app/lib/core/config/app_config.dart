import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/core/config/environment.dart';

/// Single source of truth for URLs, timeouts, and environment.
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.fcmDebugToken,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig.init() must be called before accessing instance');
    }
    return config;
  }

  static bool get isInitialized => _instance != null;

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String? fcmDebugToken;

  static Future<void> init({String envFileName = '.env'}) async {
    await dotenv.load(fileName: envFileName);
    _instance = AppConfig._fromEnv();
  }

  /// Automatically resolves host aliases across platforms:
  /// - On Android: replaces `localhost` or `127.0.0.1` with `10.0.2.2`
  /// - On iOS/macOS: replaces `10.0.2.2` with `localhost`
  /// - If using a LAN IP (e.g. 192.168.x.x), leaves it untouched for physical devices.
  static String _resolveHost(String url) {
    if (kIsWeb) return url;
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (Platform.isAndroid) {
        if (host == 'localhost' || host == '127.0.0.1') {
          return uri.replace(host: '10.0.2.2').toString();
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        if (host == '10.0.2.2') {
          return uri.replace(host: 'localhost').toString();
        }
      }
    } catch (_) {}
    return url;
  }

  factory AppConfig._fromEnv() {
    const envFromDefine = String.fromEnvironment('APP_ENV', defaultValue: '');
    final envRaw = envFromDefine.isNotEmpty ? envFromDefine : dotenv.env['APP_ENV'];

    final rawApi = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
    final rawWs = dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8080/ws';

    return AppConfig._(
      environment: AppEnvironment.parse(envRaw),
      apiBaseUrl: _resolveHost(rawApi),
      wsBaseUrl: _resolveHost(rawWs),
      connectTimeout: Duration(
        seconds: int.tryParse(dotenv.env['API_CONNECT_TIMEOUT_SECONDS'] ?? '') ?? 15,
      ),
      receiveTimeout: Duration(
        seconds: int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT_SECONDS'] ?? '') ?? 30,
      ),
      fcmDebugToken: dotenv.env['FCM_DEBUG_TOKEN']?.trim(),
    );
  }
}

