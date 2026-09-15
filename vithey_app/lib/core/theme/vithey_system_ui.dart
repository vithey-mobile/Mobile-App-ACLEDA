import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Status bar stays transparent; system navigation bar is solid black.
///
/// [behind] picks status-bar icon contrast only.
class VitheySystemUi {
  VitheySystemUi._();

  /// Solid system navigation bar fill.
  static const systemNavBar = Color(0xFF000000);

  /// Design gap above the system nav (or screen edge when inset is 0).
  static const bottomContentGap = 20.0;

  /// Bottom padding for CTAs / chrome under edge-to-edge:
  /// `20 + systemInset` — inset is 0 when there is no bottom bar.
  static double bottomContentPadding(BuildContext context) {
    return bottomContentGap + MediaQuery.viewPaddingOf(context).bottom;
  }

  /// Transparent status bar + black navigation bar.
  ///
  /// Light / soft teal / white → dark status icons.
  /// Dark / deep teal / black → light status icons.
  /// Nav bar is always [systemNavBar] with light icons.
  static SystemUiOverlayStyle forBackground(
    Color behind, {
    Color? systemNavigationBarColor,
  }) {
    // [systemNavigationBarColor] kept for call-site compatibility; nav bar
    // is always solid black so Back/Home/Recents sit on a dark strip.
    final lightStatusIcons = behind.computeLuminance() < 0.45;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          lightStatusIcons ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          lightStatusIcons ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: systemNavBar,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  /// Full-bleed dark media (Reels, media viewer, stories).
  static SystemUiOverlayStyle immersiveDark() {
    return forBackground(Colors.black);
  }
}

/// Applies system-bar style for the lifetime of this subtree.
///
/// [color] is the surface behind the status bar (icon contrast).
/// Navigation bar defaults to black unless [systemNavigationBarColor] is set.
class VitheyStatusBar extends StatelessWidget {
  const VitheyStatusBar({
    super.key,
    required this.color,
    required this.child,
    this.systemNavigationBarColor,
  });

  /// Background under the status bar — used for status icon brightness.
  final Color color;
  final Color? systemNavigationBarColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: VitheySystemUi.forBackground(
        color,
        systemNavigationBarColor:
            systemNavigationBarColor ?? VitheySystemUi.systemNavBar,
      ),
      child: child,
    );
  }
}
