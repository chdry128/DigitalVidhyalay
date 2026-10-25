// ============================================================
//  INTERNSHIP PROGRESS — Enrolled internship ke weekly tasks
//
//  Har week ka naam / kaam neeche _weekPlan() me hai.
//  Backend lagne ke baad yeh tasks server se aayenge
//  (har internship ke apne alag tasks).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/models/internship.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/internship_card.dart';
import 'certificate_screen.dart';

class InternshipProgressScreen extends StatelessWidget {
  const InternshipProgressScreen({super.key, required this.internship});

  final Internship internship;

  /// Week ka [title, kaam]. Abhi sab internships ke liye ek jaisa plan.
  List<String> _weekPlan(int week) {
    final int total = internship.weeks;
    if (week == 1) {
      return ['Orientation & setup', 'Program samjhein, zaroori tools install karein, mentor se milein.'];
    }
    if (week == total) {
      return ['Final project & certificate', 'Final project / report submit karein. Review ke baad certificate milega.'];
    }
    if (week == total - 1 && total >= 4) {
      return ['Mentor review', 'Ab tak ke kaam par mentor ka feedback lein aur sudhaar karein.'];
    }
    return ['Practical work — Part ${week - 1}', 'Is week ka assignment complete karke submit karein.'];
  }

  /// Saare weeks poore → certificate banao (pehle se hai to wahi) aur dikhao
  Future<void> _openCertificate(BuildContext context, AppState state) async {
    final CertificateRecord record = await state.issueCertificate(
      type: 'internship',
      itemId: internship.id,
      title: internship.title,
    );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CertificateScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int done = state.completedWeekCount(internship);
    final bool finished = done == internship.weeks && internship.weeks > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('My Internship')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ---------- Upar ka summary ----------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeBadge(type: internship.type),
                const SizedBox(height: 8),
                Text(internship.title, style: AppText.h2),
                const SizedBox(height: 4),
                Text('${internship.domain} · Remote · ${internship.durationLabel}', style: AppText.small),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: state.internshipProgress(internship),
                          minHeight: 8,
                          color: finished ? AppColors.success : AppColors.primary,
                          backgroundColor: const Color(0xFFE7E5E4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('$done/${internship.weeks} weeks', style: AppText.small),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Weekly plan ----------
          const Text('Weekly plan', style: AppText.title),
          const SizedBox(height: 4),
          const Text('Week ka kaam poora hone par checkbox lagayein.', style: AppText.small),
          const SizedBox(height: 10),
          for (int week = 1; week <= internship.weeks; week++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WeekTile(
                week: week,
                title: _weekPlan(week)[0],
                task: _weekPlan(week)[1],
                done: state.isWeekDone(internship, week),
                onChanged: (value) => state.setWeekDone(internship, week, value),
              ),
            ),

          // ---------- Certificate ----------
          const SizedBox(height: 6),
          AppCard(
            onTap: finished ? () => _openCertificate(context, state) : null,
            child: Row(
              children: [
                Icon(
                  finished ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                  color: finished ? AppColors.primary : AppColors.textMuted,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Work Experience Certificate', style: AppText.cardTitle),
                      Text(
                        finished ? 'Certificate dekhein / download karein' : 'Saare weeks complete karne par milega',
                        style: AppText.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Mentor help ----------
          OutlinedButton.icon(
            onPressed: () => openWhatsApp(
              context,
              message: 'Hello, main "${internship.title}" internship me hoon. Mujhe mentor se help chahiye.',
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Mentor se WhatsApp par baat karein'),
          ),
        ],
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    required this.week,
    required this.title,
    required this.task,
    required this.done,
    required this.onChanged,
  });

  final int week;
  final String title;
  final String task;
  final bool done;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => onChanged(!done),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.successLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'W$week',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: done ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.cardTitle.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.textMuted : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(task, style: AppText.small),
              ],
            ),
          ),
          Checkbox(
            value: done,
            activeColor: AppColors.success,
            onChanged: (value) => onChanged(value ?? false),
          ),
        ],
      ),
    );
  }
}
