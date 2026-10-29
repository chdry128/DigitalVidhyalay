// ============================================================
//  MY CERTIFICATES — Student ke saare certificates
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import 'certificate_screen.dart';

/// Certificates ki list — Profile aur Meri Padhai dono me use hoti hai
class CertificateList extends StatefulWidget {
  const CertificateList({super.key});

  @override
  State<CertificateList> createState() => _CertificateListState();
}

class _CertificateListState extends State<CertificateList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadCertificates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<CertificateRecord> list = state.certificates;

    if (state.isLoadingCertificates && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.certificatesError != null && list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Certificates load nahi ho paye', style: AppText.title),
              const SizedBox(height: 8),
              Text(
                state.certificatesError!,
                textAlign: TextAlign.center,
                style: AppText.small,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<AppState>().loadCertificates(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Dobara koshish karein'),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<AppState>().loadCertificates(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'Abhi koi certificate nahi',
              message: 'Course ke saare lessons dekh kar quiz pass karein, ya internship poori karein — verified certificate yahan aayega.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().loadCertificates(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
        itemBuilder: (context, index) {
          final CertificateRecord c = list[index];
          return AppCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => CertificateScreen(record: c)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: AppText.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        '${c.category ?? (c.isCourse ? "Online Course" : "Internship")} · ${c.dateLabel}',
                        style: AppText.small,
                      ),
                      Text('No: ${c.id}', style: AppText.tiny),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MyCertificatesScreen extends StatelessWidget {
  const MyCertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: const CertificateList(),
    );
  }
}
