// ============================================================
//  INTERNSHIP MODEL — Ek internship me kya information hoti hai
//
//  2 constructors:
//   • fromJson    → assets/data/internships.json (mock)
//   • fromApiJson → catalog/internships.php (backend)
//
//  Backend fields (regular):
//    id, is_stipend, title, category, description, duration_weeks,
//    fee_amount, is_free, price_badge, internship_type
//
//  Backend fields (stipend):
//    id, is_stipend=true, title, designation, category, description,
//    work_mode, duration_weeks, stipend_amount, stipend_type,
//    price_badge, internship_type
// ============================================================

class Internship {
  final int id;
  final String title;
  final String domain;       // category
  final String type;         // paid / free / stipend / project
  final int fee;             // Rupees (0 for free/stipend)
  final String? stipend;     // "₹1,000/week" — only for stipend type
  final int weeks;
  final String? role;        // Stipend internship role
  final String description;

  const Internship({
    required this.id,
    required this.title,
    required this.domain,
    required this.type,
    required this.fee,
    required this.stipend,
    required this.weeks,
    required this.role,
    required this.description,
  });

  // ── Mock JSON (assets/data/internships.json) ───────────────
  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as int,
      title: json['title'] as String,
      domain: (json['domain'] as String?) ?? 'Other',
      type: (json['type'] as String?) ?? 'paid',
      fee: (json['fee'] as num?)?.toInt() ?? 0,
      stipend: json['stipend'] as String?,
      weeks: (json['weeks'] as num?)?.toInt() ?? 0,
      role: json['role'] as String?,
      description: (json['description'] as String?) ?? '',
    );
  }

  // ── Real API (catalog/internships.php) ─────────────────────
  factory Internship.fromApiJson(Map<String, dynamic> json) {
    final isStipend = (json['is_stipend'] as bool?) ?? false;
    final feeAmt = (json['fee_amount'] as num?)?.toInt() ?? 0;
    final stipendAmt = (json['stipend_amount'] as num?)?.toDouble() ?? 0;

    String type;
    if (isStipend) {
      type = 'stipend';
    } else if (feeAmt == 0) {
      type = 'free';
    } else {
      // internship_type from DB: "Standard Internship", "Project-Based", etc.
      final rawType = (json['internship_type'] as String?) ?? '';
      type = rawType.toLowerCase().contains('project') ? 'project' : 'paid';
    }

    String? stipendBadge;
    if (isStipend && stipendAmt > 0) {
      final stipendType =
          (json['stipend_type'] as String? ?? 'per_week')
              .replaceAll('_', ' ');
      stipendBadge = '₹${stipendAmt.toStringAsFixed(0)} / $stipendType';
    }

    return Internship(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? 'Untitled',
      domain: (json['category'] as String?) ?? 'Other',
      type: type,
      fee: isStipend ? 0 : feeAmt,
      stipend: stipendBadge,
      weeks: (json['duration_weeks'] as num?)?.toInt() ?? 4,
      role: isStipend ? (json['designation'] as String?) : null,
      description: (json['description'] as String?) ?? '',
    );
  }

  bool get isPaid => type == 'paid';
  bool get isFree => type == 'free';
  bool get isStipend => type == 'stipend';
  bool get isProject => type == 'project';

  String get typeLabel => typeLabelFor(type);

  String get priceLabel {
    if (isStipend) return stipend ?? 'Stipend';
    if (fee == 0) return 'FREE';
    return '₹$fee';
  }

  String get durationLabel => '$weeks weeks';

  String get actionLabel {
    if (isFree) return 'Enroll Free';
    if (isStipend) return 'Apply Now';
    return 'Enroll Now';
  }

  static const List<String> allTypes = ['paid', 'free', 'stipend', 'project'];

  static String typeLabelFor(String type) {
    switch (type) {
      case 'free':
        return 'FREE';
      case 'stipend':
        return 'STIPEND';
      case 'project':
        return 'PROJECT';
      default:
        return 'PAID';
    }
  }
}

// ─────────────────────────────────────────────────────────────
class InternshipCatalog {
  final List<Internship> internships;
  final List<String> whatYouGet;

  const InternshipCatalog(
      {required this.internships, required this.whatYouGet});

  factory InternshipCatalog.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list =
        (json['internships'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> points =
        (json['whatYouGet'] as List<dynamic>?) ?? <dynamic>[];
    return InternshipCatalog(
      internships: list
          .map((i) => Internship.fromJson(i as Map<String, dynamic>))
          .toList(),
      whatYouGet: points.map((p) => p.toString()).toList(),
    );
  }

  static const InternshipCatalog empty =
      InternshipCatalog(internships: [], whatYouGet: []);
}
