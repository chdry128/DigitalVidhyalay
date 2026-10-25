// ============================================================
//  INTERNSHIP DETAIL — Ek internship ki poori jaankari
//
//  "What you will experience" ke points:
//  assets/data/internships.json → "whatYouGet"
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/internship.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/internship_card.dart';
import 'internship_progress_screen.dart';
import 'payment_screen.dart';
import 'stipend_apply_screen.dart';

class InternshipDetailScreen extends StatelessWidget {
  const InternshipDetailScreen({super.key, required this.internship});

  final Internship internship;

  String _buttonLabel(bool enrolled, bool applied) {
    if (enrolled) return 'Open Internship';
    if (applied) return 'Applied ✓';
    return internship.actionLabel;
  }

  /// Neeche wala button dabane pe kya ho:
  ///  enroll hai → progress  ·  free → seedha enroll  ·  stipend → form  ·  paid → payment
  Future<void> _onAction(BuildContext context, AppState state) async {
    if (state.isInternshipEnrolled(internship.id)) {
      _openProgress(context);
    } else if (internship.isFree) {
      await state.enrollFreeInternship(internship);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enroll ho gaye! Meri Padhai me dekhein.')),
      );
      _openProgress(context);
    } else if (internship.isStipend) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => StipendApplyScreen(internship: internship)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentScreen(item: PurchaseItem.fromInternship(internship)),
        ),
      );
    }
  }

  void _openProgress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => InternshipProgressScreen(internship: internship)),
    );
  }

  String get _priceNote {
    if (internship.isStipend) return 'Aapko milega';
    if (internship.fee == 0) return 'Koi fee nahi';
    return 'One-time fee';
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<String> points = state.internshipCatalog.whatYouGet;
    final bool enrolled = state.isInternshipEnrolled(internship.id);
    final bool applied = internship.isStipend && state.hasApplied(internship.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Internship Details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---------- Navy header ----------
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeBadge(type: internship.type),
                const SizedBox(height: 10),
                Text(
                  internship.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (internship.role != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${internship.role}',
                    style: const TextStyle(color: Color(0xFFFDBA74), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  internship.description,
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip(icon: Icons.schedule_rounded, text: internship.durationLabel),
                    const _HeroChip(icon: Icons.laptop_mac_rounded, text: 'Remote'),
                    const _HeroChip(icon: Icons.workspace_premium_outlined, text: 'Certificate'),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- What you will experience ----------
                if (points.isNotEmpty) ...[
                  const Text('What you will experience', style: AppText.title),
                  const SizedBox(height: 10),
                  for (final String point in points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_rounded, color: AppColors.success, size: 19),
                          const SizedBox(width: 8),
                          Expanded(child: Text(point, style: AppText.body)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                ],

                // ---------- Details table ----------
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Domain', value: internship.domain),
                      const Divider(),
                      _InfoRow(label: 'Duration', value: internship.durationLabel),
                      const Divider(),
                      const _InfoRow(label: 'Mode', value: 'Remote / Online'),
                      const Divider(),
                      _InfoRow(
                        label: internship.isStipend ? 'Stipend' : 'Fee',
                        value: internship.priceLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Help ----------
                AppCard(
                  onTap: () => openWhatsApp(
                    context,
                    message: 'Hello, mujhe "${internship.title}" internship ke baare me jaankari chahiye.',
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_outlined, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Koi sawaal hai? WhatsApp par poochein',
                          style: AppText.cardTitle,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ---------- Neeche: price + button ----------
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(internship.priceLabel, style: AppText.price.copyWith(fontSize: 20)),
                      Text(
                        _priceNote,
                        style: const TextStyle(fontSize: 12, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: ElevatedButton(
                    // Stipend me apply ho chuka → button band
                    onPressed: applied ? null : () => _onAction(context, state),
                    child: Text(_buttonLabel(enrolled, applied)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Text(label, style: AppText.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
