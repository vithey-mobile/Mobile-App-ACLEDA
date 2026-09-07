import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Reports [child] height whenever layout size changes (forms, errors, panels).
class ContentHeightReporter extends SingleChildRenderObjectWidget {
  const ContentHeightReporter({
    super.key,
    required this.onHeight,
    required Widget super.child,
  });

  final ValueChanged<double> onHeight;

  @override
  RenderContentHeightReporter createRenderObject(BuildContext context) {
    return RenderContentHeightReporter(onHeight: onHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderContentHeightReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class RenderContentHeightReporter extends RenderProxyBox {
  RenderContentHeightReporter({required this.onHeight});

  ValueChanged<double> onHeight;
  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final h = size.height;
    if (_lastHeight != null && (h - _lastHeight!).abs() < 0.5) return;
    _lastHeight = h;
    // Defer to after this frame so callers can safely update observables.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onHeight(h);
    });
  }
}
