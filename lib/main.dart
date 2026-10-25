// ============================================================
//  MAIN — App yahan se shuru hoti hai
//
//  Flow:  Splash → Onboarding (pehli baar) → Login → OTP
//         → Profile setup → Main app (5 tabs)
//
//  Screens ki files:  lib/screens/
//  Rang / font:       lib/config/
//  Courses ka data:   assets/data/
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'data/repository/api_repository.dart';
import 'data/repository/app_repository.dart';
import 'data/repository/mock_repository.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Data kahan se aayega: demo JSON ya asli backend (app_config.dart me badlein)
  final AppRepository repository =
      AppConfig.useMockData ? MockRepository() : ApiRepository();

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(repository),
      child: const DigitalVidyalayaApp(),
    ),
  );
}

class DigitalVidyalayaApp extends StatelessWidget {
  const DigitalVidyalayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Phone me bahut bada font set ho to bhi design na toote
      builder: (context, child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
