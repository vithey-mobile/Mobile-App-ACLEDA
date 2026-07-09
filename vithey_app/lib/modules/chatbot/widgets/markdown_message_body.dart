import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/code_block_card.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownMessageBody extends StatelessWidget {
  const MarkdownMessageBody({
    super.key,
    required this.content,
    this.onCodeCopied,
  });

  final String content;
  final void Function(String code)? onCodeCopied;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.scheme;

    return MarkdownBody(
      data: content,
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri == null) return;
        if (uri.scheme == 'javascript') return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: scheme.onSurface, fontSize: 15, height: 1.5),
        h1: TextStyle(color: scheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
        h2: TextStyle(color: scheme.onSurface, fontSize: 19, fontWeight: FontWeight.bold),
        h3: TextStyle(color: scheme.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
        strong: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        em: TextStyle(color: scheme.onSurface, fontStyle: FontStyle.italic),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: colors.inputFill,
          color: scheme.onSurface,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.border, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        listBullet: TextStyle(color: scheme.onSurface),
        a: TextStyle(color: scheme.primary, decoration: TextDecoration.underline),
      ),
      builders: {
        'pre': _PreElementBuilder(onCodeCopied: onCodeCopied),
      },
    );
  }
}

class _PreElementBuilder extends MarkdownElementBuilder {
  _PreElementBuilder({this.onCodeCopied});

  final void Function(String code)? onCodeCopied;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String? language;
    var code = element.textContent;

    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children!.first;
      if (child is md.Element && child.tag == 'code') {
        language = child.attributes['class']?.replaceFirst('language-', '');
        code = child.textContent;
      }
    }

    return CodeBlockCard(
      code: code.trimRight(),
      language: language,
      onCopied: () => onCodeCopied?.call(code.trimRight()),
    );
  }
}
