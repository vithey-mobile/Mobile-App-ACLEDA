import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/auth/intro_ribbon_controller.dart';
import 'package:aub_connect_app/modules/auth/language/select_language_controller.dart';
import 'package:aub_connect_app/modules/auth/login_screen.dart';
import 'package:aub_connect_app/modules/auth/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_top_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Language → Onboarding×3 → Sign In → Sign Up as one PageView continuum.
/// Forward slides left; back slides right — **buttons only** (no finger swipe).
class IntroRibbonScreen extends GetView<IntroRibbonController> {
  const IntroRibbonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.appColors.cardSurface,
      body: Obx(() {
        final busy = controller.isBusy.value;
        return IgnorePointer(
          ignoring: busy,
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: IntroRibbonController.pageCount,
            itemBuilder: (context, index) {
              switch (index) {
                case IntroRibbonController.pageLanguage:
                  return _LanguagePage(controller: controller);
                case IntroRibbonController.pageOnboarding1:
                  return _OnboardingPage(
                    controller: controller,
                    slideIndex: 0,
                  );
                case IntroRibbonController.pageOnboarding2:
                  return _OnboardingPage(
                    controller: controller,
                    slideIndex: 1,
                  );
                case IntroRibbonController.pageOnboarding3:
                  return _OnboardingPage(
                    controller: controller,
                    slideIndex: 2,
                  );
                case IntroRibbonController.pageSignIn:
                  return AuthRibbonFrame(
                    profile: WaveRibbon.signIn,
                    form: const AuthSignInForm(),
                    onBack: controller.authBack,
                  );
                case IntroRibbonController.pageSignUp:
                default:
                  return AuthRibbonFrame(
                    profile: WaveRibbon.signUp,
                    form: const AuthSignUpForm(),
                    onBack: controller.authBack,
                  );
              }
            },
          ),
        );
      }),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.controller});

  final IntroRibbonController controller;

  Color _secondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
  }

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final secondary = _secondary(context);
    final border = context.appColors.border;

    return Stack(
      fit: StackFit.expand,
      children: [
        const OnboardingBackground(profile: WaveRibbon.language),
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
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
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
                                final selected =
                                    controller.selectedLanguage.value;
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: border),
                                  ),
                                  child: Column(
                                    children: [
                                      _LanguageRow(
                                        flagAsset: AppAssets.englishLanguage,
                                        title: 'English (US)',
                                        subtitle: 'English',
                                        selected:
                                            selected == AppLanguageOption.en,
                                        secondary: secondary,
                                        onTap: () => controller.selectLanguage(
                                          AppLanguageOption.en,
                                        ),
                                      ),
                                      Divider(height: 1, color: border),
                                      _LanguageRow(
                                        flagAsset: AppAssets.khmerLanguage,
                                        title: 'Khmer',
                                        subtitle: 'ភាសាខ្មែរ',
                                        selected:
                                            selected == AppLanguageOption.km,
                                        secondary: secondary,
                                        onTap: () => controller.selectLanguage(
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
            totalPages: OnboardingController.introDotCount,
            onNext: controller.languageContinue,
            isLastSlide: false,
            nextLabel: 'Continue',
          ),
        ),
      ],
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.slideIndex,
  });

  final IntroRibbonController controller;
  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    final slide = controller.onboardingSlides[slideIndex];
    final profile = WaveRibbon.onboardingPage(slideIndex);
    final ribbonPage = IntroRibbonController.pageOnboarding1 + slideIndex;

    return Stack(
      fit: StackFit.expand,
      children: [
        OnboardingBackground(profile: profile),
        Column(
          children: [
            Expanded(
              flex: 55,
              child: OnboardingTopSection(imageAsset: slide.imageAsset),
            ),
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 112),
                child: OnboardingBottomSection(
                  title: slide.title,
                  description: slide.description,
                  currentPage: slideIndex,
                  totalPages: 3,
                  onNext: controller.onboardingNext,
                  showChrome: false,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Row(
              children: [
                CustomButton(
                  label: AppStrings.back,
                  variant: CustomButtonVariant.ghost,
                  foregroundColor: AppColors.accentLight,
                  onPressed: controller.onboardingBack,
                ),
                const Spacer(),
                CustomButton(
                  label: 'Skip',
                  variant: CustomButtonVariant.ghost,
                  foregroundColor: AppColors.accentLight,
                  onPressed: controller.skipOnboarding,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: OnboardingBottomChrome(
            currentPage: ribbonPage,
            totalPages: OnboardingController.introDotCount,
            onNext: controller.onboardingNext,
            isLastSlide: slideIndex == 2,
          ),
        ),
      ],
    );
  }
}
