// ============================================================
//  APP REPOSITORY — App ko data kahan se milega, uski "list"
//
//  Yeh sirf functions ke naam hain (kaam nahi karta).
//  Asli kaam 2 files karti hain:
//   • mock_repository.dart → abhi (JSON files se demo data)
//   • api_repository.dart  → baad me (sir ke server / backend se)
//
//  Kaunsi file use hogi, yeh AppConfig.useMockData decide karta hai.
//  Screens ko pata hi nahi ki data JSON se aaya ya server se —
//  isliye backend lagate waqt screens badalni nahi padengi.
// ============================================================
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/quiz.dart';

abstract class AppRepository {
  /// Home screen: banners, onboarding, stats
  Future<HomeData> getHomeData();

  /// Saare courses
  Future<List<Course>> getCourses();

  /// Saari internships
  Future<InternshipCatalog> getInternships();

  /// Har course ke quiz sawaal (courseId → sawaal)
  Future<Map<int, List<QuizQuestion>>> getQuizzes();

  /// Phone number pe OTP bhejo. true = OTP chala gaya
  Future<bool> sendOtp(String phone);

  /// OTP check karo. true = OTP sahi hai
  Future<bool> verifyOtp(String phone, String otp);
}
