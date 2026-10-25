// ============================================================
//  OTP SCREEN — 4-digit OTP verify
//
//  Demo me OTP hamesha AppConfig.demoOtp (1234) hai.
//  Backend lagne ke baad asli SMS wala OTP chalega.
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../state/app_state.dart';
import 'main_shell.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  static const int _resendSeconds = 30;

  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _verifying = false;
  String? _error;

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes.first.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft <= 1) {
          _secondsLeft = 0;
          timer.cancel();
        } else {
          _secondsLeft--;
        }
      });
    });
  }

  Future<void> _resend() async {
    await context.read<AppState>().repository.sendOtp(widget.phone);
    if (!mounted) return;
    setState(_startTimer);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP dobara bhej diya gaya')),
    );
  }

  void _clearBoxes() {
    for (final TextEditingController c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _verify() async {
    if (_verifying || _otp.length != _otpLength) return;
    setState(() {
      _verifying = true;
      _error = null;
    });

    final AppState state = context.read<AppState>();
    final bool ok = await state.repository.verifyOtp(widget.phone, _otp);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _verifying = false;
        _error = AppConfig.useMockData
            ? 'Galat OTP. Demo ke liye ${AppConfig.demoOtp} daalein.'
            : 'Galat OTP. Dobara try karein.';
      });
      _clearBoxes();
      return;
    }

    await state.loginWithPhone(widget.phone);
    if (!mounted) return;

    // Profile pehle se bani hai → seedha app, warna profile setup
    final Widget next = state.isLoggedIn ? const MainShell() : const ProfileSetupScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => next),
      (route) => false,
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _error = null);
    if (_otp.length == _otpLength) _verify(); // 4 digit poore → apne aap verify
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Check your messages', style: AppText.h1),
              const SizedBox(height: 6),
              Text('OTP bheja gaya: +91 ${widget.phone}', style: AppText.muted),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_otpLength, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 56,
                      height: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        expands: true,
                        maxLines: null,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend OTP in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: AppText.muted,
                      )
                    : TextButton(onPressed: _resend, child: const Text('Resend OTP')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _otp.length == _otpLength && !_verifying ? _verify : null,
                child: _verifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify & Continue'),
              ),
              if (AppConfig.useMockData) ...[
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Demo version · OTP: ${AppConfig.demoOtp}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
