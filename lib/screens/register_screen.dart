// ============================================================
//  REGISTER SCREEN — Naya account banana
//
//  Flow:  Name + Email + Phone + Password → Register API
//         → OTP Screen (6-digit code on email)
//         → OTP verify → Profile → Main App
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../state/app_state.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _loading    = false;
  bool  _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      await context.read<AppState>().register(
            name:     _nameCtrl.text.trim(),
            email:    _emailCtrl.text.trim().toLowerCase(),
            phone:    _phoneCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (!mounted) return;

      // Go to OTP screen with the registered email
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OtpScreen(email: _emailCtrl.text.trim().toLowerCase()),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString()
            .replaceFirst('ApiException(409): ', '')
            .replaceFirst('ApiException(429): ', '')
            .replaceFirst('ApiException(0): ', '')
            .replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Start your learning journey!', style: AppText.h2),
                const SizedBox(height: 6),
                const Text(
                    'Hum aapke email pe ek verification code bhejenge.',
                    style: AppText.muted),
                const SizedBox(height: 24),

                // ── Full Name ──
                _label('Full name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'Rahul Kumar',
                      prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Naam likhna zaroori hai'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Email ──
                _label('Email address *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded)),
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.isEmpty) {
                      return 'Email daalna zaroori hai';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
                      return 'Sahi email likhein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Phone ──
                _label('Mobile number (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: '98765 43210',
                    counterText: '',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Text('+91',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password ──
                _label('Password *  (min 8 characters)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password likhein';
                    if (v.length < 8) return 'Password kam se kam 8 characters ka ho';
                    return null;
                  },
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Register & Get OTP'),
                ),
                const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
}
