import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _onboardingKey = 'onboarding_completed';
  static const _startupKey = 'startup_completed';
  static const _verificationStatusKey = 'verification_status';
  static const _verificationStudentIdKey = 'verification_student_id';
  static const _verificationEmailKey = 'verification_email';
  static const _verificationSubmittedAtKey = 'verification_submitted_at';
  static const _verificationDocumentKey = 'verification_document_file_name';
  static const _privacyProfileVisibleKey = 'privacy_profile_visible';
  static const _privacyDataSharingKey = 'privacy_data_sharing';
  static const _privacyActivityTrackingKey = 'privacy_activity_tracking';
  static const _biometricEnabledKey = 'biometric_enabled';

  Future<String?> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  Future<String> readLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> isStartupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_startupKey) ?? false;
  }

  Future<void> setStartupCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_startupKey, value);
  }

  Future<String?> readVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_verificationStatusKey);
  }

  Future<void> saveVerificationStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationStatusKey, status);
  }

  Future<void> saveVerificationDraft({
    required String studentId,
    required String universityEmail,
    required String submittedAtIso,
    String? documentFileName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationStudentIdKey, studentId);
    await prefs.setString(_verificationEmailKey, universityEmail);
    await prefs.setString(_verificationSubmittedAtKey, submittedAtIso);
    if (documentFileName != null && documentFileName.isNotEmpty) {
      await prefs.setString(_verificationDocumentKey, documentFileName);
    } else {
      await prefs.remove(_verificationDocumentKey);
    }
  }

  Future<void> clearVerificationDocument() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationDocumentKey);
  }

  Future<Map<String, String?>> readVerificationDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'studentId': prefs.getString(_verificationStudentIdKey),
      'universityEmail': prefs.getString(_verificationEmailKey),
      'submittedAt': prefs.getString(_verificationSubmittedAtKey),
      'documentFileName': prefs.getString(_verificationDocumentKey),
    };
  }

  Future<void> clearVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationStatusKey);
    await prefs.remove(_verificationStudentIdKey);
    await prefs.remove(_verificationEmailKey);
    await prefs.remove(_verificationSubmittedAtKey);
    await prefs.remove(_verificationDocumentKey);
  }

  Future<bool> readPrivacyProfileVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyProfileVisibleKey) ?? true;
  }

  Future<bool> readPrivacyDataSharing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyDataSharingKey) ?? false;
  }

  Future<bool> readPrivacyActivityTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyActivityTrackingKey) ?? false;
  }

  Future<void> savePrivacySettings({
    bool? profileVisible,
    bool? dataSharing,
    bool? activityTracking,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileVisible != null) await prefs.setBool(_privacyProfileVisibleKey, profileVisible);
    if (dataSharing != null) await prefs.setBool(_privacyDataSharingKey, dataSharing);
    if (activityTracking != null) await prefs.setBool(_privacyActivityTrackingKey, activityTracking);
  }

  Future<bool> readBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> saveBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, value);
  }

  Future<void> clearSessionPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_startupKey);
  }
}
