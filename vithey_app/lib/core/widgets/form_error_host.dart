import 'package:flutter/material.dart';

/// Hosts per-form error visibility for [CustomTextField].
///
/// - [activateFor] / [FieldErrors.activate] before `FormState.validate()`
/// - [clearAll] / field focus clears messages and restores idle colors
class FormErrorHost extends StatefulWidget {
  const FormErrorHost({
    super.key,
    required this.formKey,
    required this.child,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;

  static final Set<_FormErrorHostState> _hosts = {};

  /// Clears validation errors on every mounted [FormErrorHost].
  static void clearAll() {
    for (final host in _hosts.toList()) {
      host.clearErrors();
    }
  }

  /// Turns on error display for the host that owns [formKey] (sync).
  static void activateFor(GlobalKey<FormState> formKey) {
    for (final host in _hosts) {
      if (identical(host.widget.formKey, formKey)) {
        host.activateErrors();
        return;
      }
    }
  }

  @override
  State<FormErrorHost> createState() => _FormErrorHostState();
}

class _FormErrorHostState extends State<FormErrorHost> {
  /// Sync flag — readable in the same frame as [activateErrors] + validate.
  final ValueNotifier<bool> showErrors = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    FormErrorHost._hosts.add(this);
  }

  @override
  void dispose() {
    FormErrorHost._hosts.remove(this);
    showErrors.dispose();
    super.dispose();
  }

  void activateErrors() {
    showErrors.value = true;
  }

  void clearErrors() {
    if (!showErrors.value) return;
    showErrors.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.formKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FieldErrorScope(
      showErrors: showErrors,
      activateErrors: activateErrors,
      clearErrors: clearErrors,
      child: widget.child,
    );
  }
}

class _FieldErrorScope extends InheritedWidget {
  const _FieldErrorScope({
    required this.showErrors,
    required this.activateErrors,
    required this.clearErrors,
    required super.child,
  });

  final ValueNotifier<bool> showErrors;
  final VoidCallback activateErrors;
  final VoidCallback clearErrors;

  static _FieldErrorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FieldErrorScope>();
  }

  @override
  bool updateShouldNotify(_FieldErrorScope oldWidget) {
    return showErrors != oldWidget.showErrors;
  }
}

/// Public helpers for buttons / fields.
abstract final class FieldErrors {
  static void activate(BuildContext context) {
    _FieldErrorScope.maybeOf(context)?.activateErrors();
  }

  static void clear(BuildContext context) {
    _FieldErrorScope.maybeOf(context)?.clearErrors();
  }

  /// Whether validators should surface errors (sync-safe).
  static bool show(BuildContext context) {
    final scope = _FieldErrorScope.maybeOf(context);
    if (scope == null) return true;
    return scope.showErrors.value;
  }
}
