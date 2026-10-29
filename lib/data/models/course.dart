// ============================================================
//  COURSE MODEL — Ek course me kya-kya information hoti hai
//
//  2 constructors:
//   • fromJson      → assets/data/courses.json (mock)
//   • fromApiJson   → catalog/courses.php (backend)
//
//  Backend field names:
//    course_id, course_name, course_category, course_description,
//    course_duration, course_fee, thumbnail_url
// ============================================================
import '../../config/app_config.dart';

class Course {
  final int id;
  final String title;
  final String subtitle;
  final String category;
  final String imageUrl;
  final int price;     // Rupees
  final int mrp;       // Original price (0 = don't show)
  final String language;
  final String trainer;
  final String format;
  final int lessons;
  final String duration;
  final double rating; // 0 = don't show
  final int students;  // 0 = don't show
  final String? badge; // "BESTSELLER", "NEW", null
  final String description;
  final List<CourseModule> modules;

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.mrp,
    required this.language,
    required this.trainer,
    required this.format,
    required this.lessons,
    required this.duration,
    required this.rating,
    required this.students,
    required this.badge,
    required this.description,
    required this.modules,
  });

  // ── Mock JSON (assets/data/courses.json) ───────────────────
  factory Course.fromJson(Map<String, dynamic> json) {
    final List<dynamic> moduleList =
        (json['modules'] as List<dynamic>?) ?? <dynamic>[];
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: (json['subtitle'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Other',
      imageUrl: (json['image'] as String?) ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      mrp: (json['mrp'] as num?)?.toInt() ?? 0,
      language: (json['language'] as String?) ?? 'Hindi',
      trainer: (json['trainer'] as String?) ?? AppConfig.defaultTrainer,
      format: (json['format'] as String?) ?? '',
      lessons: (json['lessons'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      students: (json['students'] as num?)?.toInt() ?? 0,
      badge: json['badge'] as String?,
      description: (json['description'] as String?) ?? '',
      modules: moduleList
          .map((m) => CourseModule.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Real API (catalog/courses.php) ─────────────────────────
  // Backend fields: course_id, course_name, course_category,
  //   course_description, course_duration, course_fee, thumbnail_url
  factory Course.fromApiJson(Map<String, dynamic> json) {
    final fee = (json['course_fee'] as num?)?.toInt() ?? 0;
    return Course(
      id: (json['course_id'] as num?)?.toInt() ?? 0,
      title: (json['course_name'] as String?) ?? 'Untitled',
      subtitle: '',
      category: (json['course_category'] as String?) ?? 'Other',
      imageUrl: (json['thumbnail_url'] as String?) ?? '',
      price: fee,
      mrp: 0,
      language: 'Hindi',
      trainer: AppConfig.defaultTrainer,
      format: 'On Demand Video + Quiz for Certificate',
      lessons: 0,
      duration: (json['course_duration'] as String?) ?? '',
      rating: 0,
      students: 0,
      badge: null,
      description: (json['course_description'] as String?) ?? '',
      modules: const [],
    );
  }

  bool get isFree => price == 0;
  String get priceLabel => isFree ? 'FREE' : '₹$price';

  int get discountPercent {
    if (mrp <= price || mrp == 0) return 0;
    return (((mrp - price) / mrp) * 100).round();
  }

  /// Video player ke liye saare lessons (module ke order me)
  List<PlaylistItem> get playlist {
    if (modules.isEmpty) {
      return [
        PlaylistItem(
          key: '${id}_0_0',
          index: 0,
          title: '$title — Introduction',
          moduleTitle: title,
          duration: '',
          videoId: AppConfig.demoVideoId,
        ),
      ];
    }
    final List<PlaylistItem> items = [];
    for (int m = 0; m < modules.length; m++) {
      final CourseModule module = modules[m];
      if (module.lessons.isEmpty) {
        items.add(PlaylistItem(
          key: '${id}_${m}_0',
          index: items.length,
          title: module.title,
          moduleTitle: module.title,
          duration: '',
          videoId: AppConfig.demoVideoId,
        ));
      } else {
        for (int l = 0; l < module.lessons.length; l++) {
          final Lesson lesson = module.lessons[l];
          items.add(PlaylistItem(
            key: '${id}_${m}_$l',
            index: items.length,
            title: lesson.title,
            moduleTitle: module.title,
            duration: lesson.duration,
            videoId: lesson.videoId ?? AppConfig.demoVideoId,
          ));
        }
      }
    }
    return items;
  }
}

// ─────────────────────────────────────────────────────────────
class CourseModule {
  final String title;
  final List<Lesson> lessons;

  const CourseModule({required this.title, required this.lessons});

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lessonList =
        (json['lessons'] as List<dynamic>?) ?? <dynamic>[];
    return CourseModule(
      title: json['title'] as String,
      lessons: lessonList.map(Lesson.fromJson).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class Lesson {
  final String title;
  final String? videoId; // YouTube video ID
  final String duration; // e.g. "9:20"

  const Lesson(
      {required this.title, required this.videoId, required this.duration});

  factory Lesson.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final String? id = json['videoId'] as String?;
      return Lesson(
        title: (json['title'] as String?) ?? '',
        videoId: (id == null || id.trim().isEmpty) ? null : id.trim(),
        duration: (json['duration'] as String?) ?? '',
      );
    }
    return Lesson(title: json.toString(), videoId: null, duration: '');
  }
}

// ─────────────────────────────────────────────────────────────
class PlaylistItem {
  final String key; // Unique progress key, e.g. "1_0_2"
  final int index;
  final String title;
  final String moduleTitle;
  final String duration;
  final String videoId;

  const PlaylistItem({
    required this.key,
    required this.index,
    required this.title,
    required this.moduleTitle,
    required this.duration,
    required this.videoId,
  });

  bool get isFree => index == 0;
}
