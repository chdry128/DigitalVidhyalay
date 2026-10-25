// ============================================================
//  COURSES SCREEN — Saare courses + category filter
//
//  Courses jodne / hatane ke liye: assets/data/courses.json
//  Filter ki categories courses.json se apne aap banti hain.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../data/models/course.dart';
import '../state/app_state.dart';
import '../widgets/app_chip.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state.dart';
import 'course_detail_screen.dart';
import 'search_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<Course> list = state.filteredCourses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ChipBar(
            labels: ['All', ...state.courseCategories],
            selected: state.courseFilter,
            onSelected: state.setCourseFilter,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              '${list.length} ${list.length == 1 ? 'course' : 'courses'}',
              style: AppText.small,
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'Is category me abhi koi course nahi',
                    message: 'Doosri category dekhein ya saare courses dekhein.',
                    buttonLabel: 'Saare courses',
                    onPressed: () => state.setCourseFilter('All'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
                    itemBuilder: (context, index) {
                      final Course course = list[index];
                      return CourseCard(
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
        ],
      ),
    );
  }
}
