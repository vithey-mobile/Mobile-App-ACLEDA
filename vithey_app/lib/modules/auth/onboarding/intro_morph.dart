import 'package:flutter/animation.dart';

/// Intro handoff flags. Morph animations run on the **entering** screen only.
class IntroMorph {
  IntroMorph._();

  /// Language ↔ Onboarding (single-phase wave + content).
  static const duration = Duration(milliseconds: 360);

  /// Sign In ↔ Sign Up slide + white-hug lerp (same pace every time).
  static const panelDuration = Duration(milliseconds: 560);

  /// Onboarding ↔ Auth: wave morph only (content fades separately, shorter).
  static const authWaveDuration = Duration(milliseconds: 280);

  /// Onboarding ↔ Auth: content fade in/out after the wave.
  static const authContentDuration = Duration(milliseconds: 180);

  static bool fadeContentIn = false;
  static bool fromLanguage = false;
  static bool fromOnboarding = false;
  static bool fromAuth = false;
  static int initialOnboardingPage = 0;

  /// Wave factor of the screen being left (Auth → Onboarding reverse morph).
  static double fromAuthWaveFactor = 1.0;

  static void clear() {
    fadeContentIn = false;
    fromLanguage = false;
    fromOnboarding = false;
    fromAuth = false;
    initialOnboardingPage = 0;
    fromAuthWaveFactor = 1.0;
  }

  static Future<void> run(
    Duration duration,
    void Function(double t) onTick,
  ) async {
    const steps = 22;
    final stepMs =
        (duration.inMilliseconds / steps).clamp(8, 36).round();
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(Duration(milliseconds: stepMs));
      onTick(Curves.easeInOutCubic.transform(i / steps));
    }
    onTick(1);
  }
}
