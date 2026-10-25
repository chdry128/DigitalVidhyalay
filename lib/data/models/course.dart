// ============================================================
//  COURSE MODEL — Ek course me kya-kya information hoti hai
//
//  courses.json ki har field yahan ek variable hai.
//  JSON me nayi field jodni ho to:
//   1. Yahan variable jodo   2. fromJson me padhne ki line jodo
// ============================================================
import '../../config/app_config.dart';

class Course {
  final int id;
  final String title;
  final String subtitle;
  final String category;
  final String imageUrl;
  final int price; // Rupees me, e.g. 9
  final int mrp; // Kata hua (original) price, 0 = mat dikhao
  final String language;
  final String trainer;
  final String format; // e.g. "On Demand Video + Quiz for Certificate"
  final int lessons;
  final String duration;
  final double rating; // 0 = rating mat dikhao
  final int students; // 0 = students mat dikhao
  final String? badge; // "BESTSELLER", "NEW" ya null
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

  factory Course.fromJson(Map<String, dynamic> json) {
    final List<dynamic> moduleList = (json['modules'] as List<dynamic>?) ?? <dynamic>[];
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

  bool get isFree => price == 0;

  /// "₹9" ya "FREE"
  String get priceLabel => isFree ? 'FREE' : '₹$price';

  /// Kitna % discount hai (mrp ke hisaab se)
  int get discountPercent {
    if (mrp <= price || mrp == 0) return 0;
    return (((mrp - price) / mrp) * 100).round();
  }

  /// Video player ke liye saare lessons ek line me (module ke order me).
  /// Agar kisi module me lessons nahi likhe, to module khud ek lesson
  /// ban jata hai — taaki har course me video chale.
  List<PlaylistItem> get playlist {
    // Course me ek bhi module nahi → ek intro lesson (taaki player kabhi khaali na ho)
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

class CourseModule {
  final String title;
  final List<Lesson> lessons;

  const CourseModule({required this.title, required this.lessons});

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lessonList = (json['lessons'] as List<dynamic>?) ?? <dynamic>[];
    return CourseModule(
      title: json['title'] as String,
      lessons: lessonList.map(Lesson.fromJson).toList(),
    );
  }
}

/// Ek lesson. JSON me 2 tarah likh sakte ho:
///   "What is Java"                                        ← sirf naam
///   { "title": "What is Java", "videoId": "OzIjZAIy6Cc", "duration": "9:20" }
class Lesson {
  final String title;
  final String? videoId; // YouTube video ID. null = AppConfig.demoVideoId chalega
  final String duration; // e.g. "9:20"

  const Lesson({required this.title, required this.videoId, required this.duration});

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

/// Video player ki list ka ek item
class PlaylistItem {
  final String key; // Progress save karne ki unique pehchaan, e.g. "1_0_2"
  final int index; // 0 se shuru
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

  /// Pehla lesson sabke liye free (preview)
  bool get isFree => index == 0;
}
