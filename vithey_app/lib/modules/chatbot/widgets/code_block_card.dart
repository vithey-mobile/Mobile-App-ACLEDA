import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class CodeBlockCard extends StatelessWidget {
  const CodeBlockCard({
    super.key,
    required this.code,
    this.language,
    this.onCopied,
  });

  final String code;
  final String? language;
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final label = (language == null || language!.isEmpty) ? 'code' : language!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
                const Spacer(),
                shad.Button.ghost(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    onCopied?.call();
                  },
                  child: const shad.Text('Copy'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.appColors.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
