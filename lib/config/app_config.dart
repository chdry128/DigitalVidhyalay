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
  static const String appVersionLabel = 'Version 1.0.0 (Demo)';

  // ---------- Contact details ----------
  static const String supportPhone = '+917505100528'; // Call button isi pe jayega
  static const String supportPhoneLabel = '+91 75051 00528'; // Screen pe yeh dikhega
  static const String whatsappNumber = '917505100528'; // Bina + aur space ke
  static const String supportEmail = 'info@digitalvidyalaya.co.in';
  static const String websiteUrl = 'https://www.digitalvidyalaya.co.in';
  static const String supportTimings = '10 AM – 6 PM';

  // ---------- Courses ke default ----------
  // Agar kisi course me trainer ka naam nahi diya, to yeh naam dikhega
  static const String defaultTrainer = 'Sagar Choudhary';
  static const String defaultTrainerInfo = 'Director, Digital Vidyalaya';

  // ---------- Demo / Backend ----------
  // true  = app assets/data/*.json se data dikhayega (abhi demo ke liye)
  // false = app asli backend (apiBaseUrl) se data layega
  static const bool useMockData = true;

  // Demo me login ka OTP. Backend lagne ke baad asli SMS OTP aayega.
  static const String demoOtp = '1234';

  // ---------- Video ----------
  // Jis lesson me "videoId" nahi diya, usme yeh YouTube video chalega.
  // YouTube link: https://youtu.be/OzIjZAIy6Cc  →  ID = OzIjZAIy6Cc
  // (Video Public ya Unlisted hona chahiye, Private nahi)
  static const String demoVideoId = 'OzIjZAIy6Cc';

  // Demo payment me "Processing..." kitni der dikhe (milliseconds)
  static const int demoPaymentDelayMs = 2000;

  // ---------- Quiz & Certificate ----------
  // Quiz pass karne ke liye kitne % sahi chahiye (5 me se 3 = 60%)
  static const int quizPassPercent = 60;

  // Certificate ke QR code se yeh page khulega (?id=CERTIFICATE_ID ke saath)
  static const String certificateVerifyUrl = 'https://www.digitalvidyalaya.co.in/verify.php';

  // Certificate pe sign karne wale ka naam aur pad
  static const String certificateSignName = 'Sagar Choudhary';
  static const String certificateSignTitle = 'Director, Digital Vidyalaya';

  // Backend ka address — PHP API ready hone ke baad yahan sahi URL daalein
  static const String apiBaseUrl = 'https://www.digitalvidyalaya.co.in/api/v1';
}
