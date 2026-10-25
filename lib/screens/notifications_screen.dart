// ============================================================
//  NOTIFICATIONS — Offers, naye courses, reminders
//
//  Abhi: assets/data/home.json → "notifications"
//  Baad me: Firebase Cloud Messaging (push notification)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/home_data.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Notification ke "icon" ka naam → asli icon
  static IconData _iconFor(String name) {
    switch (name) {
      case 'offer':
        return Icons.local_offer_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'certificate':
        return Icons.workspace_premium_outlined;
      case 'internship':
        return Icons.work_outline_rounded;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<AppNotification> list = context.watch<AppState>().home.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: list.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Koi notification nahi',
                message: 'Naye offers aur courses ki khabar yahan milegi.',
              ),
            )
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final AppNotification n = list[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_iconFor(n.icon), color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: AppText.cardTitle),
                            const SizedBox(height: 2),
                            Text(n.body, style: AppText.small),
                            const SizedBox(height: 4),
                            Text(n.time, style: AppText.tiny),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
