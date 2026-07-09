import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onSubmitted;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      elevation: 0,
      backgroundColor: colors.bodyBackground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Back',
      ),
      titleSpacing: 0,
      title: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return Semantics(
            label: 'Search',
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
              style: TextStyle(color: colors.heading, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: colors.muted),
                filled: true,
                fillColor: colors.inputFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: colors.muted, size: 22),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: colors.muted, size: 20),
                        onPressed: onClear,
                        tooltip: 'Clear search',
                      )
                    : null,
                isDense: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
