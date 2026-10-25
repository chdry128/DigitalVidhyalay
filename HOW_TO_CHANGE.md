# Digital Vidyalaya App — Kya badalna hai, kahan badlein

Yeh guide sir aur team ke liye hai. App ka zyaadatar content **code chhue bina** badla ja sakta hai.

> **Golden rule:** Kuch bhi badlo, phir `flutter run` chala kar check karo.
> JSON file badli hai to app me **Hot Restart** (terminal me capital `R`) dabana zaroori hai — sirf hot reload (`r`) se JSON update nahi hota.

---

## 1. Sabse common kaam (code nahi, sirf data)

| Kya badalna hai | Kaunsi file | Kya karna hai |
|---|---|---|
| Naya course jodna / hatana | `assets/data/courses.json` | Ek `{ ... }` block copy karke niche paste karo, values badlo. `id` naya rakho |
| Course ka price / naam / photo | `assets/data/courses.json` | Us course ke `price`, `title`, `image` badlo |
| Course ka syllabus | `assets/data/courses.json` | `modules` list me module jodo. `lessons` me lesson ke naam |
| Course ki category | `assets/data/courses.json` | `category` badlo. Nayi category apne aap filter aur Home pe aa jayegi |
| Lesson ka video | `assets/data/courses.json` | Lesson me `"videoId": "OzIjZAIy6Cc"` likho (YouTube link ka aakhri hissa) |
| Sab jagah chalne wala demo video | `lib/config/app_config.dart` | `demoVideoId` |
| Rating / students hatana | `assets/data/courses.json` | `"rating": 0` aur `"students": 0` kar do — screen pe nahi dikhega |
| Naya internship | `assets/data/internships.json` | Block copy karo. `type` = `paid` / `free` / `stipend` / `project` |
| Internship ke "What you will experience" points | `assets/data/internships.json` | `whatYouGet` list |
| Home ke offer banners | `assets/data/home.json` | `banners` list. `action` = `courses` / `internships` / `counselling` |
| Onboarding (pehli 3 slides) | `assets/data/home.json` | `onboarding` list |
| Home ke neeche stats (5,000+ students) | `assets/data/home.json` | `stats` list |
| Notifications (ghanti wali screen) | `assets/data/home.json` | `notifications` list |
| Quiz ke sawaal | `assets/data/quizzes.json` | Course ke `id` ke neeche sawaal. `answer` = sahi option ka number, **0 se shuru** (A=0, B=1, C=2, D=3) |
| Counselling ka WhatsApp message | `assets/data/home.json` | `counsellingMessage` |

### Lesson me video kaise lagayein
YouTube link `https://youtu.be/OzIjZAIy6Cc` → video ID = `OzIjZAIy6Cc`

```json
"lessons": [
  { "title": "What is Java", "videoId": "OzIjZAIy6Cc", "duration": "9:20" },
  { "title": "Installing JDK", "videoId": "XXXXXXXXXXX", "duration": "10:15" }
]
```
- Video **Public** ya **Unlisted** ho (Private nahi chalega), aur YouTube Studio me "Allow embedding" ON ho.
- Har course ka **pehla lesson FREE preview** hota hai.
- Kisi module me lessons nahi likhe? To module khud ek lesson ban jata hai (demo video ke saath).
- YouTube video ke liye **koi API key nahi** chahiye.

### JSON likhte waqt dhyan rakhein
- Har text `"double quotes"` me ho.
- Do items ke beech **comma** `,` ho, lekin **last item ke baad comma nahi**.
- Number bina quotes ke: `"price": 9` (sahi), `"price": "9"` (galat).
- Shak ho to file ko https://jsonlint.com pe paste karke check kar lo.

---

## 2. App ki settings (ek line ka badlaav)

File: `lib/config/app_config.dart`

| Kya | Variable |
|---|---|
| Support phone number | `supportPhone`, `supportPhoneLabel` |
| WhatsApp number | `whatsappNumber` (bina `+` aur space, e.g. `917505100528`) |
| Email | `supportEmail` |
| Website | `websiteUrl` |
| Default trainer ka naam | `defaultTrainer`, `defaultTrainerInfo` |
| Demo OTP | `demoOtp` |
| Demo video | `demoVideoId` |
| Demo payment me kitni der "Processing" | `demoPaymentDelayMs` |
| Quiz pass karne ke liye kitne % | `quizPassPercent` (abhi 60) |
| Certificate pe sign ka naam / pad | `certificateSignName`, `certificateSignTitle` |
| Certificate ke QR se kaunsa page khule | `certificateVerifyUrl` |
| Demo data ya asli backend | `useMockData` (`true` = demo, `false` = backend) |
| Backend ka address | `apiBaseUrl` |

---

## 3. Design (rang, font, size)

| Kya | File | Kahan |
|---|---|---|
| Orange / navy / background rang | `lib/config/app_colors.dart` | `primary`, `navy`, `background` ... |
| Font | `lib/config/app_theme.dart` | `GoogleFonts.plusJakartaSans()` ko badlo, e.g. `GoogleFonts.poppins()` |
| Text ka size | `lib/config/app_theme.dart` | `AppText` class (h1, title, body ...) |
| Button ka shape / height | `lib/config/app_theme.dart` | `elevatedButtonTheme` |
| Cards ka gol kona | `lib/config/app_theme.dart` | `AppSizes.radiusCard` |
| Category ke icons | `lib/config/category_icons.dart` | Category ka naam + icon |
| Certificate ka design (app me) | `lib/widgets/certificate_view.dart` | |
| Certificate ka design (PDF) | `lib/utils/certificate_pdf.dart` | Dono me text same rakhein |
| App ka logo | `assets/images/logo.jpg` | Same naam se nayi file daal do |
| Phone pe app ka icon | `assets/icon/` | Nayi images daalo, phir `dart run flutter_launcher_icons` |

Rang ka format: `#EA580C` → `Color(0xFFEA580C)` (aage `0xFF` lagana hai).

---

## 4. Screens (thoda code)

Har screen ki apni file hai — `lib/screens/` me. Har file ke upar likha hai ki woh screen kya karti hai.

| Screen | File |
|---|---|
| Logo wali pehli screen | `splash_screen.dart` |
| 3 intro slides | `onboarding_screen.dart` |
| Mobile number | `login_screen.dart` |
| OTP | `otp_screen.dart` |
| Naam / college form | `profile_setup_screen.dart` |
| Neeche ke 5 tabs | `main_shell.dart` |
| Home | `home_screen.dart` |
| Courses list | `courses_screen.dart` |
| Ek course ki detail | `course_detail_screen.dart` |
| Internships list | `internships_screen.dart` |
| Ek internship ki detail | `internship_detail_screen.dart` |
| Search | `search_screen.dart` |
| Payment (demo) | `payment_screen.dart` |
| Payment ho gaya | `payment_success_screen.dart` |
| Video player + lessons list | `lesson_player_screen.dart` |
| Meri Padhai (Courses / Internships tabs) | `meri_padhai_screen.dart` |
| Internship ke weekly tasks | `internship_progress_screen.dart` (week ke naam `_weekPlan` me) |
| Stipend internship ka form | `stipend_apply_screen.dart` |
| Payment History | `payment_history_screen.dart` |
| Quiz + result | `quiz_screen.dart` |
| Certificate dekhna / PDF / share | `certificate_screen.dart` |
| Saare certificates | `my_certificates_screen.dart` |
| Certificate verify | `verify_certificate_screen.dart` |
| Notifications | `notifications_screen.dart` |
| Profile | `profile_screen.dart` |

Bar-bar use hone wale chhote parts (card, button, chip) `lib/widgets/` me hain. Ek widget badlo to woh har jagah badal jata hai.

---

## 5. Folder ka naksha

```
assets/
  data/        ← courses.json, internships.json, home.json  (CONTENT)
  images/      ← logo.jpg
  icon/        ← phone ka app icon
lib/
  config/      ← rang, font, settings                       (DESIGN + SETTINGS)
  data/
    models/    ← Course, Internship ... ka structure
    repository/← data kahan se aayega (demo JSON / backend)
  state/       ← app_state.dart (login, data load)
  screens/     ← har screen ki file
  widgets/     ← card, chip, button jaise chhote parts
  utils/       ← call / WhatsApp kholna, number format
  main.dart    ← app yahan se shuru hoti hai
```

---

## 6. Backend lagana (baad me)

1. Server pe PHP API banegi jo **wahi JSON** bhejegi jo `assets/data/` ki files me hai.
2. `lib/data/repository/api_repository.dart` me har function me API call likhni hai (wahan TODO likha hai).
3. `lib/config/app_config.dart` me `useMockData = false`.

Screens me kuch nahi badalna padega.

---

## 7. Kuch gadbad ho jaye to

- `flutter analyze` — code ki galtiyan dikhata hai (line number ke saath).
- `flutter clean` phir `flutter pub get` — ajeeb build errors ke liye.
- JSON galat hone pe app "Kuch gadbad ho gayi" dikhayegi — JSON file jsonlint.com pe check karo.
