import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';

class FinanceAppBar extends GetView<FinanceController>
    implements PreferredSizeWidget {
  const FinanceAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final colors = context.appColors;

    return Obx(() {
      final isSearchActive = controller.isSearchActive.value;
      final hasQuery = controller.searchQuery.value.isNotEmpty;

      return AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: canPop ? 0 : 16,
        automaticallyImplyLeading: canPop && !isSearchActive,
        leading: isSearchActive
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: controller.closeSearch,
              )
            : null,
        title: isSearchActive
            ? _FinanceSearchField(
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                hasQuery: hasQuery,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              )
            : const Text(
                'Finance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearchActive ? Icons.close_rounded : Icons.search_rounded,
            ),
            tooltip: AppStrings.financeSearchHint,
            onPressed: controller.toggleSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.border),
        ),
      );
    });
  }
}

class _FinanceSearchField extends StatelessWidget {
  const _FinanceSearchField({
    required this.controller,
    required this.focusNode,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: TextStyle(
          color: colors.heading,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.financeSearchHint,
          hintStyle: TextStyle(
            color: colors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: colors.inputFill,
          prefixIcon:
              Icon(Icons.search_rounded, color: colors.muted, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.muted, size: 18),
                  onPressed: onClear,
                  tooltip: AppStrings.clearSearch,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
