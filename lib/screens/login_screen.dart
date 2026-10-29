// ============================================================
//  LOGIN SCREEN — Email + Password se login
//
//  Flow:
//    • Email + Password → Login API → Dashboard
//    • "Register here" link → Register flow
//    • Forgot password? → will be added later
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../state/app_state.dart';
import 'main_shell.dart';
import 'profile_setup_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;
  bool _obscure     = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      await context.read<AppState>().login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (!mounted) return;

      final state = context.read<AppState>();
      final Widget next =
          state.isLoggedIn ? const MainShell() : const ProfileSetupScreen();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => next),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ApiException(401): ', '')
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Image.asset('assets/images/logo.jpg',
                      width: 100, height: 100),
                ),
                const SizedBox(height: 28),
                const Text('Welcome Back!', style: AppText.h1),
                const SizedBox(height: 6),
                const Text('Login to your Digital Vidyalaya account.',
                    style: AppText.muted),
                const SizedBox(height: 28),

                // Email
                const Text('Email address',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
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

                // Password
                const Text('Password',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: 'Aapka password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password likhein'
                      : null,
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
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),

                // Local dev hint
                if (AppConfig.useMockData) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Demo mode · koi bhi email + koi bhi password',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Go to Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Account nahi hai? ',
                        style: AppText.small),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'Register karein',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
}
