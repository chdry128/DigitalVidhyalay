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
  final int? paymentId;
  final String orderId;
  final String? paymentIdRef; // razorpay_payment_id
  final String type; // "course" ya "internship"
  final int itemId;
  final String title;
  final int amount;
  final double? finalAmount;
  final String currency;
  final String status; // 'captured', 'created', 'failed'
  final String method; // UPI / Card / Net Banking / Razorpay
  final DateTime date;
  final DateTime? paidAt;
  final String? receiptUrl;

  const PaymentRecord({
    this.paymentId,
    required this.orderId,
    this.paymentIdRef,
    required this.type,
    required this.itemId,
    required this.title,
    required this.amount,
    this.finalAmount,
    this.currency = 'INR',
    this.status = 'captured',
    required this.method,
    required this.date,
    this.paidAt,
    this.receiptUrl,
  });

  bool get isCaptured => status.toLowerCase() == 'captured' || status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'created' || status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  String get statusLabel {
    if (isCaptured) return 'Captured';
    if (isPending) return 'Created';
    if (isFailed) return 'Failed';
    return status.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'orderId': orderId,
        'paymentIdRef': paymentIdRef,
        'type': type,
        'itemId': itemId,
        'title': title,
        'amount': amount,
        'finalAmount': finalAmount,
        'currency': currency,
        'status': status,
        'method': method,
        'date': date.toIso8601String(),
        'paidAt': paidAt?.toIso8601String(),
        'receiptUrl': receiptUrl,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        paymentId: (json['paymentId'] as num?)?.toInt(),
        orderId: (json['orderId'] as String?) ?? '',
        paymentIdRef: json['paymentIdRef'] as String?,
        type: (json['type'] as String?) ?? 'course',
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        title: (json['title'] as String?) ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        finalAmount: (json['finalAmount'] as num?)?.toDouble(),
        currency: (json['currency'] as String?) ?? 'INR',
        status: (json['status'] as String?) ?? 'captured',
        method: (json['method'] as String?) ?? 'UPI',
        date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
        paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'] as String) : null,
        receiptUrl: json['receiptUrl'] as String?,
      );

  factory PaymentRecord.fromApi(Map<String, dynamic> json) {
    final int pid = (json['payment_id'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0;
    final String orderId = (json['razorpay_order_id'] as String?) ?? 'ORDER-$pid';
    final String? payRef = json['razorpay_payment_id'] as String?;
    final double amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final double? finalAmt = (json['final_amount'] as num?)?.toDouble();
    final String curr = (json['currency'] as String?) ?? 'INR';
    final String stat = (json['status'] as String?) ?? 'created';
    final String itemTitle = (json['item_title'] as String?) ??
        (json['internship_title'] as String?) ??
        (json['course_name'] as String?) ??
        'Digital Vidyalaya Program';

    final isCourse = json['course_id'] != null && (json['course_id'] as num).toInt() > 0;
    final itemId = isCourse
        ? ((json['course_id'] as num?)?.toInt() ?? 0)
        : ((json['internship_id'] as num?)?.toInt() ?? 0);

    final dateStr = (json['created_at'] as String?) ?? '';
    final rawDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    final paidStr = json['paid_at'] as String?;
    final paidDate = paidStr != null ? DateTime.tryParse(paidStr) : null;

    return PaymentRecord(
      paymentId: pid,
      orderId: orderId,
      paymentIdRef: payRef,
      type: isCourse ? 'course' : 'internship',
      itemId: itemId,
      title: itemTitle,
      amount: amt.round(),
      finalAmount: finalAmt,
      currency: curr,
      status: stat,
      method: payRef != null ? 'Razorpay' : 'Online',
      date: rawDate,
      paidAt: paidDate,
      receiptUrl: json['receipt_url'] as String?,
    );
  }

  /// "24 Oct 2026"
  String get dateLabel {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
