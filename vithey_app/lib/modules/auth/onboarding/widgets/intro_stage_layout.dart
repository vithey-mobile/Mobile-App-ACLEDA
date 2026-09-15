import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_system_ui.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Shared intro geometry for language + onboarding.
///
/// - White content starts at the wave light edge (screen-height fraction).
/// - Dots + CTA stay **bottom-aligned**.
/// - Bottom gap = design 20px **plus** the system nav inset (0 when none).
abstract final class IntroStageMetrics {
  /// Design padding under the CTA (above the system nav / screen edge).
  static const chromeBottomPadding = 20.0;

  /// Dots(8) + gap(24) + button(~52).
  static const chromeBodyHeight = 8.0 + 24.0 + 52.0;

  /// System gesture / 3-button bar inset. Prefer [viewPadding] under edge-to-edge.
  static double systemBottomInset(BuildContext context) {
    return MediaQuery.viewPaddingOf(context).bottom;
  }

  /// 20 design + system inset (inset is 0 when there is no bottom bar).
  static double bottomPadding(BuildContext context) {
    return VitheySystemUi.bottomContentPadding(context);
  }

  /// Full height to reserve for overlay chrome.
  static double chromeReserveHeight(BuildContext context) {
    return chromeBodyHeight + bottomPadding(context);
  }

  static double maxLightY(WaveRibbonProfile profile) {
    final ys = profile.scaledLightY;
    if (ys.isEmpty) return 0.45 * WaveRibbon.heightScale;
    return ys.reduce(math.max);
  }

  /// Approximate teal-band bottom (scaled); logo/illustration centers above this.
  static double tealBandY(WaveRibbonProfile profile) {
    return profile.meanTealY;
  }

  static double whiteTopY(WaveRibbonProfile profile, double height) {
    return maxLightY(profile) * height;
  }
}

/// Teal header + centered white body. Optional [chrome] sits on the bottom;
/// overlay chrome uses [reserveOverlayChrome] instead.
class IntroStageLayout extends StatelessWidget {
  const IntroStageLayout({
    super.key,
    required this.profile,
    required this.header,
    required this.body,
    this.chrome,
    this.reserveOverlayChrome = false,
  });

  final WaveRibbonProfile profile;
  final Widget header;
  final Widget body;

  /// In-flow bottom chrome (dots + CTA).
  final Widget? chrome;

  /// When true, leave bottom space for the shared intro overlay chrome.
  final bool reserveOverlayChrome;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final lightH = IntroStageMetrics.whiteTopY(profile, h);
        final tealH =
            (IntroStageMetrics.tealBandY(profile) * h).clamp(0.0, lightH);
        final reserve = reserveOverlayChrome
            ? IntroStageMetrics.chromeReserveHeight(context)
            : 0.0;

        return Column(
          children: [
            SizedBox(
              height: lightH,
              // Exact vertical center of the teal band (not the light-wave box).
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: tealH,
                  width: double.infinity,
                  child: Center(child: header),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: body,
                ),
              ),
            ),
            if (chrome != null) chrome!,
            if (reserveOverlayChrome) SizedBox(height: reserve),
          ],
        );
      },
    );
  }
}
