import 'dart:math' as math;

import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:flutter/material.dart';

/// Editable CV section tapped on the live template preview (Canva-style).
enum CvEditSection {
  fullName,
  jobTitle,
  summary,
  skills,
  softSkills,
  education,
  experience,
  projects,
  languages,
  references,
  certifications,
  achievements,
  hobbies,
  contact,
  phone,
  email,
  location,
  website,
}

extension CvEditSectionLabel on CvEditSection {
  String get title => switch (this) {
        CvEditSection.fullName => 'Full name',
        CvEditSection.jobTitle => 'Job title',
        CvEditSection.summary => 'About / Summary',
        CvEditSection.skills => 'Skills',
        CvEditSection.softSkills => 'Soft skills',
        CvEditSection.education => 'Education',
        CvEditSection.experience => 'Experience',
        CvEditSection.projects => 'Projects',
        CvEditSection.languages => 'Languages',
        CvEditSection.references => 'References',
        CvEditSection.certifications => 'Certifications',
        CvEditSection.achievements => 'Achievements',
        CvEditSection.hobbies => 'Hobbies',
        CvEditSection.contact => 'Contact',
        CvEditSection.phone => 'Phone',
        CvEditSection.email => 'Email',
        CvEditSection.location => 'Location',
        CvEditSection.website => 'Website',
      };

  String get hint => switch (this) {
        CvEditSection.fullName => 'Your full name',
        CvEditSection.jobTitle => 'Your professional title',
        CvEditSection.summary => 'Short summary about you',
        CvEditSection.skills => 'Comma-separated skills',
        CvEditSection.softSkills => 'Comma-separated soft skills',
        CvEditSection.education => 'One school / degree per line',
        CvEditSection.experience => 'One role per line',
        CvEditSection.projects => 'One project per line',
        CvEditSection.languages => 'One language per line (e.g. English — Fluent)',
        CvEditSection.references => 'One reference per line',
        CvEditSection.certifications => 'One certification per line',
        CvEditSection.achievements => 'One achievement per line',
        CvEditSection.hobbies => 'Comma-separated hobbies',
        CvEditSection.contact => 'Email · phone · location',
        CvEditSection.phone => 'Phone number',
        CvEditSection.email => 'Email address',
        CvEditSection.location => 'City or address',
        CvEditSection.website => 'Website or portfolio URL',
      };

  int get maxLines => switch (this) {
        CvEditSection.fullName => 1,
        CvEditSection.jobTitle => 1,
        CvEditSection.phone => 1,
        CvEditSection.email => 1,
        CvEditSection.location => 2,
        CvEditSection.website => 1,
        CvEditSection.contact => 2,
        CvEditSection.skills => 3,
        CvEditSection.softSkills => 3,
        CvEditSection.hobbies => 3,
        CvEditSection.languages => 4,
        _ => 6,
      };
}

/// Renders a CV draft in a chosen template layout (gallery thumb + editor).
///
/// When [editable] is true, tapping a text block calls [onEditSection]
/// so the host can open an inline editor (Canva-style).
class CvTemplatePreview extends StatelessWidget {
  const CvTemplatePreview({
    super.key,
    required this.draft,
    required this.template,
    this.compact = false,
    this.editable = false,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    // Cap content length for the preview box (CV-only; profile untouched).
    final fitted = draft.fittedForPreview(compact: compact);
    final ctx = _PreviewCtx(
      draft: fitted,
      template: template,
      compact: compact,
      editable: editable,
      onEditSection: onEditSection,
      activeSection: activeSection,
    );

    final page = switch (template.layout) {
      CvTemplateLayout.sidebar => _SidebarFamily(ctx: ctx),
      CvTemplateLayout.header => _HeaderFamily(ctx: ctx),
      CvTemplateLayout.minimal => _MinimalFamily(ctx: ctx),
      CvTemplateLayout.blank => _BlankLayout(ctx: ctx),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        if (!maxW.isFinite || !maxH.isFinite || maxW <= 0 || maxH <= 0) {
          return ClipRect(child: page);
        }

        // Layout at a fixed A4-ish design size, then scale to fit bounds.
        const designW = 320.0;
        final designH = designW / 0.707;
        final scale = math.min(maxW / designW, maxH / designH);

        return ClipRect(
          child: ColoredBox(
            color: Colors.white,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: designW * scale,
                height: designH * scale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: designW,
                    height: designH,
                    child: ClipRect(child: page),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

double _fs(bool compact, double full) => compact ? full * 0.55 : full;

double _pad(bool compact, [double full = 14]) => compact ? full * 0.55 : full;

class _PreviewCtx {
  const _PreviewCtx({
    required this.draft,
    required this.template,
    required this.compact,
    required this.editable,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  Color get accent => template.accentColor;
  Color get secondary =>
      template.secondaryColor ?? accent.withValues(alpha: 0.18);
  CvTemplateLabels get labels => template.labels;
  String get designId => template.designId;

  int get variant {
    final parts = designId.split('_');
    return int.tryParse(parts.isNotEmpty ? parts.last : '') ?? 1;
  }

  bool show({required bool hasContent}) => editable || hasContent;

  bool get hasStructuredContact =>
      draft.phone.trim().isNotEmpty ||
      draft.email.trim().isNotEmpty ||
      draft.location.trim().isNotEmpty ||
      draft.website.trim().isNotEmpty;

  bool get showContact =>
      show(hasContent: hasStructuredContact || draft.contact.trim().isNotEmpty);

  Widget block(CvEditSection section, Widget child) => _EditableBlock(
        section: section,
        editable: editable,
        active: activeSection == section,
        onEdit: onEditSection,
        child: child,
      );
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _joinLines(Iterable<String> items, {String sep = '\n'}) =>
    items.map((e) => e.trim()).where((e) => e.isNotEmpty).join(sep);

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.color,
    required this.compact,
    this.underline = false,
  });

  final String text;
  final Color color;
  final bool compact;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _pad(compact, 10), bottom: _pad(compact, 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _fs(compact, 9),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
          if (underline)
            Container(
              margin: EdgeInsets.only(top: compact ? 2 : 4),
              height: compact ? 1 : 1.5,
              width: compact ? 28 : 48,
              color: color,
            ),
        ],
      ),
    );
  }
}

class _EditableBlock extends StatelessWidget {
  const _EditableBlock({
    required this.section,
    required this.editable,
    required this.active,
    required this.onEdit,
    required this.child,
  });

  final CvEditSection section;
  final bool editable;
  final bool active;
  final ValueChanged<CvEditSection>? onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!editable) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEdit == null ? null : () => onEdit!(section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.28),
            width: active ? 1.5 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({
    required this.text,
    required this.compact,
    this.color = const Color(0xFF1F2937),
    this.maxLines,
    this.placeholder,
  });

  final String text;
  final bool compact;
  final Color color;
  final int? maxLines;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final empty = text.trim().isEmpty;
    if (empty && placeholder == null) return const SizedBox.shrink();
    final lines = maxLines ?? (compact ? 5 : 8);
    return Text(
      empty ? (placeholder ?? '') : text,
      maxLines: lines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: TextStyle(
        fontSize: _fs(compact, 8.5),
        height: 1.25,
        color: empty ? color.withValues(alpha: 0.45) : color,
        fontStyle: empty ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.draft,
    required this.size,
    required this.bg,
    this.square = false,
    this.borderColor = Colors.white,
  });

  final AiCvDraft draft;
  final double size;
  final Color bg;
  final bool square;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final url = draft.avatarUrl?.trim();
    final shape = square
        ? BoxShape.rectangle
        : BoxShape.circle;
    final radius = square ? BorderRadius.circular(size * 0.08) : null;

    Widget child;
    if (url != null && url.isNotEmpty && !compactUrlDisabled(size)) {
      child = ClipRRect(
        borderRadius: radius ?? BorderRadius.circular(size),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsChild(),
        ),
      );
    } else {
      child = _initialsChild();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: shape,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: size * 0.05),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  bool compactUrlDisabled(double size) => size < 36;

  Widget _initialsChild() {
    return Center(
      child: Text(
        _initials(draft.fullName),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

class _NameTitle extends StatelessWidget {
  const _NameTitle({
    required this.ctx,
    required this.nameColor,
    this.titleColor,
    this.align = TextAlign.start,
    this.nameInHeader = false,
  });

  final _PreviewCtx ctx;
  final Color nameColor;
  final Color? titleColor;
  final TextAlign align;
  final bool nameInHeader;

  @override
  Widget build(BuildContext context) {
    final nameEmpty = ctx.draft.fullName.trim().isEmpty;
    final titleEmpty = ctx.draft.jobTitle.trim().isEmpty;

    return Column(
      crossAxisAlignment: align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        ctx.block(
          CvEditSection.fullName,
          Text(
            nameEmpty ? 'Your Name' : ctx.draft.fullName,
            textAlign: align,
            maxLines: ctx.compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _fs(ctx.compact, nameInHeader ? 13 : 11),
              fontWeight: FontWeight.w800,
              color: nameEmpty ? nameColor.withValues(alpha: 0.5) : nameColor,
              fontStyle: nameEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        if (ctx.show(hasContent: !titleEmpty) || titleEmpty && ctx.editable)
          Padding(
            padding: EdgeInsets.only(top: _pad(ctx.compact, 2)),
            child: ctx.block(
              CvEditSection.jobTitle,
              Text(
                titleEmpty ? 'Job Title' : ctx.draft.jobTitle,
                textAlign: align,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _fs(ctx.compact, 9),
                  fontWeight: FontWeight.w600,
                  color: titleEmpty
                      ? (titleColor ?? nameColor).withValues(alpha: 0.45)
                      : (titleColor ?? nameColor.withValues(alpha: 0.85)),
                  fontStyle: titleEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({
    required this.ctx,
    required this.fg,
    this.muted,
    this.iconColor,
    this.dense = false,
  });

  final _PreviewCtx ctx;
  final Color fg;
  final Color? muted;
  final Color? iconColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final items = <(CvEditSection, IconData, String)>[
      (CvEditSection.phone, Icons.phone_outlined, ctx.draft.phone),
      (CvEditSection.email, Icons.email_outlined, ctx.draft.email),
      (CvEditSection.location, Icons.location_on_outlined, ctx.draft.location),
      (CvEditSection.website, Icons.language_outlined, ctx.draft.website),
    ];

    final visible = items
        .where((e) => ctx.show(hasContent: e.$3.trim().isNotEmpty))
        .toList();

    if (visible.isEmpty && ctx.showContact) {
      return ctx.block(
        CvEditSection.contact,
        _BodyText(
          text: ctx.draft.contactDisplay,
          compact: ctx.compact,
          color: muted ?? fg,
          maxLines: dense ? 2 : 4,
          placeholder: ctx.editable ? 'Tap to add contact' : null,
        ),
      );
    }

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (section, icon, value) in visible)
          Padding(
            padding: EdgeInsets.only(bottom: dense ? 1 : 3),
            child: ctx.block(
              section,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: _fs(ctx.compact, 8),
                    color: iconColor ?? fg.withValues(alpha: 0.75),
                  ),
                  SizedBox(width: _pad(ctx.compact, 4)),
                  Expanded(
                    child: _BodyText(
                      text: value,
                      compact: ctx.compact,
                      color: muted ?? fg,
                      maxLines: dense ? 1 : 2,
                      placeholder: ctx.editable ? 'Tap to add' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({
    required this.ctx,
    required this.section,
    required this.title,
    required this.items,
    required this.titleColor,
    this.bodyColor,
    this.joiner = '\n',
    this.bullet = false,
  });

  final _PreviewCtx ctx;
  final CvEditSection section;
  final String title;
  final List<String> items;
  final Color titleColor;
  final Color? bodyColor;
  final String joiner;
  final bool bullet;

  @override
  Widget build(BuildContext context) {
    final has = items.any((e) => e.trim().isNotEmpty);
    if (!ctx.show(hasContent: has)) return const SizedBox.shrink();

    final text = bullet
        ? items
            .where((e) => e.trim().isNotEmpty)
            .map((e) => '• ${e.trim()}')
            .join('\n')
        : _joinLines(items, sep: joiner);

    final lines = switch (section) {
      CvEditSection.summary => ctx.compact ? 4 : 6,
      CvEditSection.skills ||
      CvEditSection.softSkills ||
      CvEditSection.hobbies =>
        ctx.compact ? 5 : 8,
      CvEditSection.contact ||
      CvEditSection.phone ||
      CvEditSection.email ||
      CvEditSection.location ||
      CvEditSection.website =>
        ctx.compact ? 3 : 4,
      _ => ctx.compact ? 4 : 6,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionTitle(text: title, color: titleColor, compact: ctx.compact),
        ctx.block(
          section,
          _BodyText(
            text: text,
            compact: ctx.compact,
            color: bodyColor ?? const Color(0xFF374151),
            maxLines: lines,
            placeholder: ctx.editable ? 'Tap to add $title' : null,
          ),
        ),
      ],
    );
  }
}

class _Hr extends StatelessWidget {
  const _Hr({required this.color, required this.compact});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _pad(compact, 6)),
      child: Divider(height: 1, thickness: compact ? 0.6 : 1, color: color),
    );
  }
}

/// Scales column content down when it would exceed available height/width.
class _FitColumn extends StatelessWidget {
  const _FitColumn({required this.child, this.alignment = Alignment.topLeft});

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: SizedBox(
              width: constraints.maxWidth,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar family (sidebar_1 … sidebar_5)
// ---------------------------------------------------------------------------

class _SidebarFamily extends StatelessWidget {
  const _SidebarFamily({required this.ctx});

  final _PreviewCtx ctx;

  bool get _darkSidebar => ctx.variant == 2 || ctx.variant == 3 || ctx.variant == 5;
  bool get _nameInMain => ctx.variant == 3;

  @override
  Widget build(BuildContext context) {
    final sidebarBg = _darkSidebar ? ctx.accent : ctx.secondary;
    final sidebarFg = _darkSidebar ? Colors.white : const Color(0xFF1F2937);
    final sidebarMuted =
        _darkSidebar ? Colors.white70 : const Color(0xFF4B5563);
    final mainFg = const Color(0xFF111827);
    final pad = _pad(ctx.compact);
    final avatar = ctx.compact ? 28.0 : 56.0;

    Widget sidebarContent() {
      return Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_nameInMain) ...[
              Center(
                child: _Avatar(
                  draft: ctx.draft,
                  size: avatar,
                  bg: _darkSidebar ? ctx.accent.withValues(alpha: 0.55) : ctx.accent,
                ),
              ),
              SizedBox(height: _pad(ctx.compact, 8)),
              _NameTitle(
                ctx: ctx,
                nameColor: sidebarFg,
                titleColor: _darkSidebar ? Colors.white70 : ctx.accent,
                align: ctx.variant == 1 ? TextAlign.center : TextAlign.start,
              ),
              SizedBox(height: _pad(ctx.compact, 6)),
            ] else ...[
              Center(
                child: _Avatar(
                  draft: ctx.draft,
                  size: avatar,
                  bg: ctx.secondary,
                  borderColor: Colors.white,
                ),
              ),
              SizedBox(height: _pad(ctx.compact, 8)),
            ],
            if (ctx.showContact) ...[
              _SectionTitle(
                text: ctx.labels.contact,
                color: sidebarFg,
                compact: ctx.compact,
              ),
              _ContactBlock(
                ctx: ctx,
                fg: sidebarFg,
                muted: sidebarMuted,
                iconColor: _darkSidebar ? Colors.white : ctx.accent,
                dense: true,
              ),
            ],
            if (ctx.variant == 1 || ctx.variant == 4)
              _ListSection(
                ctx: ctx,
                section: CvEditSection.summary,
                title: ctx.labels.aboutMe,
                items: [ctx.draft.summary],
                titleColor: sidebarFg,
                bodyColor: sidebarMuted,
              ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.skills,
              title: ctx.labels.skills,
              items: ctx.draft.skills,
              titleColor: sidebarFg,
              bodyColor: sidebarMuted,
              joiner: ' · ',
            ),
            if (ctx.show(hasContent: ctx.draft.hasSoftSkills))
              _ListSection(
                ctx: ctx,
                section: CvEditSection.softSkills,
                title: 'Soft Skills',
                items: ctx.draft.softSkills,
                titleColor: sidebarFg,
                bodyColor: sidebarMuted,
                joiner: ' · ',
              ),
            if (_nameInMain || ctx.variant >= 3)
              _ListSection(
                ctx: ctx,
                section: CvEditSection.education,
                title: ctx.labels.education,
                items: ctx.draft.education,
                titleColor: sidebarFg,
                bodyColor: sidebarMuted,
                bullet: ctx.variant == 3,
              ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.languages,
              title: ctx.labels.languages,
              items: ctx.draft.languages,
              titleColor: sidebarFg,
              bodyColor: sidebarMuted,
              bullet: true,
            ),
            if (ctx.variant == 5)
              _ListSection(
                ctx: ctx,
                section: CvEditSection.hobbies,
                title: ctx.labels.hobbies,
                items: ctx.draft.hobbies,
                titleColor: sidebarFg,
                bodyColor: sidebarMuted,
                joiner: ' · ',
              ),
          ],
        ),
      );
    }

    Widget mainContent() {
      return Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_nameInMain) ...[
              _NameTitle(
                ctx: ctx,
                nameColor: ctx.accent,
                titleColor: ctx.accent.withValues(alpha: 0.75),
              ),
              _Hr(color: ctx.accent.withValues(alpha: 0.35), compact: ctx.compact),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.summary,
                title: ctx.labels.aboutMe,
                items: [ctx.draft.summary],
                titleColor: ctx.accent,
                bodyColor: mainFg,
              ),
            ] else ...[
              _ListSection(
                ctx: ctx,
                section: CvEditSection.summary,
                title: ctx.labels.aboutMe,
                items: [ctx.draft.summary],
                titleColor: ctx.accent,
                bodyColor: mainFg,
              ),
            ],
            _ListSection(
              ctx: ctx,
              section: CvEditSection.experience,
              title: ctx.labels.experience,
              items: ctx.draft.experience,
              titleColor: ctx.accent,
              bodyColor: mainFg,
            ),
            if (!_nameInMain && ctx.variant < 3)
              _ListSection(
                ctx: ctx,
                section: CvEditSection.education,
                title: ctx.labels.education,
                items: ctx.draft.education,
                titleColor: ctx.accent,
                bodyColor: mainFg,
              ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.projects,
              title: ctx.labels.projects,
              items: ctx.draft.projects,
              titleColor: ctx.accent,
              bodyColor: mainFg,
            ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.certifications,
              title: ctx.labels.certifications,
              items: ctx.draft.certifications,
              titleColor: ctx.accent,
              bodyColor: mainFg,
            ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.achievements,
              title: ctx.labels.achievements,
              items: ctx.draft.achievements,
              titleColor: ctx.accent,
              bodyColor: mainFg,
              bullet: ctx.variant >= 3,
            ),
            _ListSection(
              ctx: ctx,
              section: CvEditSection.references,
              title: ctx.labels.references,
              items: ctx.draft.references,
              titleColor: ctx.accent,
              bodyColor: mainFg,
            ),
            if (ctx.variant != 5)
              _ListSection(
                ctx: ctx,
                section: CvEditSection.hobbies,
                title: ctx.labels.hobbies,
                items: ctx.draft.hobbies,
                titleColor: ctx.accent,
                bodyColor: mainFg,
                joiner: ' · ',
              ),
          ],
        ),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: ctx.variant == 4 ? 35 : 38,
            child: ColoredBox(
              color: sidebarBg,
              child: _FitColumn(child: sidebarContent()),
            ),
          ),
          Expanded(
            flex: ctx.variant == 4 ? 65 : 62,
            child: _FitColumn(child: mainContent()),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header family (header_1 … header_5)
// ---------------------------------------------------------------------------

class _HeaderFamily extends StatelessWidget {
  const _HeaderFamily({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    return switch (ctx.variant) {
      3 => _HeaderTimeline(ctx: ctx),
      2 || 4 => _HeaderSoftSplit(ctx: ctx),
      _ => _HeaderBanner(ctx: ctx),
    };
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final headerH = ctx.compact ? 34.0 : 68.0;
    final avatar = ctx.compact ? 26.0 : 54.0;
    final goldAccent = ctx.variant == 5 && ctx.template.secondaryColor != null;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerH + avatar * 0.35,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: headerH,
                      child: ColoredBox(
                        color: ctx.accent,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            pad + avatar * 0.9,
                            _pad(ctx.compact, 8),
                            pad,
                            0,
                          ),
                          child: _NameTitle(
                            ctx: ctx,
                            nameColor: Colors.white,
                            titleColor: goldAccent
                                ? ctx.template.secondaryColor!
                                : Colors.white70,
                            nameInHeader: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: pad,
                  top: headerH - avatar * 0.55,
                  child: _Avatar(
                    draft: ctx.draft,
                    size: avatar,
                    bg: ctx.accent,
                    borderColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: _FitColumn(child: _HeaderTwoColBody(ctx: ctx)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSoftSplit extends StatelessWidget {
  const _HeaderSoftSplit({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final stripColor = ctx.variant == 4 ? ctx.accent : ctx.accent;
    final bodyTint = ctx.secondary;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: stripColor,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: _pad(ctx.compact, 12),
              ),
              child: Row(
                children: [
                  _Avatar(
                    draft: ctx.draft,
                    size: ctx.compact ? 24 : 48,
                    bg: stripColor.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: _pad(ctx.compact, 8)),
                  Expanded(
                    child: _NameTitle(
                      ctx: ctx,
                      nameColor: Colors.white,
                      titleColor: Colors.white70,
                      nameInHeader: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: bodyTint.withValues(alpha: ctx.variant == 4 ? 0.35 : 0.2),
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: _FitColumn(
                  child: _HeaderTwoColBody(ctx: ctx, leftTint: bodyTint),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTimeline extends StatelessWidget {
  const _HeaderTimeline({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final avatar = ctx.compact ? 24.0 : 50.0;
    final headerH = ctx.compact ? 32.0 : 64.0;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerH,
            child: ColoredBox(
              color: ctx.accent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  children: [
                    _Avatar(
                      draft: ctx.draft,
                      size: avatar,
                      bg: ctx.accent.withValues(alpha: 0.55),
                    ),
                    SizedBox(width: _pad(ctx.compact, 8)),
                    Expanded(
                      child: _NameTitle(
                        ctx: ctx,
                        nameColor: Colors.white,
                        titleColor: Colors.white70,
                        nameInHeader: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 36,
                  child: ColoredBox(
                    color: ctx.secondary,
                    child: Padding(
                      padding: EdgeInsets.all(pad),
                      child: _FitColumn(
                        child: _HeaderSideColumn(ctx: ctx, onTint: true),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 64,
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: _FitColumn(
                      child: _HeaderMainColumn(ctx: ctx, timeline: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTwoColBody extends StatelessWidget {
  const _HeaderTwoColBody({required this.ctx, this.leftTint});

  final _PreviewCtx ctx;
  final Color? leftTint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 38,
          child: _HeaderSideColumn(ctx: ctx, onTint: leftTint != null),
        ),
        SizedBox(width: _pad(ctx.compact, 6)),
        Expanded(
          flex: 62,
          child: _HeaderMainColumn(ctx: ctx),
        ),
      ],
    );
  }
}

class _HeaderSideColumn extends StatelessWidget {
  const _HeaderSideColumn({required this.ctx, this.onTint = false});

  final _PreviewCtx ctx;
  final bool onTint;

  @override
  Widget build(BuildContext context) {
    final title = onTint ? ctx.accent : ctx.accent;
    final body = onTint ? const Color(0xFF374151) : const Color(0xFF4B5563);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ctx.showContact) ...[
          _SectionTitle(
            text: ctx.labels.contact,
            color: title,
            compact: ctx.compact,
            underline: ctx.variant == 1,
          ),
          _ContactBlock(ctx: ctx, fg: body, muted: body, dense: true),
        ],
        _ListSection(
          ctx: ctx,
          section: CvEditSection.skills,
          title: ctx.labels.skills,
          items: ctx.draft.skills,
          titleColor: title,
          bodyColor: body,
          bullet: true,
        ),
        _ListSection(
          ctx: ctx,
          section: CvEditSection.softSkills,
          title: 'Soft Skills',
          items: ctx.draft.softSkills,
          titleColor: title,
          bodyColor: body,
          bullet: true,
        ),
        _ListSection(
          ctx: ctx,
          section: CvEditSection.education,
          title: ctx.labels.education,
          items: ctx.draft.education,
          titleColor: title,
          bodyColor: body,
        ),
        _ListSection(
          ctx: ctx,
          section: CvEditSection.languages,
          title: ctx.labels.languages,
          items: ctx.draft.languages,
          titleColor: title,
          bodyColor: body,
          bullet: true,
        ),
        _ListSection(
          ctx: ctx,
          section: CvEditSection.references,
          title: ctx.labels.references,
          items: ctx.draft.references,
          titleColor: title,
          bodyColor: body,
        ),
      ],
    );
  }
}

class _HeaderMainColumn extends StatelessWidget {
  const _HeaderMainColumn({required this.ctx, this.timeline = false});

  final _PreviewCtx ctx;
  final bool timeline;

  @override
  Widget build(BuildContext context) {
    final body = const Color(0xFF1F2937);

    Widget section(_ListSection s) {
      if (!timeline) return s;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _pad(ctx.compact, 12), right: 4),
            child: Container(
              width: ctx.compact ? 4 : 6,
              height: ctx.compact ? 4 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ctx.accent, width: 1.2),
              ),
            ),
          ),
          Expanded(child: s),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section(_ListSection(
          ctx: ctx,
          section: CvEditSection.summary,
          title: ctx.labels.aboutMe,
          items: [ctx.draft.summary],
          titleColor: ctx.accent,
          bodyColor: body,
        )),
        section(_ListSection(
          ctx: ctx,
          section: CvEditSection.experience,
          title: ctx.labels.experience,
          items: ctx.draft.experience,
          titleColor: ctx.accent,
          bodyColor: body,
        )),
        section(_ListSection(
          ctx: ctx,
          section: CvEditSection.projects,
          title: ctx.labels.projects,
          items: ctx.draft.projects,
          titleColor: ctx.accent,
          bodyColor: body,
        )),
        section(_ListSection(
          ctx: ctx,
          section: CvEditSection.certifications,
          title: ctx.labels.certifications,
          items: ctx.draft.certifications,
          titleColor: ctx.accent,
          bodyColor: body,
        )),
        section(_ListSection(
          ctx: ctx,
          section: CvEditSection.achievements,
          title: ctx.labels.achievements,
          items: ctx.draft.achievements,
          titleColor: ctx.accent,
          bodyColor: body,
        )),
        _ListSection(
          ctx: ctx,
          section: CvEditSection.hobbies,
          title: ctx.labels.hobbies,
          items: ctx.draft.hobbies,
          titleColor: ctx.accent,
          bodyColor: body,
          joiner: ' · ',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal family (minimal_1 … minimal_5)
// ---------------------------------------------------------------------------

class _MinimalFamily extends StatelessWidget {
  const _MinimalFamily({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    return switch (ctx.variant) {
      2 => _MinimalFramed(ctx: ctx),
      3 => _MinimalSplit(ctx: ctx),
      4 => _MinimalFormal(ctx: ctx),
      5 => _MinimalCertify(ctx: ctx),
      _ => _MinimalClassic(ctx: ctx),
    };
  }
}

class _MinimalClassic extends StatelessWidget {
  const _MinimalClassic({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;
    final avatar = ctx.compact ? 22.0 : 44.0;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: _FitColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(
                    draft: ctx.draft,
                    size: avatar,
                    bg: const Color(0xFFE5E7EB),
                    square: true,
                    borderColor: ink.withValues(alpha: 0.25),
                  ),
                  SizedBox(width: _pad(ctx.compact, 8)),
                  Expanded(
                    child: _NameTitle(ctx: ctx, nameColor: ink),
                  ),
                ],
              ),
              _Hr(color: ink, compact: ctx.compact),
              if (ctx.showContact)
                _ContactBlock(
                  ctx: ctx,
                  fg: ink,
                  muted: const Color(0xFF6B7280),
                  dense: true,
                ),
              _Hr(color: ink.withValues(alpha: 0.35), compact: ctx.compact),
              ..._minimalSections(ctx, ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinimalFramed extends StatelessWidget {
  const _MinimalFramed({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad * 0.6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: ink.withValues(alpha: 0.45), width: 1.2),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: _FitColumn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameTitle(ctx: ctx, nameColor: ink, align: TextAlign.center),
                  if (ctx.showContact) ...[
                    _Hr(color: ink.withValues(alpha: 0.3), compact: ctx.compact),
                    _ContactBlock(
                      ctx: ctx,
                      fg: ink,
                      muted: const Color(0xFF6B7280),
                      dense: true,
                    ),
                  ],
                  ..._minimalSections(ctx, ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalSplit extends StatelessWidget {
  const _MinimalSplit({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;
    final avatar = ctx.compact ? 22.0 : 42.0;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(
                  draft: ctx.draft,
                  size: avatar,
                  bg: const Color(0xFFE5E7EB),
                  square: true,
                  borderColor: ink.withValues(alpha: 0.2),
                ),
                SizedBox(width: _pad(ctx.compact, 8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NameTitle(ctx: ctx, nameColor: ink),
                      ctx.block(
                        CvEditSection.summary,
                        _BodyText(
                          text: ctx.draft.summary,
                          compact: ctx.compact,
                          color: const Color(0xFF4B5563),
                          maxLines: ctx.compact ? 2 : 4,
                          placeholder:
                              ctx.editable ? 'Tap summary to edit' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _Hr(color: ink.withValues(alpha: 0.35), compact: ctx.compact),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 34,
                    child: _FitColumn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctx.showContact) ...[
                            _SectionTitle(
                              text: ctx.labels.contact,
                              color: ink,
                              compact: ctx.compact,
                            ),
                            _ContactBlock(
                              ctx: ctx,
                              fg: ink,
                              muted: const Color(0xFF6B7280),
                              dense: true,
                            ),
                          ],
                          _ListSection(
                            ctx: ctx,
                            section: CvEditSection.education,
                            title: ctx.labels.education,
                            items: ctx.draft.education,
                            titleColor: ink,
                          ),
                          _ListSection(
                            ctx: ctx,
                            section: CvEditSection.skills,
                            title: ctx.labels.skills,
                            items: ctx.draft.skills,
                            titleColor: ink,
                            bullet: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: _pad(ctx.compact, 6)),
                  Expanded(
                    flex: 66,
                    child: _FitColumn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ListSection(
                            ctx: ctx,
                            section: CvEditSection.experience,
                            title: ctx.labels.experience,
                            items: ctx.draft.experience,
                            titleColor: ink,
                          ),
                          _ListSection(
                            ctx: ctx,
                            section: CvEditSection.references,
                            title: ctx.labels.references,
                            items: ctx.draft.references,
                            titleColor: ink,
                          ),
                          _ListSection(
                            ctx: ctx,
                            section: CvEditSection.languages,
                            title: ctx.labels.languages,
                            items: ctx.draft.languages,
                            titleColor: ink,
                            bullet: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalFormal extends StatelessWidget {
  const _MinimalFormal({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: _FitColumn(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NameTitle(
                ctx: ctx,
                nameColor: ink,
                align: TextAlign.center,
              ),
              if (ctx.showContact)
                Padding(
                  padding: EdgeInsets.only(top: _pad(ctx.compact, 4)),
                  child: ctx.block(
                    CvEditSection.contact,
                    _BodyText(
                      text: ctx.draft.contactDisplay,
                      compact: ctx.compact,
                      color: const Color(0xFF6B7280),
                      maxLines: 2,
                      placeholder: ctx.editable ? 'Tap to add contact' : null,
                    ),
                  ),
                ),
              _Hr(color: ink, compact: ctx.compact),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _minimalSections(ctx, ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinimalCertify extends StatelessWidget {
  const _MinimalCertify({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: _FitColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NameTitle(ctx: ctx, nameColor: ink),
              if (ctx.showContact)
                _ContactBlock(
                  ctx: ctx,
                  fg: ink,
                  muted: const Color(0xFF6B7280),
                  dense: true,
                ),
              _Hr(color: ink.withValues(alpha: 0.35), compact: ctx.compact),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.summary,
                title: ctx.labels.aboutMe,
                items: [ctx.draft.summary],
                titleColor: ink,
              ),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.experience,
                title: ctx.labels.experience,
                items: ctx.draft.experience,
                titleColor: ink,
              ),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.certifications,
                title: ctx.labels.certifications,
                items: ctx.draft.certifications,
                titleColor: ink,
                bullet: true,
              ),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.education,
                title: ctx.labels.education,
                items: ctx.draft.education,
                titleColor: ink,
              ),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.skills,
                title: ctx.labels.skills,
                items: ctx.draft.skills,
                titleColor: ink,
                joiner: ' · ',
              ),
              _ListSection(
                ctx: ctx,
                section: CvEditSection.projects,
                title: ctx.labels.projects,
                items: ctx.draft.projects,
                titleColor: ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _minimalSections(_PreviewCtx ctx, Color ink) {
  return [
    _ListSection(
      ctx: ctx,
      section: CvEditSection.summary,
      title: ctx.labels.aboutMe,
      items: [ctx.draft.summary],
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.experience,
      title: ctx.labels.experience,
      items: ctx.draft.experience,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.education,
      title: ctx.labels.education,
      items: ctx.draft.education,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.skills,
      title: ctx.labels.skills,
      items: ctx.draft.skills,
      titleColor: ink,
      joiner: ' · ',
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.projects,
      title: ctx.labels.projects,
      items: ctx.draft.projects,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.languages,
      title: ctx.labels.languages,
      items: ctx.draft.languages,
      titleColor: ink,
      bullet: true,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.references,
      title: ctx.labels.references,
      items: ctx.draft.references,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.certifications,
      title: ctx.labels.certifications,
      items: ctx.draft.certifications,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.achievements,
      title: ctx.labels.achievements,
      items: ctx.draft.achievements,
      titleColor: ink,
    ),
    _ListSection(
      ctx: ctx,
      section: CvEditSection.hobbies,
      title: ctx.labels.hobbies,
      items: ctx.draft.hobbies,
      titleColor: ink,
      joiner: ' · ',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Blank layout
// ---------------------------------------------------------------------------

class _BlankLayout extends StatelessWidget {
  const _BlankLayout({required this.ctx});

  final _PreviewCtx ctx;

  @override
  Widget build(BuildContext context) {
    final pad = _pad(ctx.compact);
    final ink = ctx.accent;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: _FitColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NameTitle(ctx: ctx, nameColor: ink),
              if (ctx.showContact) ...[
                SizedBox(height: _pad(ctx.compact, 4)),
                _ContactBlock(
                  ctx: ctx,
                  fg: ink,
                  muted: const Color(0xFF6B7280),
                  dense: true,
                ),
              ],
              _Hr(color: ink.withValues(alpha: 0.25), compact: ctx.compact),
              ..._minimalSections(ctx, ink),
            ],
          ),
        ),
      ),
    );
  }
}
