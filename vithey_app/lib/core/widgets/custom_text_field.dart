import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';

/// Reusable text field with validation and password toggle.
///
/// **Focus:** label, border, icons, and hint turn primary.
/// Fill and typed text stay on their normal colors.
///
/// **Error:** shown only after [FieldErrors.activate] + form validate.
/// Cleared when another area is tapped or when any field is focused.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  /// When null, uses [AppSemanticColors.inputFill].
  final Color? fillColor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  late bool _obscure;
  String? _errorText;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Focusing any field clears every error on this form.
      FieldErrors.clear(context);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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
    final hasError = _errorText != null && _errorText!.isNotEmpty;
    final muted = context.appColors.muted;
    final heading = context.appColors.heading;
    final fill = widget.fillColor ?? context.appColors.inputFill;
    final idleBorder = context.appColors.border;
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

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: _radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

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
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText && _obscure,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autovalidateMode: AutovalidateMode.disabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: TextStyle(
            fontSize: 14,
            color: heading, // typed text stays normal
          ),
          cursorColor: focusColor,
          validator: (value) {
            final allow = FieldErrors.show(context);
            final error =
                allow ? widget.validator?.call(value) : null;
            _setErrorText(error);
            return error;
          },
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: chrome,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20, color: chrome),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: chrome,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
            border: border(
              hasError ? AppColors.error : idleBorder,
            ),
            enabledBorder: border(
              hasError ? AppColors.error : idleBorder,
            ),
            focusedBorder: border(
              hasError ? AppColors.error : focusColor,
              width: 1.5,
            ),
            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, width: 1.5),
          ),
        ),
      ],
    );
  }
}
