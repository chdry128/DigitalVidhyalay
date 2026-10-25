// ============================================================
//  HOME SCREEN — App ka pehla tab
//
//  Upar se neeche:
//   1. Logo + search + notification
//   2. "Namaste, Rahul"
//   3. Search box
//   4. Offer banners (home.json → "banners")
//      + Continue Learning (jab koi course enroll ho)
//   5. Categories (courses.json ki categories se apne aap)
//   6. Popular Courses (sabse zyada students wale)
//   7. Internships (har type ki ek)
//   8. Free counselling card
//   9. Stats (home.json → "stats")
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/category_icons.dart';
import '../data/models/course.dart';
import '../data/models/home_data.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/course_card.dart';
import '../widgets/course_thumb.dart';
import '../widgets/empty_state.dart';
import '../widgets/internship_card.dart';
import '../widgets/section_header.dart';
import 'course_detail_screen.dart';
import 'internship_detail_screen.dart';
import 'lesson_player_screen.dart';
import 'main_shell.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Doosra tab kholne ke liye (MainShell deta hai)
  final ValueChanged<int> onOpenTab;

  void _openCategory(AppState state, String category) {
    state.setCourseFilter(category == 'View All' ? 'All' : category);
    onOpenTab(MainShell.coursesTab);
  }

  void _onBannerTap(BuildContext context, AppState state, OfferBanner banner) {
    switch (banner.action) {
      case 'internships':
        onOpenTab(MainShell.internshipsTab);
        break;
      case 'counselling':
        openWhatsApp(context, message: state.home.counsellingMessage);
        break;
      default:
        state.setCourseFilter('All');
        onOpenTab(MainShell.coursesTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    if (state.isLoading && state.courses.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.errorMessage != null && state.courses.isEmpty) {
      return Scaffold(
        body: Center(
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Kuch gadbad ho gayi',
            message: state.errorMessage!,
            buttonLabel: 'Dobara try karein',
            onPressed: state.loadData,
          ),
        ),
      );
    }

    final List<String> categories = [...state.courseCategories.take(7), 'View All'];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: state.loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              // ---------- 1. Top bar ----------
              Row(
                children: [
                  Image.asset('assets/images/logo.jpg', width: 44, height: 44),
                  const SizedBox(width: 10),
                  const Expanded(child: Text(AppConfig.appName, style: AppText.title)),
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- 2. Greeting ----------
              Text('Namaste, ${state.user?.firstName ?? 'Student'}', style: AppText.h1),
              const SizedBox(height: 2),
              const Text('Aaj kya seekhenge?', style: AppText.muted),
              const SizedBox(height: 16),

              // ---------- 3. Search box ----------
              _SearchBox(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // ---------- 4. Offer banners ----------
              if (state.home.banners.isNotEmpty)
                _BannerCarousel(
                  banners: state.home.banners,
                  onTap: (banner) => _onBannerTap(context, state, banner),
                ),

              // ---------- 4b. Continue learning (enroll kiya ho tab) ----------
              if (state.continueCourse != null) ...[
                const SectionHeader(title: 'Continue Learning'),
                _ContinueCard(course: state.continueCourse!),
              ],

              // ---------- 5. Categories ----------
              const SectionHeader(title: 'Browse Categories'),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                  children: [
                    for (final String category in categories)
                      _CategoryTile(
                        label: category,
                        onTap: () => _openCategory(state, category),
                      ),
                  ],
                ),
              ),

              // ---------- 6. Popular courses ----------
              SectionHeader(
                title: 'Popular Courses',
                actionLabel: 'See all',
                onAction: () => _openCategory(state, 'View All'),
              ),
              SizedBox(
                height: 248,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.popularCourses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.gap),
                  itemBuilder: (context, index) {
                    final course = state.popularCourses[index];
                    return CourseCardCompact(
                      course: course,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CourseDetailScreen(course: course),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ---------- 7. Internships ----------
              SectionHeader(
                title: 'Internships with Certificate',
                actionLabel: 'See all',
                onAction: () => onOpenTab(MainShell.internshipsTab),
              ),
              for (final internship in state.featuredInternships)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.gap),
                  child: InternshipCard(
                    internship: internship,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => InternshipDetailScreen(internship: internship),
                      ),
                    ),
                  ),
                ),

              // ---------- 8. Free counselling ----------
              const SizedBox(height: 12),
              _CounsellingCard(
                onTap: () => openWhatsApp(context, message: state.home.counsellingMessage),
              ),

              // ---------- 9. Stats ----------
              if (state.home.stats.isNotEmpty) ...[
                const SizedBox(height: 24),
                _StatsRow(stats: state.home.stats),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  Home ke chhote hisse (sirf isi screen me use hote hain)
// ============================================================

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 21),
          SizedBox(width: 10),
          Text('Search courses & internships', style: AppText.muted),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.banners, required this.onTap});

  final List<OfferBanner> banners;
  final ValueChanged<OfferBanner> onTap;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  // Banner kitne second me badle
  static const Duration _autoSlide = Duration(seconds: 4);

  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoSlide, (_) {
      if (!_controller.hasClients || widget.banners.length < 2) return;
      final int next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 164,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final OfferBanner banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _BannerCard(banner: banner, onTap: () => widget.onTap(banner)),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.banners.length, (index) {
            final bool active = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.disabled,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final OfferBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF9A3412)],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.tag,
                  style: const TextStyle(
                    color: Color(0xFFFFE4D1),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFFFF1E8), fontSize: 13),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      banner.button,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconForCategory(label), color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.25, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _CounsellingCard extends StatelessWidget {
  const _CounsellingCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Career ko lekar confused?', style: AppText.cardTitle),
                const SizedBox(height: 3),
                const Text(
                  'University admission ke liye hamare counsellor se free me baat karein.',
                  style: AppText.small,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  onPressed: onTap,
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('WhatsApp par baat karein'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.success),
          const SizedBox(width: 12),
          for (final StatItem stat in stats)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat.value, style: AppText.cardTitle),
                  Text(stat.label, style: AppText.tiny),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final PlaylistItem? next = state.resumeLesson(course);
    final int done = state.completedLessonCount(course);
    final int total = course.playlist.length;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LessonPlayerScreen(course: course, startLesson: next),
        ),
      ),
      child: Row(
        children: [
          CourseThumb(course: course, width: 104, height: 96),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    next == null ? '$done/$total lessons' : 'Next: ${next.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: state.courseProgress(course),
                      minHeight: 5,
                      color: AppColors.primary,
                      backgroundColor: const Color(0xFFE7E5E4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'Resume',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
