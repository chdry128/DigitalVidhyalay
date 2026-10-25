// ============================================================
//  EMPTY STATE — Jab dikhane ko kuch na ho (khaali list)
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel; // null = button mat dikhao
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(icon, size: 42, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.h2, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppText.muted, textAlign: TextAlign.center),
          if (buttonLabel != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel!)),
          ],
        ],
      ),
    );
  }
}
