import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

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

  /// When false, only title + description are shown (dots/CTA live outside PageView).
  final bool showChrome;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, showChrome ? 24 : 8),
      child: Column(
        children: [
          // More space above than below → text sits lower, toward the dots.
          const Spacer(flex: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.heading,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 2),
          if (showChrome) ...[
            _PageDots(currentPage: currentPage, totalPages: totalPages),
            const SizedBox(height: 24),
            _OnboardingCtaButton(
              label: isLast ? AppStrings.getStarted : AppStrings.next,
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
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  /// When set, overrides `currentPage == totalPages - 1` for Get Started label
  /// (needed when dots include Select Language as step 0).
  final bool? isLastSlide;

  @override
  Widget build(BuildContext context) {
    final isLast = isLastSlide ?? (currentPage == totalPages - 1);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageDots(currentPage: currentPage, totalPages: totalPages),
          const SizedBox(height: 24),
          _OnboardingCtaButton(
            label: isLast ? AppStrings.getStarted : AppStrings.next,
            onPressed: onNext,
          ),
        ],
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
    final primary = context.scheme.primary;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: AppColors.accentLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward, size: 18, color: AppColors.accentLight),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.accentLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? active : inactive,
          ),
        );
      }),
    );
  }
}
