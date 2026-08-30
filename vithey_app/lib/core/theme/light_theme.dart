import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

ThemeData buildLightTheme() {
  const semantic = AppSemanticColors.light;
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.accentLight,
      onSurface: AppColors.titleLight,
      onSurfaceVariant: AppColors.bodyLight,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.accentLight,
    canvasColor: AppColors.accentLight,
    cardColor: AppColors.accentLight,
    dividerColor: AppColors.borderLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.accentLight,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.accentLight,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.accentLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.accentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: semantic.inputFill,
      hintStyle: const TextStyle(color: AppColors.bodyLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accentLight,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    extensions: const [semantic],
  );
}
