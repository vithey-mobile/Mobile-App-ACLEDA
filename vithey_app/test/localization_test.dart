import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/localization/app_translations.dart';
import 'package:aub_connect_app/core/localization/locale_service.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('LocaleService code conversion', () {
    expect(LocaleService.localeFromCode('en'), LocaleService.enLocale);
    expect(LocaleService.localeFromCode('km'), LocaleService.kmLocale);
    expect(LocaleService.localeFromCode('invalid'), LocaleService.enLocale);

    expect(LocaleService.codeFromLocale(const Locale('en', 'US')), 'en');
    expect(LocaleService.codeFromLocale(const Locale('km', 'KH')), 'km');
    expect(LocaleService.codeFromLocale(null), 'en');
  });

  test('AppTranslations dictionary completeness', () {
    final translations = AppTranslations();
    final en = translations.keys['en_US'];
    final km = translations.keys['km_KH'];

    expect(en, isNotNull);
    expect(km, isNotNull);

    // Verify key mappings from Figma
    expect(en!['privacy'], 'Privacy');
    expect(km!['privacy'], 'ឯកជនភាព');

    expect(en['setting'], 'Setting');
    expect(km['setting'], 'ការកំណត់');

    expect(en['logout'], 'Logout');
    expect(km['logout'], 'ចាកចេញ');

    expect(en['sign in'], 'Sign In');
    expect(km['sign in'], 'ចូល');

    expect(en['Preferences'], 'Preferences');
    expect(km['Preferences'], 'ការកំណត់ផ្ទាល់ខ្លួន');
  });

  testWidgets('Renders Khmer translations correctly', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: LocaleService.kmLocale,
        fallbackLocale: LocaleService.enLocale,
        localizationsDelegates: LocaleService.localizationsDelegates,
        supportedLocales: LocaleService.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('privacy'.tr),
                  Text('Settings'.tr),
                  Text('Preferences'.tr),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('ឯកជនភាព'), findsOneWidget);
    expect(find.text('ការកំណត់'), findsOneWidget);
    expect(find.text('ការកំណត់ផ្ទាល់ខ្លួន'), findsOneWidget);
  });

  testWidgets('Renders English translations correctly', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: LocaleService.enLocale,
        fallbackLocale: LocaleService.enLocale,
        localizationsDelegates: LocaleService.localizationsDelegates,
        supportedLocales: LocaleService.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('privacy'.tr),
                  Text('Settings'.tr),
                  Text('Preferences'.tr),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Setting'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
  });

  testWidgets('Renders CV and Map translations correctly in Khmer', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: LocaleService.kmLocale,
        fallbackLocale: LocaleService.enLocale,
        localizationsDelegates: LocaleService.localizationsDelegates,
        supportedLocales: LocaleService.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('Fill sections manually'.tr),
                  Text('Search this area'.tr),
                  Text('Post actions'.tr),
                  Text('Templates'.tr),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('បំពេញផ្នែកដោយដៃ'), findsOneWidget);
    expect(find.text('ស្វែងរកតំបន់នេះ'), findsOneWidget);
    expect(find.text('សកម្មភាពលើការបង្ហោះ'), findsOneWidget);
    expect(find.text('ទម្រង់គំរូ'), findsOneWidget);
  });

  testWidgets('Renders feed and profile action translations correctly in Khmer', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: LocaleService.kmLocale,
        fallbackLocale: LocaleService.enLocale,
        localizationsDelegates: LocaleService.localizationsDelegates,
        supportedLocales: LocaleService.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('No apply job history'.tr),
                  Text('Save comment'.tr),
                  Text('Discard changes?'.tr),
                  Text('Create your first poster'.tr),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('មិនទាន់មានប្រវត្តិដាក់ពាក្យទេ'), findsOneWidget);
    expect(find.text('រក្សាទុកមតិយោបល់'), findsOneWidget);
    expect(find.text('បោះបង់ការផ្លាស់ប្តូរ?'), findsOneWidget);
    expect(find.text('បង្កើតការបង្ហោះដំបូងរបស់អ្នក'), findsOneWidget);
  });
}

