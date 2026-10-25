// ============================================================
//  ONBOARDING — Pehli baar app kholne pe 3 slides
//
//  Slides ka text aur photo badalna ho to:
//  assets/data/home.json → "onboarding"
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/home_data.dart';
import '../state/app_state.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppState>().markOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _next(int total) {
    if (_page < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingSlide> slides = context.watch<AppState>().home.onboarding;

    // Agar slides load na hon to seedha "Get started"
    if (slides.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Image.asset('assets/images/logo.jpg', width: 160),
                const Spacer(),
                ElevatedButton(onPressed: _finish, child: const Text('Shuru karein')),
              ],
            ),
          ),
        ),
      );
    }

    final bool isLast = _page == slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _SlideView(slide: slides[index]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(slides.length, (index) {
                final bool active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.disabled,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            // Skip / Next buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
              child: Row(
                children: [
                  TextButton(onPressed: _finish, child: const Text('Skip')),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(132, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () => _next(slides.length),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLast ? 'Shuru karein' : 'Next'),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: SizedBox(
            width: double.infinity,
            child: Image.network(
              slide.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.school_outlined, size: 90, color: AppColors.primary),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DIGITAL VIDYALAYA',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(slide.title, style: AppText.h1.copyWith(fontSize: 26)),
                const SizedBox(height: 8),
                Text(slide.text, style: AppText.muted.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
