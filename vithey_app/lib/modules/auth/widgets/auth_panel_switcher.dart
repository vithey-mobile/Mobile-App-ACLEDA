import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';

/// Sign In ↔ Sign Up continuum slide (no disappear gap):
/// - Sign In → Sign Up: panels move left (incoming from the right)
/// - Sign Up → Sign In: panels move right (incoming from the left)
///
/// White hug follows **each panel's content height**, lerped with the slide
/// (not max-of-both). Slide + hug run together — no pause between them.
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

  late final AnimationController _controller;
  late final Animation<double> _t;
  late Worker _indexWorker;

  int _from = 0;
  int _to = 0;
  bool _busy = false;

  double _heightSignIn = 0;
  double _heightSignUp = 0;

  static const _duration = IntroMorph.panelDuration;

  @override
  void initState() {
    super.initState();
    _from = _auth.authPageIndex.value;
    _to = _from;
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addListener(_onTick);
    _indexWorker = ever<int>(_auth.authPageIndex, _onIndexChanged);
  }

  void _onTick() {
    if (!_busy || !mounted) return;
    _reportDisplayHeight(_t.value);
  }

  Future<void> _onIndexChanged(int next) async {
    if (!mounted || next == _to || _busy) return;

    _busy = true;
    _auth.isPanelAnimating.value = true;
    setState(() {
      _from = _to;
      _to = next;
    });

    // If the inactive panel hasn't been measured yet, give it a couple of
    // frames so the first slide doesn't snap the hug (feels "too fast").
    if (!_canLerpHeights) {
      for (var i = 0; i < 10 && mounted && !_canLerpHeights; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    }
    if (!mounted) return;

    // Hug lerp + slide start together (no extra pause after heights are ready).
    _controller.duration = _duration;
    _reportDisplayHeight(0);
    await _controller.forward(from: 0);
    if (!mounted) return;

    setState(() {
      _from = next;
      _to = next;
      _busy = false;
    });
    _controller.value = 0;
    _reportDisplayHeight(0);
    _auth.isPanelAnimating.value = false;
  }

  double _heightFor(int index) =>
      index == 0 ? _heightSignIn : _heightSignUp;

  double _displayHeight(double progress) {
    final hFrom = _heightFor(_from);
    final hTo = _heightFor(_to);
    if (!_busy) return _heightFor(_to);
    if (hFrom <= 0 && hTo <= 0) return 0;
    if (hFrom <= 0) return hTo;
    if (hTo <= 0) return hFrom;
    return lerpDouble(hFrom, hTo, progress)!;
  }

  bool get _canLerpHeights =>
      _heightFor(_from) > 0 && _heightFor(_to) > 0;

  void _reportDisplayHeight(double progress) {
    final h = _displayHeight(progress);
    if (h <= 0 || !mounted) return;
    _auth.reportContentHeight(
      contentHeight: h,
      screenHeight: MediaQuery.sizeOf(context).height,
    );
  }

  void _onPanelHeight(int index, double height) {
    if (height <= 0) return;
    final prev = index == 0 ? _heightSignIn : _heightSignUp;
    if ((height - prev).abs() < 0.5) return;

    setState(() {
      if (index == 0) {
        _heightSignIn = height;
      } else {
        _heightSignUp = height;
      }
    });

    if (!_busy && index == _to) {
      _reportDisplayHeight(0);
    } else if (_busy) {
      _reportDisplayHeight(_t.value);
    }
  }

  double _offsetFor(int index, double width, double progress) {
    final shown = _from + (_to - _from) * progress;
    return (index - shown) * width;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _indexWorker.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _panel(int index) {
    return KeyedSubtree(
      key: ValueKey<int>(index),
      child: index == 0 ? widget.signInForm : widget.signUpForm,
    );
  }

  Widget _slideChild({
    required int index,
    required double width,
    required double progress,
    required Widget child,
  }) {
    return Transform.translate(
      offset: Offset(_offsetFor(index, width, progress), 0),
      child: SizedBox(
        width: width,
        // Let each form keep its intrinsic height for measurement even when
        // the viewport is mid-lerp (shorter than Sign Up).
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minWidth: width,
          maxWidth: width,
          minHeight: 0,
          maxHeight: double.infinity,
          child: IgnorePointer(
            ignoring: _busy || index != _to,
            child: _PanelHeightSensor(
              onHeight: (h) => _onPanelHeight(index, h),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            final progress = _busy ? _t.value : 0.0;

            // At rest: active panel visible; inactive measured offstage so the
            // *first* Sign In ↔ Sign Up slide already has both heights and
            // doesn't rush the hug.
            if (!_busy) {
              final inactive = _to == 0 ? 1 : 0;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Offstage(
                    offstage: true,
                    child: SizedBox(
                      width: width,
                      child: _PanelHeightSensor(
                        onHeight: (h) => _onPanelHeight(inactive, h),
                        child: _panel(inactive),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _PanelHeightSensor(
                      onHeight: (h) => _onPanelHeight(_to, h),
                      child: _panel(_to),
                    ),
                  ),
                ],
              );
            }

            final lerped = _displayHeight(progress);
            // Both heights should be known from offstage measure; lerp with slide.
            final viewportH = lerped > 0 ? lerped : null;

            return SizedBox(
              width: width,
              height: viewportH,
              child: ClipRect(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.bottomCenter,
                  children: [
                    _slideChild(
                      index: 0,
                      width: width,
                      progress: progress,
                      child: _panel(0),
                    ),
                    _slideChild(
                      index: 1,
                      width: width,
                      progress: progress,
                      child: _panel(1),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PanelHeightSensor extends SingleChildRenderObjectWidget {
  const _PanelHeightSensor({
    required this.onHeight,
    required Widget super.child,
  });

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPanelHeightSensor(onHeight: onHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderPanelHeightSensor renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderPanelHeightSensor extends RenderProxyBox {
  _RenderPanelHeightSensor({required this.onHeight});

  ValueChanged<double> onHeight;
  double? _last;

  @override
  void performLayout() {
    super.performLayout();
    final h = size.height;
    if (_last != null && (h - _last!).abs() < 0.5) return;
    _last = h;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(h));
  }
}
