class PrivacySettings {
  const PrivacySettings({
    this.profileVisible = true,
    this.dataSharing = false,
    this.activityTracking = false,
  });

  final bool profileVisible;
  final bool dataSharing;
  final bool activityTracking;

  PrivacySettings copyWith({
    bool? profileVisible,
    bool? dataSharing,
    bool? activityTracking,
  }) {
    return PrivacySettings(
      profileVisible: profileVisible ?? this.profileVisible,
      dataSharing: dataSharing ?? this.dataSharing,
      activityTracking: activityTracking ?? this.activityTracking,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    final privacy = json['privacy'] as Map<String, dynamic>? ?? json;
    return PrivacySettings(
      profileVisible: privacy['profile_visible'] as bool? ?? true,
      dataSharing: privacy['data_sharing'] as bool? ?? false,
      activityTracking: privacy['activity_tracking'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'privacy': {
          'profile_visible': profileVisible,
          'data_sharing': dataSharing,
          'activity_tracking': activityTracking,
        },
      };
}

class UserSettingsModel {
  const UserSettingsModel({
    this.themeMode = 'light',
    this.language = 'en',
    this.privacy = const PrivacySettings(),
  });

  final String themeMode;
  final String language;
  final PrivacySettings privacy;

  UserSettingsModel copyWith({
    String? themeMode,
    String? language,
    PrivacySettings? privacy,
  }) {
    return UserSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      privacy: privacy ?? this.privacy,
    );
  }

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      themeMode: json['theme_mode'] as String? ?? 'light',
      language: json['language'] as String? ?? 'en',
      privacy: PrivacySettings.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'theme_mode': themeMode,
        'language': language,
        ...privacy.toJson(),
      };
}
