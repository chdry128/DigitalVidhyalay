// ============================================================
//  CERTIFICATE PDF — Download / share hone wali PDF (A4 landscape)
//
//  Design badalna ho to yahan badlein. App wala design:
//  lib/widgets/certificate_view.dart
//
//  ⚠ PDF ke font English ke liye hain. Agar student ka naam
//  Hindi (Devanagari) me likha hai to PDF me naam nahi dikhega —
//  isliye profile me naam English me likhwayein.
// ============================================================
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../config/app_config.dart';
import '../data/models/certificate.dart';

Future<Uint8List> buildCertificatePdf(CertificateRecord record) async {
  final ByteData logoData = await rootBundle.load('assets/images/logo.jpg');
  final pw.MemoryImage logo = pw.MemoryImage(logoData.buffer.asUint8List());

  // Rang (app_colors.dart jaise hi)
  final PdfColor navy = PdfColor.fromInt(0xFF011E60);
  final PdfColor orange = PdfColor.fromInt(0xFFEA580C);
  final PdfColor grey = PdfColor.fromInt(0xFF78716C);
  final PdfColor dark = PdfColor.fromInt(0xFF1C1917);

  final pw.TextStyle small = pw.TextStyle(fontSize: 10, color: grey);

  final pw.Document doc = pw.Document(
    title: 'Certificate ${record.id}',
    author: AppConfig.companyName,
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: navy, width: 4)),
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 22),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: orange, width: 1)),
          child: pw.Column(
            children: [
              pw.Image(logo, width: 78, height: 78),
              pw.SizedBox(height: 6),
              pw.Text(
                'DIGITAL VIDYALAYA',
                style: pw.TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'CERTIFICATE OF COMPLETION',
                style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 30, color: navy),
              ),
              pw.SizedBox(height: 14),
              pw.Text('This is proudly presented to', style: pw.TextStyle(fontSize: 13, color: grey)),
              pw.SizedBox(height: 8),
              pw.Text(
                record.studentName,
                style: pw.TextStyle(font: pw.Font.timesBold(), fontSize: 32, color: dark),
              ),
              pw.Container(width: 300, height: 1.5, color: orange, margin: const pw.EdgeInsets.only(top: 4, bottom: 10)),
              pw.Text(record.achievementLine, style: pw.TextStyle(fontSize: 13, color: grey)),
              pw.SizedBox(height: 6),
              pw.Text(
                record.title,
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: dark),
              ),
              if (record.scorePercent != null) ...[
                pw.SizedBox(height: 4),
                pw.Text('Quiz score: ${record.scorePercent}%', style: small),
              ],
              pw.Spacer(),

              // Date · QR · Signature
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(record.dateLabel, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date of issue', style: small),
                        pw.SizedBox(height: 8),
                        pw.Text(record.id, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Certificate ID', style: small),
                      ],
                    ),
                  ),
                  pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: record.verifyUrl,
                        width: 78,
                        height: 78,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Scan to verify', style: small),
                    ],
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(width: 170, height: 1, color: dark),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          AppConfig.certificateSignName,
                          style: pw.TextStyle(font: pw.Font.timesItalic(), fontSize: 14),
                        ),
                        pw.Text(AppConfig.certificateSignTitle, style: small),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return doc.save();
}
