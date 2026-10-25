// ============================================================
//  INTERNSHIP CARD — Internship ka card + type badge (PAID / FREE ...)
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/internship.dart';
import 'app_card.dart';

class InternshipCard extends StatelessWidget {
  const InternshipCard({super.key, required this.internship, required this.onTap});

  final Internship internship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeBadge(type: internship.type),
                const SizedBox(height: 5),
                Text(
                  internship.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.cardTitle,
                ),
                const SizedBox(height: 3),
                Text(
                  'Remote · ${internship.durationLabel} · Certificate',
                  style: AppText.small,
                ),
                const SizedBox(height: 4),
                Text(
                  internship.priceLabel,
                  style: AppText.price.copyWith(
                    fontSize: 14,
                    color: internship.isFree || internship.isStipend
                        ? AppColors.success
                        : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Chhota rangeen tag: PAID / FREE / STIPEND / PROJECT
class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final String type; // paid / free / stipend / project

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (type) {
      case 'free':
        bg = AppColors.freeBg;
        fg = AppColors.freeText;
        break;
      case 'stipend':
        bg = AppColors.stipendBg;
        fg = AppColors.stipendText;
        break;
      case 'project':
        bg = AppColors.projectBg;
        fg = AppColors.projectText;
        break;
      default:
        bg = AppColors.paidBg;
        fg = AppColors.paidText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        '${Internship.typeLabelFor(type)} INTERNSHIP',
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: fg),
      ),
    );
  }
}
