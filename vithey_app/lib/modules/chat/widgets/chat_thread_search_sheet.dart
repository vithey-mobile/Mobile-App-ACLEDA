import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatThreadSearchSheet extends StatefulWidget {
  const ChatThreadSearchSheet({
    super.key,
    required this.initialQuery,
    required this.onQueryChanged,
    required this.onClear,
  });

  final String initialQuery;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  @override
  State<ChatThreadSearchSheet> createState() => _ChatThreadSearchSheetState();
}

class _ChatThreadSearchSheetState extends State<ChatThreadSearchSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.chatThreadSearchHint,
                style: TextStyle(fontWeight: FontWeight.w600, color: context.appColors.heading),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppStrings.chatThreadSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            widget.onClear();
                            setState(() {});
                          },
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.onQueryChanged(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              shad.Button.primary(
                onPressed: () => Get.back(),
                child: const shad.Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showChatThreadSearchSheet({
  required String initialQuery,
  required ValueChanged<String> onQueryChanged,
  required VoidCallback onClear,
}) {
  Get.bottomSheet(
    ChatThreadSearchSheet(
      initialQuery: initialQuery,
      onQueryChanged: onQueryChanged,
      onClear: onClear,
    ),
    isScrollControlled: true,
    backgroundColor: Get.theme.scaffoldBackgroundColor,
  );
}
