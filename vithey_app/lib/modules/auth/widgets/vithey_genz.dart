import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Auth-scoped GenZ design tokens + icon chrome.
///
/// Mirrors the Vithey GenZ design system radii. Kept inside the auth module
/// until the shared `VitheyRadii` / `VitheyIconButton` land in
/// `lib/core/widgets/` — then re-export/alias from there instead.
abstract final class VitheyRadii {
  /// Cards / list rows / language tiles / interest cards.
  static const double card = 18;

  /// Text fields.
  static const double field = 16;

  /// Search pills / chips (full pill).
  static const double chip = 24;

  /// Sheets / dialogs.
  static const double sheet = 24;

  /// Icon button chrome (squircle) — 16–20 per DS.
  static const double iconChrome = 18;
}

/// GenZ icon chrome: circular/squircle plain icon button, ≥ 48 tap target.
///
/// - [onTeal]: placed over the teal auth backdrop → white icon, no fill.
/// - otherwise: heading-colored icon, no fill.
class VitheyIconButton extends StatelessWidget {
  const VitheyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.onTeal = false,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool onTeal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        onTeal ? Colors.white : context.appColors.heading;

    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: VitheyIcon(icon, size: 22, color: iconColor),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
