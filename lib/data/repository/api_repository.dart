// ============================================================
//  API REPOSITORY — Asli PHP backend se data
//
//  Local test: http://40.40.24.210:8000/mobile-api  (same Wi-Fi)
//              http://10.0.2.2:8000/mobile-api       (Android emulator)
//
//  AppConfig.apiBaseUrl me URL set karo — sirf ek line change.
//
//  Koi screen isme directly nahi aati — AppState ke through aata hai.
// ============================================================
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/certificate.dart';
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/offer_letter.dart';
import '../models/payment.dart';
import '../models/quiz.dart';
import '../models/user_profile.dart';
import '../models/workspace_data.dart';
import 'api_client.dart';
import 'app_repository.dart';

class ApiRepository implements AppRepository {
  final ApiClient _api = ApiClient.instance;

  // ──────────────────────────────────────────────────────────────────
  //  CATALOG — No auth needed
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<HomeData> getHomeData() async {
    final data = await _api.get('catalog/home.php');
    // Backend returns: banners, featured_courses, stipend_internships,
    // regular_internships, announcements
    return HomeData.fromApiJson(data['data'] as Map<String, dynamic>? ?? {});
  }

  @override
  Future<List<Course>> getCourses({String? category, String? search}) async {
    final query = <String, String>{};
    if (category != null && category != 'All') query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final data = await _api.get('catalog/courses.php', query: query);
    final raw = (data['data']?['courses'] as List<dynamic>?) ?? <dynamic>[];
    return raw
        .map((c) => Course.fromApiJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InternshipCatalog> getInternships() async {
    final data = await _api.get('catalog/internships.php');
    final raw =
        (data['data']?['internships'] as List<dynamic>?) ?? <dynamic>[];
    return InternshipCatalog(
      internships: raw
          .map((i) => Internship.fromApiJson(i as Map<String, dynamic>))
          .toList(),
      whatYouGet: const [
        'Industry-recognized certificate',
        'Live project experience',
        'Mentor guidance & support',
        'Flexible remote work schedule',
        'LinkedIn recommendation letter',
      ],
    );
  }

  @override
  Future<Map<int, List<QuizQuestion>>> getQuizzes() async {
    // Quizzes are still stored in assets/data/quizzes.json for now
    // (server-side quiz feature is built but optional for Phase 1)
    // Return empty map — quiz screen handles this gracefully
    return <int, List<QuizQuestion>>{};
  }

  // ──────────────────────────────────────────────────────────────────
  //  AUTH
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _api.post('auth/register.php', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    // On success PHP returns 201 with { email, expires_in_seconds }
    // We just need it to not throw
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _api.post('auth/verify-otp.php', {
      'email': email,
      'otp': otp,
    });
    final d = res['data'] as Map<String, dynamic>? ?? {};
    final token = d['token'] as String? ?? '';
    final userJson = d['user'] as Map<String, dynamic>? ?? {};
    final user = UserProfile.fromJson(userJson);

    // Save token for future authenticated calls
    await ApiClient.saveToken(token);
    await _saveUserToPrefs(user);
    return AuthResult(token: token, user: user);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('auth/login.php', {
      'email': email,
      'password': password,
    });
    final d = res['data'] as Map<String, dynamic>? ?? {};
    final token = d['token'] as String? ?? '';
    final userJson = d['user'] as Map<String, dynamic>? ?? {};
    final user = UserProfile.fromJson(userJson);

    await ApiClient.saveToken(token);
    await _saveUserToPrefs(user);
    return AuthResult(token: token, user: user);
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _api.post('auth/resend-otp.php', {'email': email});
  }

  // ──────────────────────────────────────────────────────────────────
  //  STUDENT PROFILE
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<UserProfile> getProfile() async {
    final res = await _api.get('student/profile.php', auth: true);
    final userJson =
        res['data']?['user'] as Map<String, dynamic>? ?? {};
    final user = UserProfile.fromJson(userJson);
    await _saveUserToPrefs(user);
    return user;
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String college,
  }) async {
    await _api.post(
      'student/profile.php',
      {'full_name': name, 'phone': phone, 'college_name': college},
      auth: true,
    );
  }

  // ──────────────────────────────────────────────────────────────────
  //  ENROLLMENT
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<void> enrollFreeInternship({required int internshipId}) async {
    await _api.post(
      'internship/enroll-free.php',
      {'internship_id': internshipId},
      auth: true,
    );
  }

  @override
  Future<void> applyStipendInternship({
    required int trackId,
    required String resumeUrl,
    required String whyApply,
  }) async {
    await _api.post(
      'stipend/apply.php',
      {
        'track_id': trackId,
        'resume_url': resumeUrl,
        'why_apply': whyApply,
      },
      auth: true,
    );
  }

  @override
  Future<List<EnrolledInternship>> getMyInternships() async {
    final res = await _api.get('internship/my-internships.php', auth: true);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['internships'] as List<dynamic>? ?? [];
    return list
        .map((e) => EnrolledInternship.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WorkspaceData> getWorkspace(int internshipId) async {
    final res = await _api.get(
      'internship/workspace.php',
      query: {'internship_id': internshipId.toString()},
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return WorkspaceData.fromJson(data);
  }

  @override
  Future<TaskSubmission> submitTask({
    required int internshipId,
    required int moduleId,
    required String submissionLink,
    String? studentNotes,
  }) async {
    final res = await _api.post(
      'internship/submit-task.php',
      {
        'internship_id': internshipId,
        'module_id': moduleId,
        'submission_link': submissionLink,
        if (studentNotes != null && studentNotes.isNotEmpty)
          'student_notes': studentNotes,
      },
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return TaskSubmission(
      submissionId: 0,
      submissionLink: data['submission_link'] as String? ?? submissionLink,
      studentNotes: studentNotes,
      status: data['status'] as String? ?? 'pending',
      submittedAt: data['submitted_at'] as String?,
    );
  }

  // ──────────────────────────────────────────────
  //  QUIZ & ASSESSMENTS (auth required)
  // ──────────────────────────────────────────────

  @override
  Future<List<QuizInfo>> getQuizList({int? internshipId, int? quizId}) async {
    final Map<String, String> q = {};
    if (internshipId != null) q['internship_id'] = internshipId.toString();
    if (quizId != null) q['quiz_id'] = quizId.toString();

    final res = await _api.get('quiz/list.php', query: q, auth: true);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['quizzes'] as List<dynamic>? ?? [];
    return list
        .map((e) => QuizInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuizSession> startQuizSession(int quizId) async {
    final res = await _api.post(
      'quiz/start-session.php',
      {'quiz_id': quizId},
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return QuizSession.fromJson(data);
  }

  @override
  Future<List<ApiQuizQuestion>> getQuizQuestions(String sessionToken) async {
    final res = await _api.get(
      'quiz/questions.php',
      query: {'session_token': sessionToken},
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['questions'] as List<dynamic>? ?? [];
    return list
        .map((e) => ApiQuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveQuizDraftAnswer({
    required String sessionToken,
    required int questionId,
    required String selectedOption,
    bool isReview = false,
  }) async {
    await _api.post(
      'quiz/save-draft.php',
      {
        'session_token': sessionToken,
        'question_id': questionId,
        'selected_option': selectedOption,
        'is_review': isReview,
      },
      auth: true,
    );
  }

  @override
  Future<QuizResult> submitQuiz({
    required String sessionToken,
    Map<int, String>? answers,
  }) async {
    final Map<String, dynamic> body = {
      'session_token': sessionToken,
    };
    if (answers != null && answers.isNotEmpty) {
      body['answers'] = answers.map((k, v) => MapEntry(k.toString(), v));
    }

    final res = await _api.post(
      'quiz/submit.php',
      body,
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return QuizResult.fromJson(data);
  }

  @override
  Future<QuizResult> getQuizResult(int attemptId) async {
    final res = await _api.get(
      'quiz/result.php',
      query: {'attempt_id': attemptId.toString()},
      auth: true,
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return QuizResult.fromJson(data);
  }

  @override
  Future<void> logQuizViolation({
    required String sessionToken,
    String violationType = 'app_backgrounded',
  }) async {
    await _api.post(
      'quiz/log-violation.php',
      {
        'session_token': sessionToken,
        'violation_type': violationType,
      },
      auth: true,
     );
  }

  // ──────────────────────────────────────────────────────────────────
  //  STUDENT DOCUMENTS (auth required)
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<List<CertificateRecord>> getCertificates() async {
    final res = await _api.get('student/certificates.php', auth: true);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['certificates'] as List? ?? [];
    return list
        .map((e) => CertificateRecord.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OfferLetterRecord>> getOfferLetters() async {
    final res = await _api.get('student/offer-letters.php', auth: true);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['offer_letters'] as List? ?? [];
    return list
        .map((e) => OfferLetterRecord.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentRecord>> getPaymentReceipts() async {
    final res = await _api.get('student/payment-receipts.php', auth: true);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['payments'] as List? ?? [];
    return list
        .map((e) => PaymentRecord.fromApi(e as Map<String, dynamic>))
        .toList();
  }

  // ──────────────────────────────────────────────────────────────────
  //  LEGACY PHONE OTP — Used only in Mock mode (unused in API mode)
  // ──────────────────────────────────────────────────────────────────

  @override
  Future<bool> sendOtp(String phone) async => true; // No-op in API mode

  @override
  Future<bool> verifyOtpLegacy(String phone, String otp) async => false;

  // ──────────────────────────────────────────────────────────────────
  //  INTERNAL HELPERS
  // ──────────────────────────────────────────────────────────────────

  /// User profile SharedPreferences me save karna (offline access)
  Future<void> _saveUserToPrefs(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_json', jsonEncode(user.toPrefsMap()));
  }
}
