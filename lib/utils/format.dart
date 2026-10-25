// ============================================================
//  FORMAT HELPERS — Numbers ko sundar dikhane ke chhote functions
// ============================================================

/// 4860 → "4,860"
String formatCount(int value) {
  final String digits = value.abs().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int fromEnd = digits.length - i;
    out.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) out.write(',');
  }
  return value < 0 ? '-$out' : out.toString();
}
