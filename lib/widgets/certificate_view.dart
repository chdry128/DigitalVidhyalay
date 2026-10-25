// ============================================================
//  CERTIFICATE VIEW — App ke andar dikhne wala certificate
//
//  PDF wala design alag file me hai: lib/utils/certificate_pdf.dart
//  Dono me text same rakhna (sign ka naam AppConfig se aata hai).
// ============================================================
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../data/models/certificate.dart';

class CertificateView extends StatelessWidget {
  const CertificateView({super.key, required this.record});

  final CertificateRecord record;

  @override
  Widget build(BuildContext context) {
    const TextStyle small = TextStyle(fontSize: 11, color: AppColors.textMuted);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.navy, width: 3),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/logo.jpg', width: 64, height: 64),
            const SizedBox(height: 6),
            const Text(
              'DIGITAL VIDYALAYA',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Certificate of Completion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                color: AppColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            const Text('This is proudly presented to', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(
              record.studentName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              height: 1.5,
              width: 200,
              color: AppColors.primary,
            ),
            Text(record.achievementLine, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text(
              record.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            if (record.scorePercent != null) ...[
              const SizedBox(height: 4),
              Text('Quiz score: ${record.scorePercent}%', style: small),
            ],
            const SizedBox(height: 20),

            // ---------- Date · QR · ID ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.dateLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const Text('Date of issue', style: small),
                    ],
                  ),
                ),
                QrImageView(
                  data: record.verifyUrl,
                  version: QrVersions.auto,
                  size: 72,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const Text('Certificate ID', style: small),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ---------- Signature ----------
            Container(width: 150, height: 1, color: AppColors.textDark),
            const SizedBox(height: 4),
            const Text(
              AppConfig.certificateSignName,
              style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 13),
            ),
            const Text(AppConfig.certificateSignTitle, style: small),
          ],
        ),
      ),
    );
  }
}
