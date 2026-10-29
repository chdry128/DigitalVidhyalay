// ============================================================
//  APP REPOSITORY — App ko data kahan se milega, uski "list"
//
//  Kaam 2 files karti hain:
//   • mock_repository.dart → JSON files se demo data (offline test)
//   • api_repository.dart  → PHP backend se asli data (local / production)
//
//  Kaunsi file use hogi: AppConfig.useMockData decide karta hai.
// ============================================================
import '../models/certificate.dart';
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/offer_letter.dart';
import '../models/payment.dart';
import '../models/quiz.dart';
import '../models/user_profile.dart';
import '../models/workspace_data.dart';

/// Auth result — token + user ek saath
class AuthResult {
  final String token;
  final UserProfile user;
  const AuthResult({required this.token, required this.user});
}

abstract class AppRepository {
  // ──────────────────────────────────────────────
  //  CATALOG (no auth needed)
  // ──────────────────────────────────────────────

  /// Home screen: banners, featured courses, internships
  Future<HomeData> getHomeData();

  /// Saare courses (with optional category/search filter)
  Future<List<Course>> getCourses({String? category, String? search});

  /// Saari internships (regular + stipend)
  Future<InternshipCatalog> getInternships();

  /// Har course ke quiz sawaal (courseId → sawaal)
  Future<Map<int, List<QuizQuestion>>> getQuizzes();

  // ──────────────────────────────────────────────
  //  AUTH
  // ──────────────────────────────────────────────

  /// Naya account banana (email, name, phone, password → 6-digit OTP bhejta hai)
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// OTP verify karo → token + user milta hai
  Future<AuthResult> verifyOtp({required String email, required String otp});

  /// Email + password se seedha login (already verified users ke liye)
  Future<AuthResult> login({required String email, required String password});

  /// OTP dobara bhejo
  Future<void> resendOtp({required String email});

  // ──────────────────────────────────────────────
  //  STUDENT (auth required)
  // ──────────────────────────────────────────────

  /// Apna profile GET/UPDATE
  Future<UserProfile> getProfile();
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String college,
  });

  // ──────────────────────────────────────────────
  //  ENROLLMENT / INTERNSHIP  (auth required)
  // ──────────────────────────────────────────────

  /// Free internship me seedha enroll karo
  Future<void> enrollFreeInternship({required int internshipId});

  /// Stipend internship ke liye apply karo
  Future<void> applyStipendInternship({
    required int trackId,
    required String resumeUrl,
    required String whyApply,
  });

  /// Logged-in student ki enrolled internships fetch karo (auth required)
  Future<List<EnrolledInternship>> getMyInternships();

  /// Internship Workspace & Modules (auth required)
  Future<WorkspaceData> getWorkspace(int internshipId);

  /// Task submission (e.g. GitHub link) (auth required)
  Future<TaskSubmission> submitTask({
    required int internshipId,
    required int moduleId,
    required String submissionLink,
    String? studentNotes,
  });

  // ──────────────────────────────────────────────
  //  QUIZ & ASSESSMENTS (auth required)
  // ──────────────────────────────────────────────

  /// Internship ya specific quiz ki details aur attempt history fetch karo
  Future<List<QuizInfo>> getQuizList({int? internshipId, int? quizId});

  /// Naya timer-based quiz session shuru karo (ya active resume karo)
  Future<QuizSession> startQuizSession(int quizId);

  /// Session ke active sawaal fetch karo (without revealing answers)
  Future<List<ApiQuizQuestion>> getQuizQuestions(String sessionToken);

  /// Sawaal ka draft answer save karo
  Future<void> saveQuizDraftAnswer({
    required String sessionToken,
    required int questionId,
    required String selectedOption,
    bool isReview = false,
  });

  /// Quiz submit karo aur evaluation result pao
  Future<QuizResult> submitQuiz({
    required String sessionToken,
    Map<int, String>? answers,
  });

  /// Completed attempt ka detailed review fetch karo
  Future<QuizResult> getQuizResult(int attemptId);

  /// Tab switch ya app background violation log karo
  Future<void> logQuizViolation({
    required String sessionToken,
    String violationType = 'app_backgrounded',
  });

  // ──────────────────────────────────────────────
  //  STUDENT DOCUMENTS (auth required)
  // ──────────────────────────────────────────────

  /// Logged-in student ke verified certificates fetch karo
  Future<List<CertificateRecord>> getCertificates();

  /// Logged-in student ke internship offer letters fetch karo
  Future<List<OfferLetterRecord>> getOfferLetters();

  /// Logged-in student ki payment receipts fetch karo
  Future<List<PaymentRecord>> getPaymentReceipts();

  // ──────────────────────────────────────────────
  //  LEGACY phone OTP (mock mode me kaam karta hai)
  // ──────────────────────────────────────────────
  Future<bool> sendOtp(String phone);
  Future<bool> verifyOtpLegacy(String phone, String otp);
}
