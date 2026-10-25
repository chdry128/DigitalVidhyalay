// ============================================================
//  COURSE DETAIL — Ek course ki poori jaankari
//
//  Tabs: About | Syllabus | Reviews
//  Neeche: price + "Enroll Now" → Payment (enroll ke baad "Continue Learning")
//
//  Text badalna ho to courses.json me us course ka
//  "description" aur "modules" badlein.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/course.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/course_info_bits.dart';
import '../widgets/course_thumb.dart';
import '../widgets/empty_state.dart';
import 'lesson_player_screen.dart';
import 'payment_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  static const List<String> _tabs = ['About', 'Syllabus', 'Reviews'];
  int _tab = 0;

  /// Free preview: enroll nahi → sirf pehla lesson; enroll hai → poora player
  void _openPreview(BuildContext context, bool enrolled) {
    final Course course = widget.course;
    if (course.playlist.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonPlayerScreen(course: course, previewOnly: !enrolled),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Course course = widget.course;
    final bool enrolled = context.watch<AppState>().isCourseEnrolled(course.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---------- Photo + Free preview ----------
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CourseThumb(course: course),
                Center(
                  child: Material(
                    color: Colors.white,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => _openPreview(context, enrolled),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Free preview',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Title ----------
                if (course.badge != null) ...[
                  BadgeLabel(text: course.badge!),
                  const SizedBox(height: 8),
                ],
                Text(course.title, style: AppText.h1),
                if (course.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(course.subtitle, style: AppText.muted),
                ],
                const SizedBox(height: 8),
                RatingRow(course: course, fontSize: 13),
                const SizedBox(height: 16),

                // ---------- Facts ----------
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Fact(icon: Icons.translate_rounded, text: course.language),
                          _Fact(
                            icon: Icons.play_circle_outline_rounded,
                            text: '${course.lessons} lessons',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _Fact(icon: Icons.schedule_rounded, text: course.duration),
                          const _Fact(
                            icon: Icons.workspace_premium_outlined,
                            text: 'Certificate',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ---------- Trainer ----------
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.navy,
                        child: Text(
                          _initials(course.trainer),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your trainer', style: AppText.tiny),
                            Text(course.trainer, style: AppText.cardTitle),
                            const Text(AppConfig.defaultTrainerInfo, style: AppText.small),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Tabs ----------
                Row(
                  children: List<Widget>.generate(_tabs.length, (index) {
                    final bool active = index == _tab;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _tab = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: active ? AppColors.primary : AppColors.border,
                                width: active ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                              color: active ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                if (_tab == 0) _AboutTab(course: course),
                if (_tab == 1) _SyllabusTab(course: course, unlocked: enrolled),
                if (_tab == 2)
                  const EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'Abhi koi review nahi',
                    message: 'App live hone ke baad students ke asli reviews yahan dikhenge.',
                  ),
              ],
            ),
          ),
        ],
      ),

      // ---------- Neeche: price + Enroll ----------
      bottomNavigationBar: _EnrollBar(course: course, enrolled: enrolled),
    );
  }

  static String _initials(String name) {
    final List<String> parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final List<String> points = [
      if (course.format.isNotEmpty) course.format,
      '${course.lessons} lessons · ${course.duration} · ${course.language}',
      'Quiz pass karne par verified certificate',
      'Apni speed se, kabhi bhi padhein',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About this course', style: AppText.title),
        const SizedBox(height: 8),
        Text(course.description, style: AppText.body.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 18),
        const Text("What you'll get", style: AppText.title),
        const SizedBox(height: 8),
        for (final String point in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_rounded, color: AppColors.success, size: 19),
                const SizedBox(width: 8),
                Expanded(child: Text(point, style: AppText.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _SyllabusTab extends StatelessWidget {
  const _SyllabusTab({required this.course, required this.unlocked});

  final Course course;
  final bool unlocked; // true = enroll kiya hai, saare lessons khule

  @override
  Widget build(BuildContext context) {
    if (course.modules.isEmpty) {
      return const Text('Syllabus jald hi update hoga.', style: AppText.muted);
    }
    return Column(
      children: [
        for (int m = 0; m < course.modules.length; m++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ModuleTile(module: course.modules[m], isFirst: m == 0, unlocked: unlocked),
          ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module, required this.isFirst, required this.unlocked});

  final CourseModule module;
  final bool isFirst; // Pehle module ka pehla lesson "Free" hota hai
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(module.title, style: AppText.cardTitle);

    // Lessons nahi hain → simple box
    if (module.lessons.isEmpty) {
      return AppCard(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: title)]));
    }

    // Lessons hain → khulne wala (expand) box
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.only(bottom: 6),
        iconColor: AppColors.primary,
        initiallyExpanded: isFirst,
        title: title,
        subtitle: Text('${module.lessons.length} lessons', style: AppText.small),
        children: [
          for (int i = 0; i < module.lessons.length; i++)
            _lessonRow(module.lessons[i], free: isFirst && i == 0),
        ],
      ),
    );
  }

  Widget _lessonRow(Lesson lesson, {required bool free}) {
    final bool open = unlocked || free;
    return ListTile(
      dense: true,
      leading: Icon(
        open ? Icons.play_circle_outline_rounded : Icons.lock_outline_rounded,
        size: 20,
        color: open ? AppColors.primary : AppColors.textMuted,
      ),
      title: Text(lesson.title, style: const TextStyle(fontSize: 13)),
      subtitle: lesson.duration.isEmpty ? null : Text(lesson.duration, style: AppText.tiny),
      trailing: free && !unlocked
          ? const Text(
              'FREE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
            )
          : null,
    );
  }
}

class _EnrollBar extends StatelessWidget {
  const _EnrollBar({required this.course, required this.enrolled});

  final Course course;
  final bool enrolled;

  void _onPressed(BuildContext context) {
    if (enrolled) {
      // Pehle se enroll hai → jahan chhoda tha wahan se video
      final AppState state = context.read<AppState>();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LessonPlayerScreen(course: course, startLesson: state.resumeLesson(course)),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentScreen(item: PurchaseItem.fromCourse(course)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: enrolled
              ? ElevatedButton.icon(
                  onPressed: () => _onPressed(context),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue Learning'),
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: PriceRow(course: course, big: true)),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: ElevatedButton(
                        onPressed: () => _onPressed(context),
                        child: const Text('Enroll Now'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
