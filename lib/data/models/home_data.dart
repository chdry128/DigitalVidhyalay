// ============================================================
//  HOME DATA MODEL — home.json ka data
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

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<dynamic> list(String key) => (json[key] as List<dynamic>?) ?? <dynamic>[];
    return HomeData(
      banners: list('banners')
          .map((b) => OfferBanner.fromJson(b as Map<String, dynamic>))
          .toList(),
      onboarding: list('onboarding')
          .map((o) => OnboardingSlide.fromJson(o as Map<String, dynamic>))
          .toList(),
      stats: list('stats').map((s) => StatItem.fromJson(s as Map<String, dynamic>)).toList(),
      counsellingMessage: (json['counsellingMessage'] as String?) ?? '',
      notifications: list('notifications')
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Agar data load na ho paaye to khaali data
  static const HomeData empty =
      HomeData(banners: [], onboarding: [], stats: [], counsellingMessage: '');
}

class OfferBanner {
  final String tag;
  final String title;
  final String subtitle;
  final String button;
  final String action; // courses / internships / counselling

  const OfferBanner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.action,
  });

  factory OfferBanner.fromJson(Map<String, dynamic> json) => OfferBanner(
        tag: (json['tag'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        button: (json['button'] as String?) ?? 'Explore',
        action: (json['action'] as String?) ?? 'courses',
      );
}

class OnboardingSlide {
  final String title;
  final String text;
  final String image;

  const OnboardingSlide({required this.title, required this.text, required this.image});

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) => OnboardingSlide(
        title: (json['title'] as String?) ?? '',
        text: (json['text'] as String?) ?? '',
        image: (json['image'] as String?) ?? '',
      );
}

class AppNotification {
  final String title;
  final String body;
  final String time; // e.g. "Aaj", "2 din pehle"
  final String icon; // course / offer / quiz / certificate / internship

  const AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        time: (json['time'] as String?) ?? '',
        icon: (json['icon'] as String?) ?? 'course',
      );
}

class StatItem {
  final String value;
  final String label;

  const StatItem({required this.value, required this.label});

  factory StatItem.fromJson(Map<String, dynamic> json) => StatItem(
        value: (json['value'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
      );
}
