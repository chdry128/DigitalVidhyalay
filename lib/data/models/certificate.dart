// ============================================================
//  CERTIFICATE MODEL — Ek certificate ki details
//  Course quiz pass karne ya internship poori karne pe banta hai.
// ============================================================
import '../../config/app_config.dart';

class CertificateRecord {
  final String id; // e.g. DV-2026-482913
  final String type; // "course" ya "internship"
  final int itemId; // Course / internship ka id
  final String title; // Course / internship ka naam
  final String studentName;
  final DateTime date;
  final int? scorePercent; // Course quiz ka score (internship me null)

  const CertificateRecord({
    required this.id,
    required this.type,
    required this.itemId,
    required this.title,
    required this.studentName,
    required this.date,
    this.scorePercent,
  });

  bool get isCourse => type == 'course';

  /// Certificate pe likhne wali line
  String get achievementLine =>
      isCourse ? 'for successfully completing the online course' : 'for successfully completing the internship program';

  /// QR code isi link pe jata hai
  String get verifyUrl => '${AppConfig.certificateVerifyUrl}?id=$id';

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
        'type': type,
        'itemId': itemId,
        'title': title,
        'studentName': studentName,
        'date': date.toIso8601String(),
        'scorePercent': scorePercent,
      };

  factory CertificateRecord.fromJson(Map<String, dynamic> json) => CertificateRecord(
        id: (json['id'] as String?) ?? '',
        type: (json['type'] as String?) ?? 'course',
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        title: (json['title'] as String?) ?? '',
        studentName: (json['studentName'] as String?) ?? '',
        date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
        scorePercent: (json['scorePercent'] as num?)?.toInt(),
      );
}
