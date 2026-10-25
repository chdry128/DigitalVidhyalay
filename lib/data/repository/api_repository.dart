// ============================================================
//  API REPOSITORY — Asli backend (sir ke server) se data
//
//  ABHI KHAALI HAI. Backend (PHP API) ready hone ke baad:
//   1. pubspec.yaml me "http" package jodo
//   2. Neeche har function me API call likho
//   3. app_config.dart me useMockData = false karo
//
//  Har API ko wahi JSON bhejna hai jo assets/data/ ki files me
//  hai — tab models (Course, Internship) bina badle kaam karenge.
// ============================================================
import '../../config/app_config.dart';
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/quiz.dart';
import 'app_repository.dart';

class ApiRepository implements AppRepository {
  final String baseUrl = AppConfig.apiBaseUrl;

  @override
  Future<HomeData> getHomeData() {
    // TODO: GET {baseUrl}/home  → home.json jaisa JSON
    throw UnimplementedError('API abhi bani nahi: GET $baseUrl/home');
  }

  @override
  Future<List<Course>> getCourses() {
    // TODO: GET {baseUrl}/courses  → { "courses": [ ... ] }
    throw UnimplementedError('API abhi bani nahi: GET $baseUrl/courses');
  }

  @override
  Future<InternshipCatalog> getInternships() {
    // TODO: GET {baseUrl}/internships  → internships.json jaisa JSON
    throw UnimplementedError('API abhi bani nahi: GET $baseUrl/internships');
  }

  @override
  Future<Map<int, List<QuizQuestion>>> getQuizzes() {
    // TODO: GET {baseUrl}/quizzes  → quizzes.json jaisa JSON
    throw UnimplementedError('API abhi bani nahi: GET $baseUrl/quizzes');
  }

  @override
  Future<bool> sendOtp(String phone) {
    // TODO: POST {baseUrl}/auth/send-otp   body: { "phone": "98xxxxxxxx" }
    throw UnimplementedError('API abhi bani nahi: POST $baseUrl/auth/send-otp');
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) {
    // TODO: POST {baseUrl}/auth/verify-otp  body: { "phone": "...", "otp": "1234" }
    //       → { "token": "JWT...", "user": { ... } }  token ko save karna hai
    throw UnimplementedError('API abhi bani nahi: POST $baseUrl/auth/verify-otp');
  }
}
