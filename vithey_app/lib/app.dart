import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/core/utils/connectivity_wrapper.dart';
import 'package:aub_connect_app/routes/app_pages.dart';

class VitheyApp extends StatelessWidget {
  const VitheyApp({super.key, required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vithey App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) => ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
