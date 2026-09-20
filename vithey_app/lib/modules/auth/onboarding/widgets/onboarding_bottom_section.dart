import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/intro_stage_layout.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class OnboardingBottomSection extends StatelessWidget {
  const OnboardingBottomSection({
    super.key,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.showChrome = true,
  });

  final String title;
  final String description;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  /// When false, only title + description are shown (dots/CTA live outside).
  final bool showChrome;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    final colors = context.appColors;

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.tr,
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(height: 1.25),
        ),
        const SizedBox(height: 12),
        Text(
          description.tr,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium
              ?.copyWith(color: colors.muted, height: 1.4),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, showChrome ? 24 : 8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: copy,
              ),
            ),
          ),
          if (showChrome) ...[
            _PageDots(currentPage: currentPage, totalPages: totalPages),
            const SizedBox(height: 24),
            _OnboardingCtaButton(
              label: (isLast ? AppStrings.getStarted : AppStrings.next).tr,
              onPressed: onNext,
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingBottomChrome extends StatelessWidget {
  const OnboardingBottomChrome({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.isLastSlide,
    this.nextLabel,
    this.showCta = true,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  /// When set, overrides `currentPage == totalPages - 1` for Get Started label
  /// (needed when dots include Select Language as step 0).
  final bool? isLastSlide;

  /// Overrides Next / Get Started when set (e.g. Language → Continue).
  final String? nextLabel;

  /// When false, only dots are interactive; CTA slot keeps height so layout
  /// stays put (used when Get Started lives inside the last PageView page).
  final bool showCta;

  /// Space reserved for overlay chrome (dots + CTA + 20 + system inset).
  static double reservedHeight(BuildContext context) {
    return IntroStageMetrics.chromeReserveHeight(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = isLastSlide ?? (currentPage == totalPages - 1);
    final rawLabel =
        nextLabel ?? (isLast ? AppStrings.getStarted : AppStrings.next);
    final label = rawLabel.tr;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        IntroStageMetrics.bottomPadding(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageDots(currentPage: currentPage, totalPages: totalPages),
          const SizedBox(height: 24),
          if (showCta)
            _OnboardingCtaButton(
              label: label,
              onPressed: onNext,
            )
          else
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: _OnboardingCtaButton(
                  label: AppStrings.getStarted.tr,
                  onPressed: () {},
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Get Started CTA for the last onboarding page (slides with PageView).
class OnboardingGetStartedButton extends StatelessWidget {
  const OnboardingGetStartedButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        IntroStageMetrics.bottomPadding(context),
      ),
      child: _OnboardingCtaButton(
        label: AppStrings.getStarted.tr,
        onPressed: onPressed,
      ),
    );
  }
}

class _OnboardingCtaButton extends StatelessWidget {
  const _OnboardingCtaButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: label,
            icon: LucideIcons.chevronRight,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final active = context.scheme.primary;
    final inactive = context.appColors.border;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: isActive ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? active : inactive,
          ),
        );
      }),
    );
  }
}
