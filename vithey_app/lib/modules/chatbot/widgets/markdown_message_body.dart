import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/code_block_card.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/streaming_markdown.dart';

/// ChatGPT-style auto preview of assistant replies.
///
/// Renders markdown as a formatted preview (headings, lists, tables, code,
/// links) — users never see raw `**` / `#` source. Works for both streaming
/// and finished messages via [GptMarkdown.isStreaming].
class MarkdownMessageBody extends StatelessWidget {
  const MarkdownMessageBody({
    super.key,
    required this.content,
    this.streaming = false,
    this.onCodeCopied,
  });

  final String content;
  final bool streaming;
  final void Function(String code)? onCodeCopied;

  /// Normalizes markdown spacing and heading/list formatting so text without
  /// proper newlines/spaces (e.g. `containers.##KeyFeatures:-Item`) parses cleanly.
  static String normalizeMarkdown(String raw) {
    if (raw.isEmpty) return raw;
    var text = raw.replaceAll('\r\n', '\n');

    // 1. Ensure space after hash marks for headings: "##KeyFeatures" -> "## KeyFeatures"
    text = text.replaceAllMapped(
      RegExp(r'(^|\n)(#{1,6})([A-Za-z0-9\u1780-\u17FF])', multiLine: true),
      (m) => '${m[1]}${m[2]} ${m[3]}',
    );

    // 2. Ensure space after list markers: "-Lightweight" -> "- Lightweight"
    text = text.replaceAllMapped(
      RegExp(r'(^|\n)([-*+])([A-Za-z0-9\u1780-\u17FF])', multiLine: true),
      (m) => '${m[1]}${m[2]} ${m[3]}',
    );

    // 3. Ensure double newline before headings when glued to non-newline text:
    // e.g. "containers.## Key Features" -> "containers.\n\n## Key Features"
    text = text.replaceAllMapped(
      RegExp(r'([^\n])\s*(#{1,6}\s+)'),
      (m) => '${m[1]}\n\n${m[2]}',
    );

    // 4. Ensure newline before list items glued to non-newline text:
    // e.g. "machines- **Portable**:" -> "machines\n- **Portable**:"
    text = text.replaceAllMapped(
      RegExp(r'([^\n\s])\s*([-*+]\s+)'),
      (m) => '${m[1]}\n${m[2]}',
    );

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final raw = content.trimRight();
    final normalized = normalizeMarkdown(raw);
    final text = streaming ? stabilizeStreamingMarkdown(normalized) : normalized;
    if (text.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    final scheme = context.scheme;
    final base = context.text.bodyLarge?.copyWith(
      fontSize: 15.5,
      height: 1.55,
      letterSpacing: 0.1,
      color: scheme.onSurface,
    );

    return GptMarkdown(
      text,
      style: base,
      // Stream + final both preview as formatted UI (not raw markdown).
      isStreaming: streaming,
      animation: GptMarkdownAnimation.none,
      followLinkColor: true,
      onLinkTap: (url, title) async {
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        if (uri.scheme == 'javascript') return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      onCodeCopy: (code) => onCodeCopied?.call(code),
      codeBuilder: (context, name, code, closed) {
        return CodeBlockCard(
          code: code.trimRight(),
          language: name.isEmpty ? null : name,
          onCopied: () => onCodeCopied?.call(code.trimRight()),
        );
      },
      styleSheet: GptMarkdownStyleSheet(
        heading: HeadingStyle(
          textStyle: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          showDivider: false,
        ),
        list: const ListStyle(
          bulletColor: AppColors.primary,
          indent: 4,
          gapAfterMarker: 8,
        ),
        inlineCode: InlineCodeStyle(
          backgroundColor: colors.inputFill,
          borderColor: colors.border.withValues(alpha: 0.6),
          color: scheme.primary,
          fontWeight: FontWeight.w500,
          borderRadius: const Radius.circular(6),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        ),
        codeBlock: CodeBlockStyle(
          backgroundColor: colors.inputFill,
          borderColor: colors.border,
          showCopyButton: false,
        ),
        table: TableStyle(
          borderColor: colors.border,
          borderWidth: 0.6,
          headerBackground: colors.inputFill,
          rowStripeColor: colors.cardSurface,
        ),
        link: LinkStyle(color: scheme.primary),
        blockQuote: BlockQuoteStyle(
          backgroundColor: colors.inputFill,
          barColor: AppColors.primary,
          barWidth: 3,
        ),
      ),
    );
  }
}
