import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSkillRing extends StatelessWidget {
  const ProfileSkillRing({
    super.key,
    required this.skill,
    this.size = 80,
  });

  final ProfileSkill skill;
  final double size;

  static const _palette = [
    AppColors.primary,
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[skill.name.hashCode.abs() % _palette.length];
    final progress = (skill.proficiency.clamp(0, 100)) / 100;

    return SizedBox(
      width: size,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    strokeAlign: CircularProgressIndicator.strokeAlignInside,
                    backgroundColor: context.appColors.inputFill,
                    color: color,
                  ),
                ),
                Text(
                  '${skill.proficiency}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.heading,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            skill.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.15,
              color: context.appColors.heading,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileSkillsRow extends StatelessWidget {
  const ProfileSkillsRow({super.key, required this.skills});

  final List<ProfileSkill> skills;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: skills.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) => ProfileSkillRing(skill: skills[index]),
          ),
        ),
      ],
    );
  }
}

/// About v1: display-only titled sections. Editing is only on Edit personal info.
class ProfileAboutDetails extends StatelessWidget {
  const ProfileAboutDetails({
    super.key,
    required this.profile,
    required this.isOwnProfile,
  });

  final UserProfileModel profile;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio?.trim();

    final personal = <_AboutRowData>[
      if (profile.location != null && profile.location!.trim().isNotEmpty)
        _AboutRowData(Icons.location_on_outlined, profile.location!),
      if (profile.gender != null && profile.gender!.trim().isNotEmpty)
        _AboutRowData(Icons.person_outline, profile.gender!),
      if (profile.dateOfBirth != null)
        _AboutRowData(
          Icons.cake_outlined,
          DateFormat('MMMM dd yyyy').format(profile.dateOfBirth!),
        ),
      for (final extra in profile.personalExtras)
        if (extra.trim().isNotEmpty)
          _AboutRowData(Icons.notes_outlined, extra),
    ];

    final work = <_AboutRowData>[
      for (final job in profile.workItems)
        if (job.displayLabel.trim().isNotEmpty)
          _AboutRowData(Icons.apartment_outlined, job.displayLabel),
    ];

    final education = <_AboutRowData>[
      for (final edu in profile.educationItems) ...[
        if (edu.school.trim().isNotEmpty)
          _AboutRowData(Icons.school_outlined, edu.school),
        if (edu.major != null && edu.major!.trim().isNotEmpty)
          _AboutRowData(Icons.menu_book_outlined, edu.major!),
        if (edu.certificate != null && edu.certificate!.trim().isNotEmpty)
          _AboutRowData(Icons.workspace_premium_outlined, edu.certificate!),
      ],
    ];

    final links = <_AboutLinkData>[
      for (final link in profile.linkItems)
        if (link.url.trim().isNotEmpty)
          _AboutLinkData(
            link.platform.trim().isEmpty ? link.url : link.platform,
            link.url,
          ),
    ];

    final contact = <_AboutRowData>[
      if (isOwnProfile)
        for (final c in profile.contactItems) ...[
          if (c.phone != null && c.phone!.trim().isNotEmpty)
            _AboutRowData(Icons.phone_outlined, c.phone!),
          if (c.email != null && c.email!.trim().isNotEmpty)
            _AboutRowData(Icons.email_outlined, c.email!),
        ],
    ];

    final hasAny = (bio != null && bio.isNotEmpty) ||
        personal.isNotEmpty ||
        work.isNotEmpty ||
        education.isNotEmpty ||
        links.isNotEmpty ||
        contact.isNotEmpty;

    if (!hasAny) {
      return Text(
        isOwnProfile
            ? 'Add your details in Edit Profile Info'
            : 'No public information',
        style: TextStyle(color: context.appColors.muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bio != null && bio.isNotEmpty) ...[
          _AboutSection(
            title: 'Bio',
            rows: [_AboutRowData(Icons.format_quote_outlined, bio)],
          ),
          const SizedBox(height: 18),
        ],
        if (personal.isNotEmpty) ...[
          _AboutSection(title: 'Personal details', rows: personal),
          const SizedBox(height: 18),
        ],
        if (work.isNotEmpty) ...[
          _AboutSection(title: 'Work', rows: work),
          const SizedBox(height: 18),
        ],
        if (education.isNotEmpty) ...[
          _AboutSection(title: 'Education', rows: education),
          const SizedBox(height: 18),
        ],
        if (links.isNotEmpty) ...[
          _AboutLinksSection(links: links),
          const SizedBox(height: 18),
        ],
        if (contact.isNotEmpty)
          _AboutSection(title: 'Contact info', rows: contact),
      ],
    );
  }
}

class _AboutRowData {
  const _AboutRowData(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _AboutLinkData {
  const _AboutLinkData(this.label, this.url);
  final String label;
  final String url;
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.rows});

  final String title;
  final List<_AboutRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        for (final row in rows) _DetailRow(icon: row.icon, text: row.text),
      ],
    );
  }
}

class _AboutLinksSection extends StatelessWidget {
  const _AboutLinksSection({required this.links});

  final List<_AboutLinkData> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        for (final link in links)
          _LinkDetailRow(label: link.label, url: link.url),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.appColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: context.appColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkDetailRow extends StatelessWidget {
  const _LinkDetailRow({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showUrlAsLabel = label.startsWith('http');
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link, size: 20, color: context.appColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                showUrlAsLabel ? url : label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
