// ============================================================
//  COURSE CARD — Course ka card
//
//  2 tarah ka:
//   • CourseCard        → Courses list (photo left, details right)
//   • CourseCardCompact → Home ki "Popular Courses" aadi list
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../data/models/course.dart';
import 'app_card.dart';
import 'course_info_bits.dart';
import 'course_thumb.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120),
              child: SizedBox(width: 112, child: CourseThumb(course: course)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (course.badge != null) ...[
                      BadgeLabel(text: course.badge!),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.cardTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${course.trainer} · ${course.language}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small,
                    ),
                    const SizedBox(height: 3),
                    RatingRow(course: course),
                    if (course.lessons > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${course.lessons} lessons'
                        '${course.duration.isNotEmpty ? ' · ${course.duration}' : ''}',
                        style: AppText.small,
                      ),
                    ],
                    const SizedBox(height: 6),
                    PriceRow(course: course),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCardCompact extends StatelessWidget {
  const CourseCardCompact({super.key, required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CourseThumb(course: course, height: 118, width: double.infinity),
                if (course.badge != null)
                  Positioned(top: 8, left: 8, child: BadgeLabel(text: course.badge!)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${course.lessons} lessons · ${course.language}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small,
                  ),
                  const SizedBox(height: 4),
                  RatingRow(course: course),
                  const SizedBox(height: 6),
                  PriceRow(course: course),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
