// ============================================================
//  COMING SOON — Demo me jo feature abhi bana nahi, uske liye popup
//
//  Jab woh feature ban jaye, us button ke onPressed me
//  showComingSoon(...) hata kar asli screen khol dena.
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';

Future<void> showComingSoon(BuildContext context, {required String feature}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration:
                  const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.rocket_launch_outlined, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(feature, style: AppText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text(
              'Yeh feature agle update me aa raha hai. Abhi aap app ka design aur flow dekh sakte hain.',
              style: AppText.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Theek hai'),
            ),
          ],
        ),
      ),
    ),
  );
}
