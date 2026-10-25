// ============================================================
//  COURSE INFO BITS — Course card ke chhote hisse
//   • BadgeLabel  → "BESTSELLER" / "NEW" tag
//   • RatingRow   → ★ 4.8 · 4,860 students
//   • PriceRow    → ₹9  ₹499  98% off
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/course.dart';
import '../utils/format.dart';

class BadgeLabel extends StatelessWidget {
  const BadgeLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bool isNew = text.toUpperCase() == 'NEW';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: isNew ? const Color(0xFF0369A1) : const Color(0xFF92400E),
        ),
      ),
    );
  }
}

/// Rating aur students. Agar dono 0 hain to kuch nahi dikhta.
class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.course, this.fontSize = 12});

  final Course course;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (course.rating <= 0 && course.students <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (course.rating > 0) ...[
          Icon(Icons.star_rounded, size: fontSize + 3, color: AppColors.star),
          const SizedBox(width: 2),
          Text(
            course.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
        if (course.rating > 0 && course.students > 0)
          Text(' · ', style: TextStyle(fontSize: fontSize, color: AppColors.textMuted)),
        if (course.students > 0)
          Flexible(
            child: Text(
              '${formatCount(course.students)} students',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({super.key, required this.course, this.big = false});

  final Course course;
  final bool big; // true = detail page ke neeche wala bada price

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          course.priceLabel,
          style: AppText.price.copyWith(fontSize: big ? 22 : 16),
        ),
        if (course.discountPercent > 0) ...[
          Text(
            '₹${course.mrp}',
            style: TextStyle(
              fontSize: big ? 13 : 12,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '${course.discountPercent}% off',
            style: TextStyle(
              fontSize: big ? 13 : 12,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
