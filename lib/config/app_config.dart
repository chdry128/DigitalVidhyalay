// ============================================================
//  APP CONFIG — App ki basic settings
//
//  Kya badal sakte ho (sirf yahi file kholni hai):
//   • App ka naam / tagline
//   • Support phone, WhatsApp number, email, website
//   • Demo mode (mock data) ON/OFF
//   • Backend (API) ka address
// ============================================================

class AppConfig {
  AppConfig._(); // Is class ka object nahi banta, sirf values use hoti hain

  // ---------- App ki pehchaan ----------
  static const String appName = 'Digital Vidyalaya';
  static const String tagline = 'Learn. Grow. Succeed.';
  static const String companyName = 'Digital Vidyalaya Technologies Pvt. Ltd.';
  static const String appVersionLabel = 'Version 1.0.0 (Beta)';

  // ---------- Contact details ----------
  static const String supportPhone = '+917505100528';
  static const String supportPhoneLabel = '+91 75051 00528';
  static const String whatsappNumber = '917505100528';
  static const String supportEmail = 'info@digitalvidyalaya.co.in';
  static const String websiteUrl = 'https://www.digitalvidyalaya.co.in';
  static const String supportTimings = '10 AM – 6 PM';

  // ---------- Courses ke default ----------
  static const String defaultTrainer = 'Sagar Choudhary';
  static const String defaultTrainerInfo = 'Director, Digital Vidyalaya';

  // ============================================================
  //  MOCK vs REAL BACKEND
  //  true  = assets/data/*.json se demo data (no server needed)
  //  false = PHP server se asli data (local XAMPP / production)
  // ============================================================
  static const bool useMockData = false;

  // Demo OTP (sirf useMockData = true me kaam karta hai)
  static const String demoOtp = '1234';

  // ---------- Video ----------
  static const String demoVideoId = 'OzIjZAIy6Cc';
  static const int demoPaymentDelayMs = 2000;

  // ---------- Quiz & Certificate ----------
  static const int quizPassPercent = 60;
  static const String certificateVerifyUrl =
      'https://www.digitalvidyalaya.co.in/verify.php';
  static const String certificateSignName = 'Sagar Choudhary';
  static const String certificateSignTitle = 'Director, Digital Vidyalaya';

  // ============================================================
  //  LOCAL API BASE URL
  //
  //  Kaunsa uncomment karna hai:
  //
  //  [A] Android EMULATOR (AVD):
  //        10.0.2.2 = emulator ke andar PC ka loopback address
  //        → _apiBaseUrlAndroidEmulator uncomment karo
  //
  //  [B] ASLI ANDROID / iOS PHONE (same Wi-Fi pe):
  //        Aapke PC ki IP = 40.40.24.210
  //        → _apiBaseUrlPhysicalDevice uncomment karo
  //
  //  [C] iOS Simulator ya Windows Flutter Desktop:
  //        → _apiBaseUrlLocalhost uncomment karo
  //
  //  [D] PRODUCTION (baad mein live server pe deploy karne ke baad):
  //        → _apiBaseUrlProduction uncomment karo
  // ============================================================

  // [A] Android Emulator
  // ignore: unused_field
  //static const String _apiBaseUrlAndroidEmulator =
   //   'http://10.0.2.2:8000/mobile-api';

  // [B] Physical Device (use the PC's Wi-Fi IPv4 address, not 127.0.0.1)
 // static const String _apiBaseUrlPhysicalDevice =
     // 'http://172.29.209.183:8000/mobile-api';

  // [C] iOS Simulator / Windows Desktop / ADB reverse
  // ignore: unused_field
  //static const String _apiBaseUrlLocalhost =
      //'http://127.0.0.1:8000/mobile-api';

  // [D] Production server
  // ignore: unused_field
  static const String _apiBaseUrlProduction =
     'https://www.digitalvidyalaya.co.in/mobile-api';

  // ↓↓ SIRF EK LINE UNCOMMENT RAKHEIN ↓↓
  //static const String apiBaseUrl = _apiBaseUrlPhysicalDevice;
  // static const String apiBaseUrl = _apiBaseUrlAndroidEmulator;
  // static const String apiBaseUrl = _apiBaseUrlLocalhost;
   static const String apiBaseUrl = _apiBaseUrlProduction;
}
