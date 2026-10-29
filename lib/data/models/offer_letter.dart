// ============================================================
//  OFFER LETTER MODEL — Student ke official internship offer letters
// ============================================================

class OfferLetterRecord {
  final int id;
  final String offerRefNo;
  final String programTitle;
  final String category;
  final int durationWeeks;
  final DateTime issuedAt;
  final String? pdfDownloadUrl;
  final String? verificationUrl;

  const OfferLetterRecord({
    required this.id,
    required this.offerRefNo,
    required this.programTitle,
    required this.category,
    required this.durationWeeks,
    required this.issuedAt,
    this.pdfDownloadUrl,
    this.verificationUrl,
  });

  String get dateLabel {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'offer_ref_no': offerRefNo,
        'program_title': programTitle,
        'category': category,
        'duration_weeks': durationWeeks,
        'issued_at': issuedAt.toIso8601String(),
        'pdf_download_url': pdfDownloadUrl,
        'verification_url': verificationUrl,
      };

  factory OfferLetterRecord.fromJson(Map<String, dynamic> json) {
    return OfferLetterRecord.fromApi(json);
  }

  factory OfferLetterRecord.fromApi(Map<String, dynamic> json) {
    final rawDate = DateTime.tryParse(
          (json['issued_at'] as String?) ?? (json['created_at'] as String?) ?? '',
        ) ??
        DateTime.now();

    return OfferLetterRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      offerRefNo: (json['offer_ref_no'] as String?) ?? '',
      programTitle: (json['program_title'] as String?) ?? 'Internship Program',
      category: (json['category'] as String?) ?? 'Technical Training',
      durationWeeks: (json['duration_weeks'] as num?)?.toInt() ?? 4,
      issuedAt: rawDate,
      pdfDownloadUrl: json['pdf_download_url'] as String?,
      verificationUrl: json['verification_url'] as String?,
    );
  }
}
