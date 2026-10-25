# Digital Vidyalaya — Student App (Flutter)

Demo version (Phase 1). Data `assets/data/*.json` se aata hai, backend baad me judega.
Kya kahan badalna hai → **HOW_TO_CHANGE.md** dekhein.

## Phase 1 me kya hai
- Splash, Onboarding (3 slides), Mobile + OTP login (demo OTP `1234`), Profile setup
- Home: banners, categories, popular courses, internships, free counselling (WhatsApp), stats
- Courses: 14 asli LMS courses, category filter, detail (About / Syllabus / Reviews)
- Internships: website ke 48 programs, Paid / Free / Stipend / Project tabs + domain filter, detail
- Search (courses + internships), Profile (edit, help, website, about, logout)

## Phase 2 me kya juda
- **Enroll → Payment (DEMO, paisa nahi katta) → Success** — courses aur paid/project internships
- Free internship: seedha enroll. Stipend internship: application form
- **Video player** (YouTube, fullscreen) — lessons list, "Mark as done", "Next lesson", progress
- Course detail: **Free preview** (pehla lesson), enroll ke baad "Continue Learning"
- **Meri Padhai**: Courses aur Internships alag tabs, progress bar, Resume (jahan chhoda tha)
- Internship ke **weekly tasks** (checkbox se progress)
- Home pe **Continue Learning** card, Profile me **Payment History**
- Sab progress phone me save hota hai (app band karke kholo, sab wahi milega). Logout pe saaf.

## Phase 3 me kya juda
- **Quiz**: har course ke 5 sawaal (`assets/data/quizzes.json`), saare lessons poore hone par unlock
- Result: score ring (pass = hara, fail = laal), har sawaal ka review, Retry
- **Certificate**: pass hone par banta hai — app me design + **PDF download / share** (A4, logo + QR code)
- Internship ke saare weeks poore → internship certificate
- **My Certificates** (Profile + Meri Padhai ka teesra tab), **Verify Certificate** (ID se)
- **Notifications** screen (Home ki ghanti)
- Video player me backup button: *"YouTube app me dekhein"*
- Video Error 152 fix: player me `origin` set kiya

## Pehli baar setup (aapke laptop pe)

Flutter 3.24 ya naya chahiye (`flutter --version`).

```bash
cd digital_vidyalaya

# 1. Android folder banao (aapki banayi files nahi badlengi)
flutter create --org com.digitalvidyalaya --project-name digital_vidyalaya --platforms android .

# 2. Packages
flutter pub get

# 3. Logo se app icon
dart run flutter_launcher_icons

# 4. Code check — koi error aaye to mujhe bhejo
flutter analyze
flutter test

# 5. Phone (USB debugging ON) ya emulator pe chalao
flutter run
```

### Step 1 ke baad: AndroidManifest me 3 cheezein (zaroori)

File: `android/app/src/main/AndroidManifest.xml`

**a) Internet permission** — iske bina release APK me photos aur font load nahi honge.
`<manifest ...>` ke turant neeche, `<application` se pehle:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**b) App ka naam** — `<application` me `android:label="digital_vidyalaya"` ko badlo:

```xml
android:label="Digital Vidyalaya"
```

**c) Call / WhatsApp / Email kholne ke liye** — file me pehle se `<queries>` block hoga, uske andar yeh jodo:

```xml
<intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
</intent>
<intent>
    <action android:name="android.intent.action.DIAL" />
    <data android:scheme="tel" />
</intent>
<intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
</intent>
```

### (Optional) Package name chhota karna
`android/app/build.gradle.kts` me `applicationId = "com.digitalvidyalaya.digital_vidyalaya"`
ko `"com.digitalvidyalaya.app"` kar sakte ho. **Play Store pe daalne ke baad yeh kabhi nahi badalta** — sir se final karke hi rakhna.

## Sir ke phone ke liye APK

```bash
flutter build apk --release --split-per-abi
```

File: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
WhatsApp / Drive se bhejo → sir ke phone pe "Install unknown apps" allow → Install
(Play Protect warning aaye to "Install anyway").

Demo APK aapke laptop ki debug key se sign hota hai — isliye **har update isi laptop se banana**, tab sir ke phone me purane app ke upar install hoga. Play Store ke liye alag keystore banayenge.

## Phase 1 se update kar rahe ho?
Purane folder pe naya zip copy karo (android/ folder mat hatao), phir:
```bash
flutter pub get      # naye packages: youtube_player_iframe, qr_flutter, pdf, printing
flutter analyze
flutter run
```

## Aage
- PHP backend (`lib/data/repository/api_repository.dart`) — asli login OTP, Razorpay payment, server pe certificates
- Push notifications (Firebase Cloud Messaging)
