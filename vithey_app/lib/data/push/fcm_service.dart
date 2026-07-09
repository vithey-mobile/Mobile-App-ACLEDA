import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/push/notification_router.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';

/// Firebase push wrapper — enable with FCM_ENABLED=true after Firebase setup.
class FcmService {
  FcmService(this._notificationService, this._flags);

  final NotificationService _notificationService;
  final FeatureFlags _flags;

  String? _cachedToken;

  bool get enabled => _flags.fcmEnabled;

  bool get _useMockApi => _flags.useMockNotifications;

  Future<void> init() async {
    if (!enabled) return;

    // When firebase_messaging is configured:
    // await Firebase.initializeApp();
    // FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(handlePushData);
    // final initial = await FirebaseMessaging.instance.getInitialMessage();
    // if (initial != null) handlePushData(initial.data);

    final debugToken = AppConfig.instance.fcmDebugToken;
    if (debugToken != null && debugToken.isNotEmpty) {
      _cachedToken = debugToken;
    }
  }

  Future<void> registerToken() async {
    if (!enabled || _useMockApi) return;

    // final token = _cachedToken ?? await FirebaseMessaging.instance.getToken();
    final token = _cachedToken ?? AppConfig.instance.fcmDebugToken;
    if (token == null || token.isEmpty) return;

    await _notificationService.registerDevice(
      fcmToken: token,
      platform: _platform,
    );
    _cachedToken = token;
  }

  Future<void> unregisterToken() async {
    if (!enabled || _useMockApi) return;
    final token = _cachedToken;
    if (token == null || token.isEmpty) return;

    try {
      await _notificationService.unregisterDevice(token);
    } finally {
      _cachedToken = null;
    }
  }

  void handlePushData(Map<String, dynamic> data) {
    final repository = Get.find<NotificationRepository>();
    final notification = NotificationService.fromJson({
      'id': data['notification_id'] ?? data['id'] ?? '',
      'type': data['type'],
      'event': data['event'],
      'title': data['title'] ?? '',
      'body': data['body'] ?? '',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'actor': {
        if (data['actor_id'] != null) 'id': data['actor_id'],
        if (data['actor_name'] != null) 'full_name': data['actor_name'],
      },
      'destination': {
        'reference_type': data['reference_type'],
        'reference_id': data['reference_id'],
        'post_id': data['post_id'],
        'conversation_id': data['conversation_id'],
        'job_post_id': data['job_post_id'],
        'application_id': data['application_id'],
        'payment_id': data['payment_id'],
        'ai_thread_id': data['ai_thread_id'],
      },
      'dedupe_key': data['dedupe_key'],
    });

    if (notification.id.isNotEmpty) {
      repository.cacheNotification(notification);
      repository.reconcileUnreadCount();
    }

    NotificationRouter.routeFromPushData(data);
  }

  String get _platform {
    if (kIsWeb) return 'ANDROID';
    return Platform.isIOS ? 'IOS' : 'ANDROID';
  }
}
