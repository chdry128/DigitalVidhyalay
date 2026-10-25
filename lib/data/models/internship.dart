// ============================================================
//  INTERNSHIP MODEL — Ek internship me kya information hoti hai
//
//  type ki 4 values ho sakti hain: paid, free, stipend, project
// ============================================================

class Internship {
  final int id;
  final String title;
  final String domain; // e.g. "Software Development", "AI & ML"
  final String type; // paid / free / stipend / project
  final int fee; // Rupees me (free / stipend ke liye 0)
  final String? stipend; // e.g. "₹1,000/week" — sirf stipend type me
  final int weeks;
  final String? role; // Stipend internship ka role, e.g. "Digital Marketing Associate"
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

  bool get isPaid => type == 'paid';
  bool get isFree => type == 'free';
  bool get isStipend => type == 'stipend';
  bool get isProject => type == 'project';

  /// Card pe dikhne wala type, e.g. "PAID", "STIPEND"
  String get typeLabel => typeLabelFor(type);

  /// Card pe dikhne wala price, e.g. "₹39", "FREE", "₹1,000/week"
  String get priceLabel {
    if (isStipend) return stipend ?? 'Stipend';
    if (fee == 0) return 'FREE';
    return '₹$fee';
  }

  String get durationLabel => '$weeks weeks';

  /// Neeche wale button ka text
  String get actionLabel {
    if (isFree) return 'Enroll Free';
    if (isStipend) return 'Apply Now';
    return 'Enroll Now';
  }

  /// Tabs ke liye saare types (isi order me dikhte hain)
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

/// internships.json ka poora data: internships ki list +
/// "What you will experience" points (har internship pe dikhte hain)
class InternshipCatalog {
  final List<Internship> internships;
  final List<String> whatYouGet;

  const InternshipCatalog({required this.internships, required this.whatYouGet});

  factory InternshipCatalog.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = (json['internships'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> points = (json['whatYouGet'] as List<dynamic>?) ?? <dynamic>[];
    return InternshipCatalog(
      internships:
          list.map((i) => Internship.fromJson(i as Map<String, dynamic>)).toList(),
      whatYouGet: points.map((p) => p.toString()).toList(),
    );
  }

  static const InternshipCatalog empty = InternshipCatalog(internships: [], whatYouGet: []);
}
