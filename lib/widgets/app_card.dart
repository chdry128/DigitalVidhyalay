// ============================================================
//  APP CARD — White box with border (poori app me cards isi se bante hain)
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.surface,
  });

  final Widget child;
  final VoidCallback? onTap; // null = card dabane pe kuch nahi hoga
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusCard);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
