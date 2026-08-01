import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
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
                  child: Column(
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
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              16 + bottomInset,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: const Alignment(0, 0.35),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: ConstrainedBox(
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
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: heading,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
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
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                const _IntroDots(
                                  activeIndex: 0,
                                  count: introDotCount,
                                ),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 420),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: busy ? null : controller.next,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.arrow_forward, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.next,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (interactive)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Opacity(
                    opacity: uiOpacity,
                    child: TextButton(
                      onPressed: busy ? null : controller.skip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class _IntroDots extends StatelessWidget {
  const _IntroDots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : context.appColors.border,
          ),
        );
      }),
    );
  }
}
