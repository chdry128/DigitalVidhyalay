// ============================================================
//  MOCK REPOSITORY — Demo data (assets/data/*.json se)
//
//  Abhi app isi se chal rahi hai. Courses / internships badalne
//  ke liye yeh file nahi, assets/data/ ki JSON files badlein.
// ============================================================
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../config/app_config.dart';
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/quiz.dart';
import 'app_repository.dart';

class MockRepository implements AppRepository {
  /// JSON file padh kar Map me badalta hai
  Future<Map<String, dynamic>> _readJson(String fileName) async {
    final String text = await rootBundle.loadString('assets/data/$fileName');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  @override
  Future<HomeData> getHomeData() async {
    return HomeData.fromJson(await _readJson('home.json'));
  }

  @override
  Future<List<Course>> getCourses() async {
    final Map<String, dynamic> json = await _readJson('courses.json');
    final List<dynamic> list = (json['courses'] as List<dynamic>?) ?? <dynamic>[];
    return list.map((c) => Course.fromJson(c as Map<String, dynamic>)).toList();
  }

  @override
  Future<InternshipCatalog> getInternships() async {
    return InternshipCatalog.fromJson(await _readJson('internships.json'));
  }

  @override
  Future<Map<int, List<QuizQuestion>>> getQuizzes() async {
    return QuizQuestion.catalogFromJson(await _readJson('quizzes.json'));
  }

  @override
  Future<bool> sendOtp(String phone) async {
    // Demo: asli SMS nahi jata, thoda ruk kar "sent" bata dete hain
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return otp == AppConfig.demoOtp;
  }
}
