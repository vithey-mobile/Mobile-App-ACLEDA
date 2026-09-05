import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';

class NotificationPreferencesController extends GetxController {
  NotificationPreferencesController(
    this._settingsRepository,
    this._fcmService,
  );

  final SettingsRepository _settingsRepository;
  final FcmService _fcmService;

  final preferences = const NotificationPreferences().obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  NotificationPreferences _saved = const NotificationPreferences();

  bool get categoriesEnabled => preferences.value.allowNotifications;
  bool get hasChanges => preferences.value != _saved;
  bool get canSave => hasChanges && !isSaving.value;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    isLoading.value = true;
    try {
      final loaded = await _settingsRepository.loadNotificationPreferences();
      _saved = loaded;
      preferences.value = loaded;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAllowNotifications(bool value) async {
    if (value && !await _ensureNotificationPermission()) return;
    preferences.value = preferences.value.copyWith(allowNotifications: value);
  }

  void toggleChatMessages(bool value) {
    if (!categoriesEnabled) return;
    preferences.value = preferences.value.copyWith(chatMessages: value);
  }

  void toggleReminders(bool value) {
    if (!categoriesEnabled) return;
    preferences.value = preferences.value.copyWith(reminders: value);
  }

  void toggleAnnouncements(bool value) {
    if (!categoriesEnabled) return;
    preferences.value = preferences.value.copyWith(announcements: value);
  }

  void toggleAppUpdates(bool value) {
    if (!categoriesEnabled) return;
    preferences.value = preferences.value.copyWith(appUpdates: value);
  }

  Future<void> savePreferences() async {
    if (!canSave) return;
    isSaving.value = true;
    final draft = preferences.value;
    try {
      await _settingsRepository.saveNotificationPreferences(draft);
      _saved = draft;

      try {
        if (draft.allowNotifications) {
          await _fcmService.registerToken();
        } else {
          await _fcmService.unregisterToken();
        }
      } catch (_) {
        Get.snackbar(
          'Vithey',
          'Preferences saved, but push registration could not be updated',
        );
        return;
      }

      Get.snackbar('Vithey', 'Notification preferences saved');
    } catch (error) {
      Get.snackbar(
        'Vithey',
        error.toString().replaceFirst('SettingsServiceException: ', ''),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> _ensureNotificationPermission() async {
    final current = await Permission.notification.status;
    if (current.isGranted || current.isLimited) return true;

    final requested = await Permission.notification.request();
    if (requested.isGranted || requested.isLimited) return true;

    if (requested.isPermanentlyDenied) {
      Get.snackbar(
        'Notifications are disabled',
        'Enable notification permission in system settings.',
        // GetX types SnackbarController.mainButton as TextButton?;
        // VitheyTextLink extends TextButton so it satisfies the type.
        mainButton: VitheyTextLink(
          label: 'Open settings',
          onPressed: openAppSettings,
        ),
      );
    } else {
      Get.snackbar(
        'Notifications are disabled',
        'Notification permission was not granted.',
      );
    }
    return false;
  }
}
