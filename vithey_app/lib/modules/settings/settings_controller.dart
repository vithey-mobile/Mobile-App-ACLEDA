import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/local/search_recent_store.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._settingsRepository, this._authRepository, this._localStorage);

  final SettingsRepository _settingsRepository;
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  final isDarkMode = false.obs;
  final languageCode = 'en'.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final settings = await _settingsRepository.loadSettings();
      isDarkMode.value = settings.themeMode == 'dark';
      languageCode.value = settings.language;
    } finally {
      isLoading.value = false;
    }
  }

  String get languageLabel {
    switch (languageCode.value) {
      case 'km':
        return 'Khmer';
      default:
        return 'English (US)';
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(mode);
    await _settingsRepository.saveThemeMode(AppTheme.toStorage(mode));
  }

  void openLanguagePicker() {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('English (US)'),
              trailing: languageCode.value == 'en' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () => _selectLanguage('en'),
            ),
            ListTile(
              title: const Text('Khmer'),
              trailing: languageCode.value == 'km' ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () => _selectLanguage('km'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Get.context!.scheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }

  Future<void> _selectLanguage(String code) async {
    languageCode.value = code;
    await _settingsRepository.saveLanguage(code);
    Get.back();
    Get.snackbar('Vithey', 'Language preference saved');
  }

  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Log out',
      message: 'Are you sure you want to log out of Vithey?',
      confirmLabel: 'Log out',
    );
    if (confirmed != true) return;

    try {
      if (Get.isRegistered<FcmService>()) {
        await Get.find<FcmService>().unregisterToken();
      }
      if (Get.isRegistered<NotificationRepository>()) {
        Get.find<NotificationRepository>().clearSession();
      }
      await _authRepository.logout();
      await _localStorage.clearSessionPreferences();
      if (Get.isRegistered<SearchRecentStore>()) {
        await Get.find<SearchRecentStore>().clearAll();
      }
    } catch (_) {}
    Get.offAllNamed(AppRoutes.auth);
  }
}
