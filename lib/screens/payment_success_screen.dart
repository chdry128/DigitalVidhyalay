// ============================================================
//  PAYMENT SUCCESS — Payment ho gaya, receipt dikhao
//
//  "Start Learning" → Meri Padhai tab khulta hai
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/payment.dart';
import 'main_shell.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.record});

  final PaymentRecord record;

  void _goToLearning(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const MainShell(initialTab: MainShell.learningTab),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Back dabane pe payment screen pe wapas nahi jana
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToLearning(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration:
                      const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 46),
                ),
                const SizedBox(height: 20),
                const Text('Payment successful', style: AppText.h1),
                const SizedBox(height: 8),
                Text(
                  'Aap "${record.title}" me enroll ho gaye hain.',
                  textAlign: TextAlign.center,
                  style: AppText.muted.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _ReceiptRow(label: 'Amount paid', value: '₹${record.amount}'),
                      _ReceiptRow(label: 'Order ID', value: record.orderId),
                      _ReceiptRow(label: 'Payment mode', value: record.method),
                      _ReceiptRow(label: 'Date', value: record.dateLabel),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () => _goToLearning(context),
                  child: Text(record.type == 'course' ? 'Start Learning' : 'Go to Internship'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: AppText.muted),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
