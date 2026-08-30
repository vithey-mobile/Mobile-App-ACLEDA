import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/select_language/select_language_controller.dart';

/// Select Language — UI only; preference saved for future i18n.
class SelectLanguageScreen extends StatelessWidget {
  const SelectLanguageScreen({
    super.key,
    this.contentReveal = 1.0,
    this.interactive = true,
  });

  /// 0 → 1: content rises into place (used by splash handoff).
  final double contentReveal;

  /// When false (splash underlay), taps are ignored.
  final bool interactive;

  static const introDotCount = 4;

  Color _secondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
  }

  @override
  Widget build(BuildContext context) {
    // Avoid red error while Get.offAll disposes this route's controller.
    if (!Get.isRegistered<SelectLanguageController>()) {
      return Scaffold(
        backgroundColor: context.appColors.cardSurface,
        body: const OnboardingBackground(
          waveHeightFactor: OnboardingBackground.onboardingFactor,
        ),
      );
    }
    final controller = Get.find<SelectLanguageController>();

    final heading = context.appColors.heading;
    final secondary = _secondary(context);
    final border = context.appColors.border;
    final reveal = contentReveal.clamp(0.0, 1.0);
    final contentT = Curves.easeOutCubic.transform(reveal);

    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Obx(() {
        if (!Get.isRegistered<SelectLanguageController>()) {
          return const OnboardingBackground(
            waveHeightFactor: OnboardingBackground.onboardingFactor,
          );
        }
        final wave = controller.waveFactor.value;
        final fade = controller.contentOpacity.value;
        final uiOpacity = (contentT * fade).clamp(0.0, 1.0);
        final busy = controller.isBusy.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            OnboardingBackground(waveHeightFactor: wave),
            Opacity(
              opacity: uiOpacity,
              child: Transform.translate(
                offset: Offset(0, (1.0 - contentT) * 48),
                child: IgnorePointer(
                  ignoring: !interactive || busy,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        children: [
                          const Expanded(
                            flex: 34,
                            child: SafeArea(
                              bottom: false,
                              child: Center(
                                child: AppLogo(size: 100, onWhiteCircle: true),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 66,
                            child: SafeArea(
                              top: false,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 112),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    8,
                                    24,
                                    8,
                                  ),
                                  child: Column(
                                    children: [
                                      const Spacer(flex: 5),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 420,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Select Language',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: heading,
                                                height: 1.25,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Choose your preferred language for the app.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1.4,
                                                color: secondary,
                                              ),
                                            ),
                                            const SizedBox(height: 40),
                                            Obx(() {
                                              if (!Get.isRegistered<
                                                  SelectLanguageController>()) {
                                                return const SizedBox.shrink();
                                              }
                                              final selected =
                                                  controller.selected.value;
                                              return DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border:
                                                      Border.all(color: border),
                                                ),
                                                child: Column(
                                                  children: [
                                                    _LanguageRow(
                                                      flagAsset: AppAssets
                                                          .englishLanguage,
                                                      title: 'English (US)',
                                                      subtitle: 'English',
                                                      selected: selected ==
                                                          AppLanguageOption.en,
                                                      secondary: secondary,
                                                      onTap: () =>
                                                          controller.select(
                                                        AppLanguageOption.en,
                                                      ),
                                                    ),
                                                    Divider(
                                                      height: 1,
                                                      color: border,
                                                    ),
                                                    _LanguageRow(
                                                      flagAsset: AppAssets
                                                          .khmerLanguage,
                                                      title: 'Khmer',
                                                      subtitle: 'ភាសាខ្មែរ',
                                                      selected: selected ==
                                                          AppLanguageOption.km,
                                                      secondary: secondary,
                                                      onTap: () =>
                                                          controller.select(
                                                        AppLanguageOption.km,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      const Spacer(flex: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: OnboardingBottomChrome(
                          currentPage: 0,
                          totalPages: introDotCount,
                          onNext: controller.next,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.flagAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.secondary,
    required this.onTap,
  });

  final String flagAsset;
  final String title;
  final String subtitle;
  final bool selected;
  final Color secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                flagAsset,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: context.appColors.heading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary, size: 24)
            else
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
