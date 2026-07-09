import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';
import 'package:aub_connect_app/data/services/settings_service.dart';

class SettingsRepository {
  SettingsRepository(this._settingsService, this._localStorage, this._flags);

  final SettingsService _settingsService;
  final LocalStorageService _localStorage;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockApi;

  Future<UserSettingsModel> loadSettings() async {
    final theme = await _localStorage.readThemeMode();
    final language = await _localStorage.readLanguage();
    final privacy = await _loadLocalPrivacy();

    final local = UserSettingsModel(
      themeMode: theme ?? 'light',
      language: language,
      privacy: privacy,
    );

    if (useMockApi) return local;

    try {
      final remote = await _settingsService.getSettings();
      await _persistLocal(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<PrivacySettings> loadPrivacySettings() async {
    if (useMockApi) return _loadLocalPrivacy();

    try {
      final remote = await _settingsService.getSettings();
      await _localStorage.savePrivacySettings(
        profileVisible: remote.privacy.profileVisible,
        dataSharing: remote.privacy.dataSharing,
        activityTracking: remote.privacy.activityTracking,
      );
      return remote.privacy;
    } catch (_) {
      return _loadLocalPrivacy();
    }
  }

  Future<void> saveThemeMode(String value) async {
    await _localStorage.saveThemeMode(value);
    if (!useMockApi) {
      try {
        await _settingsService.updateSettings({'theme_mode': value});
      } catch (_) {}
    }
  }

  Future<void> saveLanguage(String value) async {
    await _localStorage.saveLanguage(value);
    if (!useMockApi) {
      try {
        await _settingsService.updateSettings({'language': value});
      } catch (_) {}
    }
  }

  Future<void> savePrivacySettings(PrivacySettings settings) async {
    await _localStorage.savePrivacySettings(
      profileVisible: settings.profileVisible,
      dataSharing: settings.dataSharing,
      activityTracking: settings.activityTracking,
    );
    if (!useMockApi) {
      await _settingsService.updateSettings(settings.toJson());
    }
  }

  Future<PrivacySettings> _loadLocalPrivacy() async {
    return PrivacySettings(
      profileVisible: await _localStorage.readPrivacyProfileVisible(),
      dataSharing: await _localStorage.readPrivacyDataSharing(),
      activityTracking: await _localStorage.readPrivacyActivityTracking(),
    );
  }

  Future<void> _persistLocal(UserSettingsModel settings) async {
    await _localStorage.saveThemeMode(settings.themeMode);
    await _localStorage.saveLanguage(settings.language);
    await _localStorage.savePrivacySettings(
      profileVisible: settings.privacy.profileVisible,
      dataSharing: settings.privacy.dataSharing,
      activityTracking: settings.privacy.activityTracking,
    );
  }
}
