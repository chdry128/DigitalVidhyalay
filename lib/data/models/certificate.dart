// ============================================================
//  CERTIFICATE MODEL — Ek certificate ki details
//  Course quiz pass karne ya internship poori karne pe banta hai.
// ============================================================
import '../../config/app_config.dart';

class CertificateRecord {
  final String id; // e.g. DV-CERT-6C9E04C5 or DV-2026-482913
  final int? numericId;
  final String type; // "course" ya "internship"
  final int itemId; // Course / internship ka id
  final String title; // Course / internship ka naam
  final String studentName;
  final DateTime date;
  final int? scorePercent; // Course quiz ka score (internship me null)
  final String? category;
  final int? durationWeeks;
  final String? certificateUrl;
  final String? pdfDownloadUrl;
  final String? verificationUrl;

  const CertificateRecord({
    required this.id,
    this.numericId,
    required this.type,
    required this.itemId,
    required this.title,
    required this.studentName,
    required this.date,
    this.scorePercent,
    this.category,
    this.durationWeeks,
    this.certificateUrl,
    this.pdfDownloadUrl,
    this.verificationUrl,
  });

  bool get isCourse => type == 'course';

  /// Certificate pe likhne wali line
  String get achievementLine =>
      isCourse ? 'for successfully completing the online course' : 'for successfully completing the internship program';

  /// QR code isi link pe jata hai
  String get verifyUrl => verificationUrl ?? '${AppConfig.certificateVerifyUrl}?id=$id';

  /// "26 October 2026"
  String get dateLabel {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numericId': numericId,
        'type': type,
        'itemId': itemId,
        'title': title,
        'studentName': studentName,
        'date': date.toIso8601String(),
        'scorePercent': scorePercent,
        'category': category,
        'durationWeeks': durationWeeks,
        'certificateUrl': certificateUrl,
        'pdfDownloadUrl': pdfDownloadUrl,
        'verificationUrl': verificationUrl,
      };

  factory CertificateRecord.fromJson(Map<String, dynamic> json) => CertificateRecord(
        id: (json['id'] as String?) ?? '',
        numericId: (json['numericId'] as num?)?.toInt(),
        type: (json['type'] as String?) ?? 'course',
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        title: (json['title'] as String?) ?? '',
        studentName: (json['studentName'] as String?) ?? '',
        date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
        scorePercent: (json['scorePercent'] as num?)?.toInt(),
        category: json['category'] as String?,
        durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
        certificateUrl: json['certificateUrl'] as String?,
        pdfDownloadUrl: json['pdfDownloadUrl'] as String?,
        verificationUrl: json['verificationUrl'] as String?,
      );

  factory CertificateRecord.fromApi(Map<String, dynamic> json, {String? defaultStudentName}) {
    final certNum = (json['certificate_number'] as String?) ?? (json['id']?.toString() ?? '');
    final dateStr = (json['issue_date'] as String?) ?? (json['created_at'] as String?) ?? '';
    final rawDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    return CertificateRecord(
      id: certNum,
      numericId: (json['id'] as num?)?.toInt(),
      type: 'internship',
      itemId: (json['internship_id'] as num?)?.toInt() ?? 0,
      title: (json['program_title'] as String?) ?? (json['title'] as String?) ?? 'Internship Completion Certificate',
      studentName: defaultStudentName ?? 'Student',
      date: rawDate,
      scorePercent: null,
      category: json['category'] as String?,
      durationWeeks: (json['duration_weeks'] as num?)?.toInt(),
      certificateUrl: json['certificate_url'] as String?,
      pdfDownloadUrl: json['pdf_download_url'] as String?,
      verificationUrl: json['verification_url'] as String?,
    );
  }
}
