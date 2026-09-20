import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/app.dart';
import 'package:aub_connect_app/core/di/app_bindings.dart';
import 'package:aub_connect_app/core/localization/locale_service.dart';
import 'package:aub_connect_app/core/theme/vithey_system_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw under the status bar; overlays stay transparent so each screen's
  // own background shows through ([VitheySystemUi] / [VitheyStatusBar]).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    VitheySystemUi.forBackground(Colors.white),
  );
  final themeMode = await AppBindings.init();
  Get.changeThemeMode(themeMode);
  final initialLocale = await LocaleService.loadSavedLocale();
  runApp(VitheyApp(themeMode: themeMode, initialLocale: initialLocale));
}
