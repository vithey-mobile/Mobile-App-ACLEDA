import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';

/// Typed Add/Edit sheets. Controllers live inside each form State so drag-dismiss
/// and Submit never dispose listeners while TextFields are still mounted.

Future<ProfileSkill?> showSkillSheet(
  BuildContext context, {
  ProfileSkill? existing,
}) {
  return showEditProfileSheet<ProfileSkill>(
    context: context,
    title: existing == null ? 'Add skill' : 'Edit skill',
    builder: (ctx) => _SkillForm(sheetContext: ctx, existing: existing),
  );
}

Future<String?> showBioSheet(BuildContext context, {String? existing}) {
  return showEditProfileSheet<String>(
    context: context,
    title: (existing == null || existing.trim().isEmpty) ? 'Add bio' : 'Edit bio',
    builder: (ctx) => _BioForm(sheetContext: ctx, existing: existing ?? ''),
  );
}

class PersonalDetailsResult {
  const PersonalDetailsResult({
    required this.location,
    required this.gender,
    required this.dateOfBirth,
  });

  final String location;
  final String gender;
  final DateTime? dateOfBirth;
}

Future<PersonalDetailsResult?> showPersonalDetailsSheet(
  BuildContext context, {
  String location = '',
  String gender = '',
  DateTime? dateOfBirth,
}) {
  return showEditProfileSheet<PersonalDetailsResult>(
    context: context,
    title: 'Personal details',
    builder: (ctx) => _PersonalForm(
      sheetContext: ctx,
      location: location,
      gender: gender,
      dateOfBirth: dateOfBirth,
    ),
  );
}

Future<ProfileWorkEntry?> showWorkSheet(
  BuildContext context, {
  ProfileWorkEntry? existing,
}) {
  return showEditProfileSheet<ProfileWorkEntry>(
    context: context,
    title: existing == null ? 'Add work' : 'Edit work',
    builder: (ctx) => _WorkForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileEducationEntry?> showEducationSheet(
  BuildContext context, {
  ProfileEducationEntry? existing,
}) {
  return showEditProfileSheet<ProfileEducationEntry>(
    context: context,
    title: existing == null ? 'Add education' : 'Edit education',
    builder: (ctx) => _EducationForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileLinkEntry?> showLinkSheet(
  BuildContext context, {
  ProfileLinkEntry? existing,
}) {
  return showEditProfileSheet<ProfileLinkEntry>(
    context: context,
    title: existing == null ? 'Add link' : 'Edit link',
    builder: (ctx) => _LinkForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileContactEntry?> showContactSheet(
  BuildContext context, {
  ProfileContactEntry? existing,
}) {
  return showEditProfileSheet<ProfileContactEntry>(
    context: context,
    title: existing == null ? 'Add contact' : 'Edit contact',
    builder: (ctx) => _ContactForm(sheetContext: ctx, existing: existing),
  );
}

// ─── Forms (own controllers) ──────────────────────────────────────────

class _SkillForm extends StatefulWidget {
  const _SkillForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileSkill? existing;

  @override
  State<_SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends State<_SkillForm> {
  late final TextEditingController _name;
  late final TextEditingController _pct;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _pct = TextEditingController(
      text: widget.existing?.proficiency.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _pct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'Skill name',
          controller: _name,
          required: true,
        ),
        EditProfileSheetField(
          label: 'Skill percentage',
          controller: _pct,
          keyboardType: TextInputType.number,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            final pct = (int.tryParse(_pct.text.trim()) ?? 0).clamp(0, 100);
            Navigator.pop(
              widget.sheetContext,
              ProfileSkill(name: name, proficiency: pct),
            );
          },
        ),
      ],
    );
  }
}

class _BioForm extends StatefulWidget {
  const _BioForm({required this.sheetContext, required this.existing});
  final BuildContext sheetContext;
  final String existing;

  @override
  State<_BioForm> createState() => _BioFormState();
}

class _BioFormState extends State<_BioForm> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Bio', controller: _ctrl, maxLines: 4),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () => Navigator.pop(widget.sheetContext, _ctrl.text.trim()),
        ),
      ],
    );
  }
}

class _PersonalForm extends StatefulWidget {
  const _PersonalForm({
    required this.sheetContext,
    required this.location,
    required this.gender,
    required this.dateOfBirth,
  });

  final BuildContext sheetContext;
  final String location;
  final String gender;
  final DateTime? dateOfBirth;

  @override
  State<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends State<_PersonalForm> {
  late final TextEditingController _location;
  late final TextEditingController _gender;
  late final TextEditingController _dob;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _dateOfBirth = widget.dateOfBirth;
    _location = TextEditingController(text: widget.location);
    _gender = TextEditingController(text: widget.gender);
    _dob = TextEditingController(
      text: _dateOfBirth == null
          ? ''
          : DateFormat('MMMM dd yyyy').format(_dateOfBirth!),
    );
  }

  @override
  void dispose() {
    _location.dispose();
    _gender.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: widget.sheetContext,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = picked;
      _dob.text = DateFormat('MMMM dd yyyy').format(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Location', controller: _location),
        EditProfileSheetField(label: 'Gender', controller: _gender),
        EditProfileSheetField(
          label: 'Date of birth',
          controller: _dob,
          readOnly: true,
          suffix: const Icon(Icons.calendar_today_outlined),
          onTap: _pickDob,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () => Navigator.pop(
            widget.sheetContext,
            PersonalDetailsResult(
              location: _location.text.trim(),
              gender: _gender.text.trim(),
              dateOfBirth: _dateOfBirth,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkForm extends StatefulWidget {
  const _WorkForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileWorkEntry? existing;

  @override
  State<_WorkForm> createState() => _WorkFormState();
}

class _WorkFormState extends State<_WorkForm> {
  late final TextEditingController _position;
  late final TextEditingController _workplace;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _position = TextEditingController(text: widget.existing?.position ?? '');
    _workplace = TextEditingController(text: widget.existing?.workplace ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _position.dispose();
    _workplace.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Position', controller: _position),
        EditProfileSheetField(
          label: 'Workplace',
          controller: _workplace,
          required: true,
        ),
        EditProfileSheetField(
          label: 'Description',
          controller: _desc,
          maxLines: 3,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final workplace = _workplace.text.trim();
            if (workplace.isEmpty) return;
            final desc = _desc.text.trim();
            Navigator.pop(
              widget.sheetContext,
              ProfileWorkEntry(
                position: _position.text.trim(),
                workplace: workplace,
                description: desc.isEmpty ? null : desc,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EducationForm extends StatefulWidget {
  const _EducationForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileEducationEntry? existing;

  @override
  State<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<_EducationForm> {
  late final TextEditingController _school;
  late final TextEditingController _major;
  late final TextEditingController _cert;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _school = TextEditingController(text: widget.existing?.school ?? '');
    _major = TextEditingController(text: widget.existing?.major ?? '');
    _cert = TextEditingController(text: widget.existing?.certificate ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _school.dispose();
    _major.dispose();
    _cert.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'School / University',
          controller: _school,
          required: true,
        ),
        EditProfileSheetField(label: 'Major', controller: _major),
        EditProfileSheetField(label: 'Certificate', controller: _cert),
        EditProfileSheetField(
          label: 'Description',
          controller: _desc,
          maxLines: 3,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final school = _school.text.trim();
            if (school.isEmpty) return;
            final major = _major.text.trim();
            final cert = _cert.text.trim();
            final desc = _desc.text.trim();
            Navigator.pop(
              widget.sheetContext,
              ProfileEducationEntry(
                school: school,
                major: major.isEmpty ? null : major,
                certificate: cert.isEmpty ? null : cert,
                description: desc.isEmpty ? null : desc,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LinkForm extends StatefulWidget {
  const _LinkForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileLinkEntry? existing;

  @override
  State<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  late final TextEditingController _platform;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _platform = TextEditingController(text: widget.existing?.platform ?? '');
    _url = TextEditingController(text: widget.existing?.url ?? '');
  }

  @override
  void dispose() {
    _platform.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'Platform name',
          controller: _platform,
          required: true,
        ),
        EditProfileSheetField(
          label: 'URL',
          controller: _url,
          required: true,
          keyboardType: TextInputType.url,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final platform = _platform.text.trim();
            final url = _url.text.trim();
            if (platform.isEmpty || url.isEmpty) return;
            Navigator.pop(
              widget.sheetContext,
              ProfileLinkEntry(platform: platform, url: url),
            );
          },
        ),
      ],
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileContactEntry? existing;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.existing?.phone ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'Phone number',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        EditProfileSheetField(
          label: 'Email address',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final phone = _phone.text.trim();
            final email = _email.text.trim();
            if (phone.isEmpty && email.isEmpty) return;
            Navigator.pop(
              widget.sheetContext,
              ProfileContactEntry(
                phone: phone.isEmpty ? null : phone,
                email: email.isEmpty ? null : email,
              ),
            );
          },
        ),
      ],
    );
  }
}
