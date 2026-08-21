import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';

/// Visual-only Select Language for Splash handoff.
/// Must NOT use GetX — Splash deletes/replaces routes around this widget.
class SelectLanguagePreview extends StatelessWidget {
  const SelectLanguagePreview({
    super.key,
    this.contentReveal = 1.0,
  });

  final double contentReveal;

  static const introDotCount = 4;

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
    final border = context.appColors.border;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final reveal = contentReveal.clamp(0.0, 1.0);
    final contentT = Curves.easeOutCubic.transform(reveal);

    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(
            waveHeightFactor: OnboardingBackground.languageFactor,
          ),
          Opacity(
            opacity: contentT,
            child: Transform.translate(
              offset: Offset(0, (1.0 - contentT) * 48),
              child: IgnorePointer(
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
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 420),
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
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(color: border),
                                          ),
                                          child: Column(
                                            children: [
                                              _PreviewRow(
                                                flagAsset:
                                                    AppAssets.englishLanguage,
                                                title: 'English (US)',
                                                subtitle: 'English',
                                                selected: true,
                                                secondary: secondary,
                                              ),
                                              Divider(height: 1, color: border),
                                              _PreviewRow(
                                                flagAsset:
                                                    AppAssets.khmerLanguage,
                                                title: 'Khmer',
                                                subtitle: 'ភាសាខ្មែរ',
                                                selected: false,
                                                secondary: secondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(introDotCount, (i) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i == 0
                                          ? AppColors.primary
                                          : border,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
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
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.flagAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.secondary,
  });

  final String flagAsset;
  final String title;
  final String subtitle;
  final bool selected;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Text(subtitle, style: TextStyle(fontSize: 13, color: secondary)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check, color: AppColors.primary, size: 24)
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}
