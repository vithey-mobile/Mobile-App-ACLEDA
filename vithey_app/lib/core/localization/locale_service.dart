import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Custom delegate wrapping ShadcnLocalizations to safely fallback to English
/// when the user switches to Khmer (or any locale not natively in Shadcn).
class FallbackShadcnLocalizationsDelegate
    extends LocalizationsDelegate<shad.ShadcnLocalizations> {
  const FallbackShadcnLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<shad.ShadcnLocalizations> load(Locale locale) {
    if (shad.ShadcnLocalizations.delegate.isSupported(locale)) {
      return shad.ShadcnLocalizations.delegate.load(locale);
    }
    return shad.ShadcnLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackShadcnLocalizationsDelegate old) => false;
}

class LocaleService {
  LocaleService._();

  static const enLocale = Locale('en', 'US');
  static const kmLocale = Locale('km', 'KH');

  static const supportedLocales = [
    enLocale,
    kmLocale,
  ];

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        const FallbackShadcnLocalizationsDelegate(),
        ...shad.ShadcnLocalizations.localizationsDelegates.skip(1),
      ];

  static Locale localeFromCode(String? code) {
    if (code == 'km') return kmLocale;
    return enLocale;
  }

  static String codeFromLocale(Locale? locale) {
    return locale?.languageCode == 'km' ? 'km' : 'en';
  }

  static final rxLocaleCode = 'en'.obs;

  static bool get isKhmer => rxLocaleCode.value == 'km';

  static String get currentCode => rxLocaleCode.value;

  static Future<Locale> loadSavedLocale() async {
    if (Get.isRegistered<LocalStorageService>()) {
      final code = await Get.find<LocalStorageService>().readLanguage();
      final locale = localeFromCode(code);
      rxLocaleCode.value = locale.languageCode;
      return locale;
    }
    rxLocaleCode.value = 'en';
    return enLocale;
  }

  static Future<void> changeLocale(String code) async {
    final target = localeFromCode(code);
    rxLocaleCode.value = target.languageCode;
    await Get.updateLocale(target);
    if (Get.isRegistered<LocalStorageService>()) {
      await Get.find<LocalStorageService>().saveLanguage(code);
    }
  }
}
