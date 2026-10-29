// ============================================================
//  CERTIFICATE SCREEN — Official Certificate details & verification
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.record});

  final CertificateRecord record;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.record.verifyUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification link copied to clipboard')),
    );
  }

  void _openVerification() {
    openLink(context, widget.record.verifyUrl);
  }

  void _openPdfDownload() {
    if (widget.record.pdfDownloadUrl != null && widget.record.pdfDownloadUrl!.isNotEmpty) {
      openLink(context, widget.record.pdfDownloadUrl!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Official PDF URL is not available for this record.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CertificateRecord record = widget.record;

    return Scaffold(
      appBar: AppBar(title: const Text('Official Certificate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ── Verified Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verified Credential',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        'Credential ID: ${record.id}',
                        style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Certificate Details Card ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.title, style: AppText.cardTitle),
                          if (record.category != null && record.category!.isNotEmpty)
                            Text(record.category!, style: AppText.small),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _InfoRow(label: 'Certificate No', value: record.id),
                const SizedBox(height: 8),
                _InfoRow(label: 'Program', value: record.title),
                if (record.durationWeeks != null && record.durationWeeks! > 0) ...[
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Duration', value: '${record.durationWeeks} Weeks'),
                ],
                const SizedBox(height: 8),
                _InfoRow(label: 'Issue Date', value: record.dateLabel),
                const SizedBox(height: 8),
                const _InfoRow(label: 'Status', value: 'Issued & Active', isSuccess: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Actions ──
          if (record.pdfDownloadUrl != null && record.pdfDownloadUrl!.isNotEmpty) ...[
            ElevatedButton.icon(
              onPressed: _openPdfDownload,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Official Certificate PDF'),
            ),
            const SizedBox(height: 10),
          ],

          OutlinedButton.icon(
            onPressed: _openVerification,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Verify Credential Online'),
          ),
          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _copyLink,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy Verification Link'),
          ),

          const SizedBox(height: 12),
          const Text(
            'Official certificates are digitally verified by Digital Vidyalaya and recognized for internship completion.',
            textAlign: TextAlign.center,
            style: AppText.tiny,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isSuccess = false,
  });

  final String label;
  final String value;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.muted),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSuccess ? AppColors.success : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
