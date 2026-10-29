// ============================================================
//  VERIFY CERTIFICATE — Certificate ya Offer Letter ID daal kar check karna
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/repository/api_client.dart';
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
  bool _busy = false;
  bool _checked = false;
  CertificateRecord? _localRecord;
  Map<String, dynamic>? _apiVerifiedData;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _id.text.trim();
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _checked = false;
      _localRecord = null;
      _apiVerifiedData = null;
    });

    try {
      // 1. Try local API credential verification
      final res = await ApiClient.instance.get(
        'catalog/verify-credential.php',
        query: {'id': code},
      );

      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && data['is_valid'] == true) {
        if (mounted) {
          setState(() {
            _busy = false;
            _checked = true;
            _apiVerifiedData = data;
          });
        }
        return;
      }
    } catch (_) {
      // Fallback to local cache if offline or in mock mode
    }

    // 2. Check local AppState cache as fallback
    if (!mounted) return;
    final local = context.read<AppState>().findCertificate(code);
    setState(() {
      _busy = false;
      _checked = true;
      _localRecord = local;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Credential')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Icon(Icons.verified_user_outlined, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text('Credential Verify Karein', textAlign: TextAlign.center, style: AppText.h2),
          const SizedBox(height: 4),
          const Text(
            'Certificate No (e.g. DV-CERT-6C9E04C5) ya Offer Ref (e.g. DV/OFFER/2026/0004) daalein',
            textAlign: TextAlign.center,
            style: AppText.muted,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _id,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) {
              if (_checked) setState(() => _checked = false);
            },
            onSubmitted: (_) => _verify(),
            decoration: const InputDecoration(
              hintText: 'Credential ID / Reference No',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: (_id.text.trim().isEmpty || _busy) ? null : _verify,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Verify'),
          ),

          // ---------- Result ----------
          if (_checked) ...[
            const SizedBox(height: 20),
            if (_apiVerifiedData != null)
              _ApiVerifiedCard(data: _apiVerifiedData!)
            else if (_localRecord != null)
              _FoundCard(record: _localRecord!)
            else
              const _NotFoundCard(),
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

class _ApiVerifiedCard extends StatelessWidget {
  const _ApiVerifiedCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final String type = (data['type'] as String?) ?? 'Verified Credential';
    final String name = (data['student_name'] as String?) ?? 'Student';
    final String prog = (data['program_title'] as String?) ?? 'Program';
    final String? college = data['college_name'] as String?;
    final String? date = data['issue_date'] as String?;
    final String? credId = data['credential_id'] as String?;

    return Material(
      color: const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        side: const BorderSide(color: Color(0xFFBBF7D0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type Verified ✓',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      if (credId != null)
                        Text('ID: $credId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Text(name, style: AppText.cardTitle),
            const SizedBox(height: 2),
            Text(prog, style: AppText.small),
            if (college != null && college.isNotEmpty) Text('College: $college', style: AppText.tiny),
            if (date != null && date.isNotEmpty) Text('Issued: $date', style: AppText.tiny),
          ],
        ),
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
              'Yeh credential ID nahi mila. ID dobara check karein, ya website pe verify karein.',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
