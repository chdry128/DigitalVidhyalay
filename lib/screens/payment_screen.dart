// ============================================================
//  PAYMENT SCREEN — Order summary + payment method + Pay
//
//  ⚠ DEMO: Abhi asli paisa nahi katta. "Pay" dabane pe 2 second
//  ruk kar seedha success. Backend ke time yahan Razorpay lagega
//  (sirf _pay() function badalna hoga).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.item});

  final PurchaseItem item;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Payment ke tareeke — naya tareeka jodna ho to ek line copy karo
  static const List<_PayMethod> _methods = [
    _PayMethod('UPI', 'GPay · PhonePe · Paytm · BHIM', Icons.qr_code_2_rounded),
    _PayMethod('Card', 'Debit ya Credit card', Icons.credit_card_rounded),
    _PayMethod('Net Banking', 'Sabhi bade Indian banks', Icons.account_balance_outlined),
  ];

  final TextEditingController _coupon = TextEditingController();
  String _method = 'UPI';
  String? _couponMessage;
  bool _processing = false;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    // Demo: koi coupon valid nahi. Backend me server check karega.
    setState(() {
      _couponMessage = _coupon.text.trim().isEmpty ? 'Coupon code likhein' : 'Yeh coupon valid nahi hai';
    });
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    final AppState state = context.read<AppState>();

    // DEMO: thoda ruko (jaise payment ho raha ho)
    await Future<void>.delayed(const Duration(milliseconds: AppConfig.demoPaymentDelayMs));
    final PaymentRecord record = await state.completePurchase(widget.item, _method);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => PaymentSuccessScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PurchaseItem item = widget.item;

    return PopScope(
      canPop: !_processing, // Payment chalte waqt back band
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('Complete Payment')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (AppConfig.useMockData) const _DemoNotice(),

                // ---------- Order summary ----------
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORDER SUMMARY', style: AppText.tiny),
                      const SizedBox(height: 8),
                      Text(item.title, style: AppText.title),
                      const SizedBox(height: 2),
                      Text(item.isCourse ? 'Online course' : 'Internship program', style: AppText.small),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Text(item.isCourse ? 'Course fee' : 'Internship fee', style: AppText.body),
                          const Spacer(),
                          Text('₹${item.amount}', style: AppText.price),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Coupon
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _coupon,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Coupon code',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(80, 46)),
                            onPressed: _applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_couponMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _couponMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          const Text('Total', style: AppText.title),
                          const Spacer(),
                          Text('₹${item.amount}', style: AppText.price.copyWith(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------- Payment method ----------
                const SizedBox(height: 22),
                const Text('Payment method chunein', style: AppText.title),
                const SizedBox(height: 10),
                for (final _PayMethod m in _methods)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MethodTile(
                      name: m.name,
                      hint: m.hint,
                      icon: m.icon,
                      selected: _method == m.name,
                      onTap: () => setState(() => _method = m.name),
                    ),
                  ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      '100% secure payment',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: ElevatedButton(
                    onPressed: _processing ? null : _pay,
                    child: Text('Pay ₹${item.amount}'),
                  ),
                ),
              ),
            ),
          ),

          // ---------- "Processing..." parda ----------
          if (_processing) const _ProcessingOverlay(),
        ],
      ),
    );
  }
}

class _PayMethod {
  const _PayMethod(this.name, this.hint, this.icon);

  final String name;
  final String hint;
  final IconData icon;
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF92400E)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'DEMO payment — koi paisa nahi katega.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.name,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.cardTitle),
                    Text(hint, style: AppText.small),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primary : AppColors.disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Material(
        color: Color(0xE6FFFFFF),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(strokeWidth: 4, color: AppColors.primary),
              ),
              SizedBox(height: 24),
              Text('Payment ho raha hai...', style: AppText.h2),
              SizedBox(height: 6),
              Text('Kripya app band na karein', style: AppText.muted),
            ],
          ),
        ),
      ),
    );
  }
}
