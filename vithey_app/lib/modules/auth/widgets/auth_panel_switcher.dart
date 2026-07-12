import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/auth_moving_wave_sheet.dart';

/// Sign In ↔ Sign Up via **height morph** (not left/right slide):
/// - Fade current content out
/// - Swap panel; white sheet **grows up** or **shrinks down** to hug the next form
/// - Fade next content in
///
/// Text does not scale with the sheet — only height + opacity animate.
class AuthPanelSwitcher extends StatefulWidget {
  const AuthPanelSwitcher({
    super.key,
    required this.signInForm,
    required this.signUpForm,
  });

  final Widget signInForm;
  final Widget signUpForm;

  @override
  State<AuthPanelSwitcher> createState() => _AuthPanelSwitcherState();
}

class _AuthPanelSwitcherState extends State<AuthPanelSwitcher>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();

  late final AnimationController _fade;
  late Worker _indexWorker;

  int _visibleIndex = 0;
  bool _busy = false;

  static const _fadeOutMs = 160;
  static const _sizeMs = 420;
  static const _fadeInMs = 200;

  @override
  void initState() {
    super.initState();
    _visibleIndex = _auth.authPageIndex.value;
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _fadeOutMs),
      value: 1, // 1 = fully visible
    );
    _indexWorker = ever<int>(_auth.authPageIndex, _handleIndexChange);
  }

  Future<void> _handleIndexChange(int next) async {
    if (!mounted || next == _visibleIndex || _busy) return;

    _busy = true;
    _auth.isPanelAnimating.value = true;

    // 1) Fade out current form (height stays).
    _fade.duration = const Duration(milliseconds: _fadeOutMs);
    await _fade.animateTo(0, curve: Curves.easeOut);
    if (!mounted) return;

    // 2) Swap; AnimatedSize grows/shrinks to hug the new form.
    setState(() => _visibleIndex = next);

    // 3) Fade in once the size morph has mostly settled.
    await Future<void>.delayed(const Duration(milliseconds: _sizeMs ~/ 2));
    if (!mounted) return;

    _fade.duration = const Duration(milliseconds: _fadeInMs);
    await _fade.animateTo(1, curve: Curves.easeIn);
    if (!mounted) return;

    // Let remaining size settle before unlocking.
    final remaining = _sizeMs - (_sizeMs ~/ 2);
    if (remaining > 0) {
      await Future<void>.delayed(Duration(milliseconds: remaining));
    }
    if (!mounted) return;

    _auth.isPanelAnimating.value = false;
    _busy = false;
  }

  @override
  void dispose() {
    _indexWorker.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthMovingWaveSheet(
      waveHeightFactor: 0.10,
      child: AnimatedSize(
        duration: const Duration(milliseconds: _sizeMs),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: FadeTransition(
          opacity: _fade,
          child: KeyedSubtree(
            key: ValueKey<int>(_visibleIndex),
            child: _visibleIndex == 0
                ? widget.signInForm
                : widget.signUpForm,
          ),
        ),
      ),
    );
  }
}
