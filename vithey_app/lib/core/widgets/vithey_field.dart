import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// App-wide text field built on [shad.TextField].
///
/// Labels use [FontWeight.w600]. Works with [FormErrorHost] / [FieldErrors]
/// the same way [CustomTextField] did.
class VitheyField extends StatefulWidget {
  const VitheyField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.autofocus = false,
    this.filled = true,
    this.onToggleObscure,
    this.focusNode,
    this.inputFormatters,
    this.errorText,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool filled;

  /// When set, obscure toggling is owned by the parent: [obscureText] is the
  /// live hidden state and this callback is fired by the eye button.
  final VoidCallback? onToggleObscure;

  /// Optional external focus node. When null, an internal node is created
  /// and disposed with the field.
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  /// External error override; wins over the internal validator error.
  final String? errorText;

  bool get _ownsObscureState => onToggleObscure == null;

  @override
  State<VitheyField> createState() => _VitheyFieldState();
}

class _VitheyFieldState extends State<VitheyField> {
  FocusNode? _ownedFocusNode;
  late bool _obscure;
  String? _errorText;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownedFocusNode ??= FocusNode()..addListener(_onFocusChange));

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant VitheyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      FieldErrors.clear(context);
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _setErrorText(String? error) {
    if (_errorText == error) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _errorText = error);
    });
  }

  Color _chromeColor({
    required bool focused,
    required bool hasError,
    required Color muted,
    required Color focusColor,
  }) {
    if (hasError) return AppColors.error;
    if (focused) return focusColor;
    return muted;
  }

  Color _labelColor({
    required bool focused,
    required bool hasError,
    required Color heading,
    required Color focusColor,
  }) {
    if (hasError) return AppColors.error;
    if (focused) return focusColor;
    return heading;
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final externalError = widget.errorText;
    final hasError = (externalError != null && externalError.isNotEmpty) ||
        (_errorText != null && _errorText!.isNotEmpty);
    final muted = context.appColors.muted;
    final heading = context.appColors.heading;
    final focusColor = context.scheme.primary;
    final chrome = _chromeColor(
      focused: focused,
      hasError: hasError,
      muted: muted,
      focusColor: focusColor,
    );
    final labelColor = _labelColor(
      focused: focused,
      hasError: hasError,
      heading: heading,
      focusColor: focusColor,
    );

    final features = <shad.InputFeature>[
      if (widget.prefixIcon != null)
        shad.InputFeature.leading(
          Icon(widget.prefixIcon, size: 20, color: chrome),
        ),
      if (widget.obscureText)
        shad.InputFeature.trailing(
          shad.IconButton.text(
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: chrome,
            ),
            onPressed: () {
              if (widget._ownsObscureState) {
                setState(() => _obscure = !_obscure);
              } else {
                widget.onToggleObscure!();
              }
            },
            density: shad.ButtonDensity.compact,
          ),
        )
      else if (widget.suffix != null)
        shad.InputFeature.trailing(widget.suffix!),
    ];

    final effectiveObscure = widget._ownsObscureState
        ? widget.obscureText && _obscure
        : widget.obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        FormField<String>(
          initialValue: widget.controller.text,
          autovalidateMode: AutovalidateMode.disabled,
          validator: (_) {
            final allow = FieldErrors.show(context);
            final error =
                allow ? widget.validator?.call(widget.controller.text) : null;
            _setErrorText(error);
            return error;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shad.TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  obscureText: effectiveObscure,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  maxLength: widget.maxLength,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onTap: widget.onTap,
                  inputFormatters: widget.inputFormatters,
                  filled: widget.filled,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.readOnly || !widget.enabled ? muted : heading,
                  ),
                  placeholder: widget.hint == null
                      ? null
                      : Text(
                          widget.hint!,
                          style: TextStyle(
                            color: chrome,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                  features: features,
                  onChanged: (value) {
                    field.didChange(value);
                    widget.onChanged?.call(value);
                  },
                  onSubmitted: widget.onSubmitted,
                ),
                if (hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    externalError ?? _errorText!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
