// ============================================================
//  CERTIFICATE SCREEN — Certificate dekhna, PDF download / share
//
//  • "Download PDF" → phone ka print/save screen ("Save as PDF")
//  • "Share" → WhatsApp, email wagairah pe PDF bhejna
// ============================================================
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../utils/certificate_pdf.dart';
import '../widgets/certificate_view.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.record});

  final CertificateRecord record;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _busy = false;

  String get _fileName => 'Certificate_${widget.record.id}.pdf';

  Future<void> _run(Future<void> Function(Uint8List bytes) action) async {
    setState(() => _busy = true);
    try {
      final Uint8List bytes = await buildCertificatePdf(widget.record);
      await action(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF nahi ban payi: $e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _download() => _run((bytes) async {
        await Printing.layoutPdf(onLayout: (format) async => bytes, name: _fileName);
      });

  Future<void> _share() => _run((bytes) async {
        await Printing.sharePdf(bytes: bytes, filename: _fileName);
      });

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.record.verifyUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verify link copy ho gaya')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CertificateRecord record = widget.record;

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verified certificate · ID ${record.id}',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CertificateView(record: record),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _busy ? null : _download,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded),
            label: const Text('Download PDF'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : _share,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share Certificate'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _copyLink,
            icon: const Icon(Icons.link_rounded, size: 18),
            label: const Text('Verify link copy karein'),
          ),
          const SizedBox(height: 4),
          const Text(
            'Download PDF dabane par "Save as PDF" chunein — certificate phone me save ho jayega.',
            textAlign: TextAlign.center,
            style: AppText.tiny,
          ),
        ],
      ),
    );
  }
}
