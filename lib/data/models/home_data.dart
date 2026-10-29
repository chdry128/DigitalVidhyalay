// ============================================================
//  HOME DATA MODEL — home.json ka data (mock) + API ka data (backend)
//  (Banners, onboarding slides, stats, counselling message)
// ============================================================

class HomeData {
  final List<OfferBanner> banners;
  final List<OnboardingSlide> onboarding;
  final List<StatItem> stats;
  final String counsellingMessage;
  final List<AppNotification> notifications;

  const HomeData({
    required this.banners,
    required this.onboarding,
    required this.stats,
    required this.counsellingMessage,
    this.notifications = const [],
  });

  // ── Mock JSON (assets/data/home.json) ──────────────────────
  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<dynamic> list(String key) =>
        (json[key] as List<dynamic>?) ?? <dynamic>[];
    return HomeData(
      banners: list('banners')
          .map((b) => OfferBanner.fromJson(b as Map<String, dynamic>))
          .toList(),
      onboarding: list('onboarding')
          .map((o) => OnboardingSlide.fromJson(o as Map<String, dynamic>))
          .toList(),
      stats: list('stats')
          .map((s) => StatItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      counsellingMessage:
          (json['counsellingMessage'] as String?) ?? '',
      notifications: list('notifications')
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Real API (catalog/home.php response data object) ───────
  factory HomeData.fromApiJson(Map<String, dynamic> json) {
    // PHP returns: banners[], featured_courses[], stipend_internships[],
    //              regular_internships[], announcements[]

    final rawBanners =
        (json['banners'] as List<dynamic>?) ?? <dynamic>[];
    final banners = rawBanners
        .map((b) => OfferBanner.fromApiJson(b as Map<String, dynamic>))
        .toList();

    final rawAnnouncements =
        (json['announcements'] as List<dynamic>?) ?? <dynamic>[];
    final notifications = rawAnnouncements
        .map((a) => AppNotification.fromApiJson(a as Map<String, dynamic>))
        .toList();

    return HomeData(
      banners: banners,
      onboarding: const [],        // Onboarding slides stay in local asset
      stats: _defaultStats(),
      counsellingMessage:
          'Hello Digital Vidyalaya, mujhe free counselling chahiye. Please help.',
      notifications: notifications,
    );
  }

  static List<StatItem> _defaultStats() => const [
        StatItem(value: '5,000+', label: 'Students Enrolled'),
        StatItem(value: '50+', label: 'Online Courses'),
        StatItem(value: '48', label: 'Internship Programs'),
        StatItem(value: '95%', label: 'Placement Rate'),
      ];

  static const HomeData empty =
      HomeData(banners: [], onboarding: [], stats: [], counsellingMessage: '');
}

// ─────────────────────────────────────────────────────────────
//  OFFER BANNER
// ─────────────────────────────────────────────────────────────
class OfferBanner {
  final String tag;
  final String title;
  final String subtitle;
  final String button;
  final String action; // courses / internships / counselling / stipend_internships

  const OfferBanner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.action,
  });

  // Mock JSON
  factory OfferBanner.fromJson(Map<String, dynamic> json) => OfferBanner(
        tag: (json['tag'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        button: (json['button'] as String?) ?? 'Explore',
        action: (json['action'] as String?) ?? 'courses',
      );

  // API JSON (catalog/home.php banners array)
  factory OfferBanner.fromApiJson(Map<String, dynamic> json) => OfferBanner(
        tag: (json['badge'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        button: 'Explore',
        action: (json['action_type'] as String?) ?? 'courses',
      );
}

// ─────────────────────────────────────────────────────────────
//  ONBOARDING SLIDE
// ─────────────────────────────────────────────────────────────
class OnboardingSlide {
  final String title;
  final String text;
  final String image;

  const OnboardingSlide(
      {required this.title, required this.text, required this.image});

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) =>
      OnboardingSlide(
        title: (json['title'] as String?) ?? '',
        text: (json['text'] as String?) ?? '',
        image: (json['image'] as String?) ?? '',
      );
}

// ─────────────────────────────────────────────────────────────
//  NOTIFICATION
// ─────────────────────────────────────────────────────────────
class AppNotification {
  final String title;
  final String body;
  final String time;
  final String icon; // course / offer / quiz / certificate / internship

  const AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        time: (json['time'] as String?) ?? '',
        icon: (json['icon'] as String?) ?? 'course',
      );

  // API: email_logs announcement
  factory AppNotification.fromApiJson(Map<String, dynamic> json) =>
      AppNotification(
        title: (json['subject'] as String?) ?? 'Announcement',
        body: (json['preview'] as String?) ?? '',
        time: (json['sent_at'] as String?) ?? '',
        icon: 'offer',
      );
}

// ─────────────────────────────────────────────────────────────
//  STAT ITEM
// ─────────────────────────────────────────────────────────────
class StatItem {
  final String value;
  final String label;

  const StatItem({required this.value, required this.label});

  factory StatItem.fromJson(Map<String, dynamic> json) => StatItem(
        value: (json['value'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
      );
}
