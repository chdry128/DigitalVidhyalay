// ============================================================
//  SEARCH — Courses aur internships dono me dhoondo
//
//  Suggestion wale words badalne ho to: _suggestions
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../data/models/course.dart';
import '../data/models/internship.dart';
import '../state/app_state.dart';
import '../widgets/app_chip.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/internship_card.dart';
import 'course_detail_screen.dart';
import 'internship_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _suggestions = [
    'Java',
    'Python',
    'GATE',
    'Web Development',
    'Flutter',
    'Digital Marketing',
    'Electrical',
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final String query = _controller.text;
    final List<Course> courses = state.searchCourses(query);
    final List<Internship> internships = state.searchInternships(query);
    final int total = courses.length + internships.length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search courses & internships',
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => _setQuery(''),
                    ),
            ),
          ),
        ),
      ),
      body: query.trim().isEmpty
          // ---------- Kuch type nahi kiya → suggestions ----------
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Popular searches', style: AppText.title),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final String s in _suggestions)
                      AppChip(label: s, onTap: () => _setQuery(s)),
                  ],
                ),
              ],
            )
          : total == 0
              // ---------- Kuch nahi mila ----------
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Kuch nahi mila',
                  message: '"$query" se koi course ya internship nahi mila. Doosra word try karein.',
                )
              // ---------- Results ----------
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text('$total ${total == 1 ? 'result' : 'results'}', style: AppText.small),
                    if (courses.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Courses (${courses.length})', style: AppText.title),
                      const SizedBox(height: 10),
                      for (final Course c in courses)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.gap),
                          child: CourseCard(
                            course: c,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => CourseDetailScreen(course: c)),
                            ),
                          ),
                        ),
                    ],
                    if (internships.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Internships (${internships.length})', style: AppText.title),
                      const SizedBox(height: 10),
                      for (final Internship i in internships)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.gap),
                          child: InternshipCard(
                            internship: i,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => InternshipDetailScreen(internship: i),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
    );
  }
}
