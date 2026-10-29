// ============================================================
//  OTP SCREEN — Email pe aaya 6-digit code verify karo
//
//  Register ke baad yahan aata hai.
//  OTP enter karo → verify → Profile setup → Main app
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
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength     = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
          _otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List<FocusNode>.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int  _secondsLeft = _resendSeconds;
  bool _verifying   = false;
  String? _error;

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNodes.first.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes)   { f.dispose(); }
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
    setState(() { _error = null; });
    try {
      await context.read<AppState>().resendOtp(email: widget.email);
      if (!mounted) return;
      setState(_startTimer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP dobara bhej diya gaya')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend fail: $e')),
      );
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes.first.requestFocus();
  }

  Future<void> _verify() async {
    if (_verifying || _otp.length != _otpLength) return;
    setState(() { _verifying = true; _error = null; });

    final state = context.read<AppState>();

    try {
      await state.verifyOtp(email: widget.email, otp: _otp);
      if (!mounted) return;

      final Widget next =
          state.isLoggedIn ? const MainShell() : const ProfileSetupScreen();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => next),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.toString()
            .replaceFirst('ApiException(400): ', '')
            .replaceFirst('Exception: ', '');
      });
      _clearBoxes();
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _error = null);
    if (_otp.length == _otpLength) _verify();
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
              const Text('Check your inbox', style: AppText.h1),
              const SizedBox(height: 6),
              Text(
                '6-digit code bheja gaya:\n${widget.email}',
                style: AppText.muted,
              ),
              const SizedBox(height: 32),

              // ── 6 OTP boxes ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_otpLength, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 46,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        expands: true,
                        maxLines: null,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) =>
                            _onDigitChanged(index, value),
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
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13),
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
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend OTP'),
                      ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    _otp.length == _otpLength && !_verifying ? _verify : null,
                child: _verifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify & Continue'),
              ),

              if (AppConfig.useMockData) ...[
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Demo mode · OTP: 123456 ya 1234',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Spam folder bhi check karein agar email nahi mila.',
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
