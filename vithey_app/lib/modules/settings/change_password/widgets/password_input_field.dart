import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Password field with label, placeholder, leading lock icon, and a
/// controlled eye toggle: open eye while hidden (tap to reveal), closed eye
/// while visible (tap to hide).
class PasswordInputField extends StatelessWidget {
  const PasswordInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.visible,
    required this.onToggleVisibility,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 6),
        shad.TextField(
          controller: controller,
          placeholder: Text(placeholder),
          obscureText: !visible,
          maxLines: 1,
          features: [
            const shad.InputFeature.leading(Icon(Icons.lock_outline, size: 18)),
            shad.InputFeature.trailing(
              shad.IconButton.text(
                icon: Icon(
                  visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: onToggleVisibility,
                density: shad.ButtonDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
