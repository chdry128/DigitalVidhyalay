// ============================================================
//  COURSE THUMB — Course ki photo
//
//  Photo internet se aati hai (courses.json ka "image").
//  Agar photo na mile ya internet na ho, to navy box me
//  course ka naam dikhta hai — app kabhi khaali nahi dikhegi.
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../data/models/course.dart';

class CourseThumb extends StatelessWidget {
  const CourseThumb({
    super.key,
    required this.course,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final Course course;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: course.imageUrl.isEmpty
            ? _Fallback(title: course.title)
            : Image.network(
                course.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _Fallback(title: course.title),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: const Color(0xFFEDE9E4));
                },
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF2B4C9B)],
        ),
      ),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.bottomLeft,
      child: Text(
        title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
