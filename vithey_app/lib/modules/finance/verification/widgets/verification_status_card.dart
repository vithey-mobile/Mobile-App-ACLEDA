import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';

/// Status hero cards from `Verified.png`:
/// pending = orange, verified = green, notSubmitted = grey.
class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.pending:
        return const _GradientCard(
          colors: [Color(0xFFFF9F43), Color(0xFFE53935)],
          title: 'Verification Pending',
          subtitle: 'Your application is under review.',
        );
      case VerificationStatus.verified:
        return const _GradientCard(
          colors: [Color(0xFF8BC34A), Color(0xFF43A047)],
          title: 'Verified Success',
          subtitle: 'Your application has been confirmed.',
        );
      case VerificationStatus.rejected:
        // Fail state uses the grey Not Verified card from Verified.png.
        return const _GradientCard(
          colors: [Color(0xFF6B7280), Color(0xFF374151)],
          title: 'Not Verified',
          subtitle: "You haven't submitted your application yet.",
        );
      case VerificationStatus.notSubmitted:
        return const _GradientCard(
          colors: [Color(0xFF6B7280), Color(0xFF374151)],
          title: 'Not Verified',
          subtitle: "You haven't submitted your application yet.",
        );
    }
  }
}

class _GradientCard extends StatelessWidget {
  const _GradientCard({
    required this.colors,
    required this.title,
    required this.subtitle,
  });

  final List<Color> colors;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          // Translucent circle + white outline clock (Verified.png).
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
