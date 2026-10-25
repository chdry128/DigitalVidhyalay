// ============================================================
//  VERIFY CERTIFICATE — Certificate ID daal kar check karna
//
//  DEMO: abhi sirf isi phone me bane certificates check hote hain.
//  Backend lagne ke baad server se check hoga (kisi ka bhi
//  certificate). Tab tak "Website pe verify" button bhi hai.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import 'certificate_screen.dart';

class VerifyCertificateScreen extends StatefulWidget {
  const VerifyCertificateScreen({super.key});

  @override
  State<VerifyCertificateScreen> createState() => _VerifyCertificateScreenState();
}

class _VerifyCertificateScreenState extends State<VerifyCertificateScreen> {
  final TextEditingController _id = TextEditingController();
  bool _checked = false;
  CertificateRecord? _found;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    setState(() {
      _checked = true;
      _found = context.read<AppState>().findCertificate(_id.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Certificate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Icon(Icons.verified_user_outlined, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text('Certificate check karein', textAlign: TextAlign.center, style: AppText.h2),
          const SizedBox(height: 4),
          const Text(
            'Certificate ke neeche likha ID daalein, e.g. DV-2026-482913',
            textAlign: TextAlign.center,
            style: AppText.muted,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _id,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() => _checked = false),
            onSubmitted: (_) => _verify(),
            decoration: const InputDecoration(
              hintText: 'Certificate ID',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _id.text.trim().isEmpty ? null : _verify,
            child: const Text('Verify'),
          ),

          // ---------- Result ----------
          if (_checked) ...[
            const SizedBox(height: 20),
            if (_found != null) _FoundCard(record: _found!) else const _NotFoundCard(),
          ],

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => openLink(context, AppConfig.certificateVerifyUrl),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Website pe verify karein'),
          ),
        ],
      ),
    );
  }
}

class _FoundCard extends StatelessWidget {
  const _FoundCard({required this.record});

  final CertificateRecord record;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        side: const BorderSide(color: Color(0xFFBBF7D0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => CertificateScreen(record: record)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certificate verified ✓',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(record.studentName, style: AppText.cardTitle),
                    Text(record.title, style: AppText.small),
                    Text('Issued: ${record.dateLabel}', style: AppText.tiny),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  const _NotFoundCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Yeh certificate ID nahi mila. ID dobara check karein, ya website pe verify karein.',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
