// ============================================================
//  PAYMENT HISTORY — Ab tak ke saare payments (read-only history)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadPaymentReceipts();
      }
    });
  }

  Color _statusColor(PaymentRecord p) {
    if (p.isCaptured) return AppColors.success;
    if (p.isPending) return const Color(0xFFD97706); // Amber
    if (p.isFailed) return AppColors.error;
    return AppColors.textMuted;
  }

  Color _statusBgColor(PaymentRecord p) {
    if (p.isCaptured) return AppColors.successLight;
    if (p.isPending) return const Color(0xFFFEF3C7);
    if (p.isFailed) return const Color(0xFFFEE2E2);
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<PaymentRecord> payments = state.payments;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Receipts')),
      body: Builder(
        builder: (context) {
          if (state.isLoadingPayments && payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.paymentsError != null && payments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Payment history load nahi ho payi', style: AppText.title),
                    const SizedBox(height: 8),
                    Text(
                      state.paymentsError!,
                      textAlign: TextAlign.center,
                      style: AppText.small,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AppState>().loadPaymentReceipts(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Dobara koshish karein'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (payments.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<AppState>().loadPaymentReceipts(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Abhi koi payment nahi',
                    message: 'Course ya internship khareedne par payment receipt yahan dikhegi.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AppState>().loadPaymentReceipts(forceRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
              itemBuilder: (context, index) {
                final PaymentRecord p = payments[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                          Text('₹${p.amount}', style: AppText.price),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order: ${p.orderId}', style: AppText.tiny),
                              if (p.paymentIdRef != null && p.paymentIdRef!.isNotEmpty)
                                Text('Payment ID: ${p.paymentIdRef}', style: AppText.tiny),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusBgColor(p),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.statusLabel,
                              style: TextStyle(
                                color: _statusColor(p),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (p.receiptUrl != null && p.receiptUrl!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => openLink(context, p.receiptUrl!),
                            icon: const Icon(Icons.receipt_outlined, size: 16),
                            label: const Text('View Web Receipt', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
