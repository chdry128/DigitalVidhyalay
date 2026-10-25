// ============================================================
//  PAYMENT HISTORY — Ab tak ke saare payments (naya sabse upar)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PaymentRecord> payments = context.watch<AppState>().payments;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: payments.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Abhi koi payment nahi',
                message: 'Course ya internship khareedne par receipt yahan dikhegi.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
              itemBuilder: (context, index) {
                final PaymentRecord p = payments[index];
                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          p.type == 'course' ? Icons.menu_book_outlined : Icons.work_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: AppText.cardTitle),
                            const SizedBox(height: 2),
                            Text('${p.dateLabel} · ${p.method}', style: AppText.small),
                            Text('Order ID: ${p.orderId}', style: AppText.tiny),
                          ],
                        ),
                      ),
                      Text('₹${p.amount}', style: AppText.price),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
