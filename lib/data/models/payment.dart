// ============================================================
//  PAYMENT MODELS
//   • PurchaseItem  → kya khareed rahe hain (course / internship)
//   • PaymentRecord → payment ho gaya, uski receipt
// ============================================================
import 'course.dart';
import 'internship.dart';

class PurchaseItem {
  final String type; // "course" ya "internship"
  final int id;
  final String title;
  final int amount; // Rupees

  const PurchaseItem({
    required this.type,
    required this.id,
    required this.title,
    required this.amount,
  });

  bool get isCourse => type == 'course';

  factory PurchaseItem.fromCourse(Course course) => PurchaseItem(
        type: 'course',
        id: course.id,
        title: course.title,
        amount: course.price,
      );

  factory PurchaseItem.fromInternship(Internship internship) => PurchaseItem(
        type: 'internship',
        id: internship.id,
        title: internship.title,
        amount: internship.fee,
      );
}

class PaymentRecord {
  final String orderId;
  final String type; // "course" ya "internship"
  final int itemId;
  final String title;
  final int amount;
  final String method; // UPI / Card / Net Banking
  final DateTime date;

  const PaymentRecord({
    required this.orderId,
    required this.type,
    required this.itemId,
    required this.title,
    required this.amount,
    required this.method,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'type': type,
        'itemId': itemId,
        'title': title,
        'amount': amount,
        'method': method,
        'date': date.toIso8601String(),
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        orderId: (json['orderId'] as String?) ?? '',
        type: (json['type'] as String?) ?? 'course',
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        title: (json['title'] as String?) ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        method: (json['method'] as String?) ?? 'UPI',
        date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      );

  /// "24 Oct 2026"
  String get dateLabel {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
