import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';

class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.pending:
        return const _GradientCard(
          colors: [Color(0xFFFF8A50), Color(0xFFE53935)],
          icon: Icons.hourglass_top,
          title: 'Verification Pending',
          subtitle: 'Your application is under review',
        );
      case VerificationStatus.verified:
        return const _GradientCard(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          icon: Icons.verified_user_outlined,
          title: 'Verified Student',
          subtitle: 'Your student status has been confirmed',
        );
      case VerificationStatus.rejected:
        return const _GradientCard(
          colors: [Color(0xFFFFB74D), Color(0xFFD84315)],
          icon: Icons.warning_amber_outlined,
          title: 'Verification Needs Attention',
          subtitle: 'Please review the message below',
        );
      case VerificationStatus.notSubmitted:
        return const _GradientCard(
          colors: [Color(0xFF455A64), Color(0xFF37474F)],
          icon: Icons.cancel_outlined,
          title: 'Not Verified',
          subtitle: 'You haven\'t submitted your verification yet',
        );
    }
  }
}

class _GradientCard extends StatelessWidget {
  const _GradientCard({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final List<Color> colors;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
