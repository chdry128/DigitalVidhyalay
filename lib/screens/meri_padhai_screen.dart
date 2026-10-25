// ============================================================
//  MERI PADHAI — Student ke enrolled courses aur internships
//
//  3 tabs: Courses | Internships | Certificates
//  Course card → "Resume" → video player (jahan chhoda tha)
//  Internship card → weekly progress screen
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/course.dart';
import '../data/models/internship.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/course_thumb.dart';
import '../widgets/empty_state.dart';
import '../widgets/internship_card.dart';
import 'internship_progress_screen.dart';
import 'my_certificates_screen.dart';
import 'lesson_player_screen.dart';

class MeriPadhaiScreen extends StatefulWidget {
  const MeriPadhaiScreen({super.key, required this.onExplore});

  /// "Explore Courses" dabane pe Courses tab kholta hai
  final VoidCallback onExplore;

  @override
  State<MeriPadhaiScreen> createState() => _MeriPadhaiScreenState();
}

class _MeriPadhaiScreenState extends State<MeriPadhaiScreen> {
  int? _selectedTab; // 0 = Courses, 1 = Internships, 2 = Certificates, null = apne aap chuno

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<Course> courses = state.enrolledCourses;
    final List<Internship> internships = state.enrolledInternships;
    // Pehli baar: abhi internship li hai to Internships tab, warna Courses
    final int tab = _selectedTab ?? (state.lastEnrollWasInternship ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Meri Padhai'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          // ---------- Tabs ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _TabButton(
                  label: 'Courses (${courses.length})',
                  active: tab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: 'Internships (${internships.length})',
                  active: tab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                _TabButton(
                  label: 'Certificates (${state.certificates.length})',
                  active: tab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
              ],
            ),
          ),

          // ---------- List ----------
          Expanded(
            child: tab == 2
                ? const CertificateList()
                : tab == 0
                ? (courses.isEmpty
                    ? _empty(
                        icon: Icons.menu_book_outlined,
                        title: 'Abhi koi course nahi hai',
                        message: 'Course enroll karne ke baad aapki padhai yahan dikhegi.',
                        button: 'Explore Courses',
                        onPressed: widget.onExplore,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
                        itemBuilder: (context, index) => _CourseProgressCard(course: courses[index]),
                      ))
                : (internships.isEmpty
                    ? _empty(
                        icon: Icons.work_outline_rounded,
                        title: 'Abhi koi internship nahi',
                        message: 'Internship enroll karne ke baad uske weekly tasks yahan dikhenge.',
                        button: null,
                        onPressed: null,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: internships.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
                        itemBuilder: (context, index) =>
                            _InternshipProgressCard(internship: internships[index]),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String message,
    required String? button,
    required VoidCallback? onPressed,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: icon,
          title: title,
          message: message,
          buttonLabel: button,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress bar (0.0 – 1.0)
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        color: value >= 1 ? AppColors.success : AppColors.primary,
        backgroundColor: const Color(0xFFE7E5E4),
      ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.course});

  final Course course;

  void _resume(BuildContext context) {
    final AppState state = context.read<AppState>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonPlayerScreen(course: course, startLesson: state.resumeLesson(course)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int total = course.playlist.length;
    final int done = state.completedLessonCount(course);
    final bool finished = state.isCourseCompleted(course);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _resume(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseThumb(course: course, height: 140, width: double.infinity),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppText.title),
                const SizedBox(height: 2),
                Text(
                  finished ? 'Saare lessons complete ✓' : '$done of $total lessons complete',
                  style: AppText.small.copyWith(color: finished ? AppColors.success : null),
                ),
                const SizedBox(height: 10),
                _ProgressBar(value: state.courseProgress(course)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _resume(context),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(done == 0 ? 'Start Learning' : (finished ? 'Revise' : 'Resume')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InternshipProgressCard extends StatelessWidget {
  const _InternshipProgressCard({required this.internship});

  final Internship internship;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int done = state.completedWeekCount(internship);

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => InternshipProgressScreen(internship: internship),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypeBadge(type: internship.type),
          const SizedBox(height: 8),
          Text(internship.title, style: AppText.title),
          const SizedBox(height: 2),
          Text('Week $done of ${internship.weeks} complete · Remote', style: AppText.small),
          const SizedBox(height: 10),
          _ProgressBar(value: state.internshipProgress(internship)),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                'Weekly tasks dekhein',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
