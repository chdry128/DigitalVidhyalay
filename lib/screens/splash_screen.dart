// ============================================================
//  SPLASH SCREEN — App khulte hi logo (1.5 second)
//
//  Isi time me data load hota hai, phir decide hota hai:
//   • Pehle se login hai     → Main app
//   • Onboarding dekh liya   → Login
//   • Pehli baar             → Onboarding
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../state/app_state.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Logo kitni der dikhe (milliseconds)
  static const int _splashDurationMs = 1500;

  @override
  void initState() {
    super.initState();
    // Pehla frame banne ke baad loading shuru karte hain
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final AppState state = context.read<AppState>();
    await Future.wait<void>([
      state.init(),
      Future<void>.delayed(const Duration(milliseconds: _splashDurationMs)),
    ]);
    if (!mounted) return;

    final Widget next;
    if (state.isLoggedIn) {
      next = const MainShell();
    } else if (state.onboardingSeen) {
      next = const LoginScreen();
    } else {
      next = const OnboardingScreen();
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.jpg', width: 170, height: 170),
            const SizedBox(height: 18),
            const Text(
              AppConfig.tagline,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
