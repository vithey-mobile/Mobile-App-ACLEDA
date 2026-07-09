import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Reusable text field with validation and password toggle.
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

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;

  void _validate() {
    if (widget.validator == null) return;
    setState(() => _errorText = widget.validator!(widget.controller.text));
  }

  List<shad.InputFeature> _buildFeatures() {
    return [
      if (widget.prefixIcon != null)
        shad.InputFeature.leading(Icon(widget.prefixIcon, size: 18)),
      if (widget.obscureText) shad.InputFeature.passwordToggle(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          shad.Text(widget.label!),
          const SizedBox(height: 6),
        ],
        shad.TextField(
          controller: widget.controller,
          hintText: widget.hint,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          features: _buildFeatures(),
          onChanged: (value) {
            widget.onChanged?.call(value);
            if (_errorText != null) _validate();
          },
          onSubmitted: (_) => _validate(),
        ),
        if (_errorText != null && _errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}
