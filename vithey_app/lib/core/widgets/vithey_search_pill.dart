import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Rounded pill search field used on Map / Search GenZ chrome (shadcn).
class VitheySearchPill extends StatelessWidget {
  const VitheySearchPill({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.trailing,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final List<Widget>? trailing;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      color: colors.cardSurface,
      child: shad.TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        border: const Border.fromBorderSide(BorderSide.none),
        filled: true,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.heading,
        ),
        placeholder: Text(
          hintText,
          style: TextStyle(
            color: colors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        features: [
          const shad.InputFeature.leading(
            Icon(Icons.search, size: 20, color: AppColors.primary),
          ),
          if (controller.text.isNotEmpty && onClear != null)
            shad.InputFeature.trailing(
              shad.IconButton.text(
                icon: Icon(Icons.clear, size: 18, color: colors.muted),
                onPressed: onClear,
                density: shad.ButtonDensity.compact,
              ),
            ),
          if (trailing != null)
            for (final widget in trailing!) shad.InputFeature.trailing(widget),
        ],
      ),
    );
  }
}
