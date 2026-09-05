import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// App-wide toggle switch wrapping [shad.Switch].
///
/// Active track uses the brand primary from the theme. The whole 48px-tall
/// area is tappable, not just the track.
class VitheySwitch extends StatelessWidget {
  const VitheySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;

  /// Called when the user toggles the switch. Ignored when [enabled] is false.
  final ValueChanged<bool>? onChanged;

  final bool enabled;

  void _handleTap() {
    if (enabled && onChanged != null) onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = context.scheme.primary;
    final switchWidget = shad.Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      activeColor: activeColor,
      borderRadius: BorderRadius.circular(999),
    );

    if (!enabled) return switchWidget;

    // Surround the track with an opaque 48px tap target.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 56,
        height: 48,
        child: Center(child: switchWidget),
      ),
    );
  }
}
