// ============================================================
//  LOGIN SCREEN — Mobile number daalo → OTP
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../state/app_state.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _sending = false;

  String get _phone => _phoneController.text.trim();

  // Indian mobile number: 10 digit, 6/7/8/9 se shuru
  bool get _isValid => RegExp(r'^[6-9][0-9]{9}$').hasMatch(_phone);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _sending = true);
    final bool sent = await context.read<AppState>().repository.sendOtp(_phone);
    if (!mounted) return;
    setState(() => _sending = false);

    if (sent) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => OtpScreen(phone: _phone)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP nahi bhej paye. Dobara try karein.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showError = _phone.length == 10 && !_isValid;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(child: Image.asset('assets/images/logo.jpg', width: 104, height: 104)),
              const SizedBox(height: 32),
              const Text('Enter your mobile number', style: AppText.h1),
              const SizedBox(height: 6),
              const Text(
                'Hum aapke number pe 4-digit OTP bhejenge.',
                style: AppText.muted,
              ),
              const SizedBox(height: 28),
              const Text(
                'Mobile number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 16, letterSpacing: 1),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '98765 43210',
                  errorText: showError ? 'Sahi 10-digit mobile number daalein' : null,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Text(
                      '+91',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isValid && !_sending ? _sendOtp : null,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Get OTP'),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Aage badhne par aap hamari Terms & Privacy Policy se sahmat hain.',
                  textAlign: TextAlign.center,
                  style: AppText.tiny,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
