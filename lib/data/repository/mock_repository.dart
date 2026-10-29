// ============================================================
//  MOCK REPOSITORY — Demo data (assets/data/*.json se)
//
//  AppConfig.useMockData = true hone par yeh use hota hai.
//  Courses / internships badalne ke liye yeh file nahi,
//  assets/data/ ki JSON files badlein.
// ============================================================
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../config/app_config.dart';
import '../models/certificate.dart';
import '../models/course.dart';
import '../models/home_data.dart';
import '../models/internship.dart';
import '../models/offer_letter.dart';
import '../models/payment.dart';
import '../models/quiz.dart';
import '../models/user_profile.dart';
import '../models/workspace_data.dart';
import 'app_repository.dart';

class MockRepository implements AppRepository {
  Future<Map<String, dynamic>> _readJson(String fileName) async {
    final String text = await rootBundle.loadString('assets/data/$fileName');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  // ──────── CATALOG ────────

  @override
  Future<HomeData> getHomeData() async {
    return HomeData.fromJson(await _readJson('home.json'));
  }

  @override
  Future<List<Course>> getCourses({String? category, String? search}) async {
    final json = await _readJson('courses.json');
    final list = (json['courses'] as List<dynamic>?) ?? <dynamic>[];
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

  // ──────── AUTH (mock — no real server) ────────

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Demo: always succeeds
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Demo: OTP 1234 (or any 6-digit code in mock)
    if (otp != AppConfig.demoOtp && otp != '123456') {
      throw Exception('Galat OTP. Demo ke liye ${AppConfig.demoOtp} daalein.');
    }
    final user = UserProfile(
      id: 1,
      phone: '',
      name: 'Demo Student',
      email: email,
      college: 'Demo College',
      city: '',
    );
    return AuthResult(token: 'mock_token', user: user);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = UserProfile(
      id: 1,
      phone: '',
      name: 'Demo Student',
      email: email,
      college: 'Demo College',
      city: '',
    );
    return AuthResult(token: 'mock_token', user: user);
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  // ──────── STUDENT ────────

  @override
  Future<UserProfile> getProfile() async {
    return const UserProfile(
      id: 1,
      phone: '',
      name: 'Demo Student',
      email: 'demo@example.com',
      college: 'Demo College',
      city: '',
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String college,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  // ──────── ENROLLMENT ────────

  @override
  Future<void> enrollFreeInternship({required int internshipId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> applyStipendInternship({
    required int trackId,
    required String resumeUrl,
    required String whyApply,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<List<EnrolledInternship>> getMyInternships() async => [];

  @override
  Future<WorkspaceData> getWorkspace(int internshipId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return WorkspaceData(
      internship: InternshipWorkspaceInfo(
        id: internshipId,
        title: 'Demo Internship',
        durationWeeks: 4,
        completionStatus: 'in_progress',
        progressPercent: 25,
      ),
      quizStatus: const QuizUnlockStatus(
        isUnlocked: false,
        unlockTimestamp: 0,
        unlockDate: 'After 4 weeks',
      ),
      modules: const [
        WorkspaceModule(
          moduleId: 1,
          week: 1,
          moduleOrder: 1,
          title: 'Week 1: Setup & Orientation',
          taskInstructions: 'Install Flutter and push project to GitHub.',
          taskType: 'url_submission',
          hasQuiz: false,
        ),
      ],
    );
  }

  @override
  Future<TaskSubmission> submitTask({
    required int internshipId,
    required int moduleId,
    required String submissionLink,
    String? studentNotes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return TaskSubmission(
      submissionId: 1,
      submissionLink: submissionLink,
      studentNotes: studentNotes,
      status: 'pending',
      submittedAt: 'Just now',
    );
  }

  // ──────── QUIZ (MOCK) ────────

  @override
  Future<List<QuizInfo>> getQuizList({int? internshipId, int? quizId}) async {
    return [
      QuizInfo(
        id: quizId ?? 1,
        internshipId: internshipId ?? 1,
        title: 'Demo Assessment',
        timeLimitMinutes: 30,
        passingScore: 70,
        maxAttempts: 3,
        totalQuestions: 5,
        totalMarks: 5,
        attemptsUsed: 0,
        canAttempt: true,
        isPassed: false,
        highestScorePercent: 0,
        attemptsHistory: const [],
      )
    ];
  }

  @override
  Future<QuizSession> startQuizSession(int quizId) async {
    return QuizSession(
      sessionToken: 'mock_session_token',
      quizId: quizId,
      quizTitle: 'Demo Assessment',
      durationMinutes: 30,
      expiresAt:
          DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
      expiresInSeconds: 1800,
    );
  }

  @override
  Future<List<ApiQuizQuestion>> getQuizQuestions(String sessionToken) async {
    return [
      ApiQuizQuestion(
        questionNumber: 1,
        questionId: 101,
        questionText: 'Demo question 1: What is Flutter?',
        options: const {
          'A': 'UI Toolkit',
          'B': 'Database',
          'C': 'Operating System',
          'D': 'Compiler'
        },
        marks: 1,
      ),
      ApiQuizQuestion(
        questionNumber: 2,
        questionId: 102,
        questionText: 'Demo question 2: What language does Flutter use?',
        options: const {
          'A': 'Java',
          'B': 'Dart',
          'C': 'Python',
          'D': 'C++'
        },
        marks: 1,
      ),
    ];
  }

  @override
  Future<void> saveQuizDraftAnswer({
    required String sessionToken,
    required int questionId,
    required String selectedOption,
    bool isReview = false,
  }) async {}

  @override
  Future<QuizResult> submitQuiz({
    required String sessionToken,
    Map<int, String>? answers,
  }) async {
    return const QuizResult(
      attemptId: 1,
      quizId: 1,
      quizTitle: 'Demo Assessment',
      scoreObtained: 2,
      totalScore: 2,
      percentage: 100.0,
      passingScore: 70,
      status: 'passed',
      isPassed: true,
      completedAt: 'Just now',
    );
  }

  @override
  Future<QuizResult> getQuizResult(int attemptId) async {
    return const QuizResult(
      attemptId: 1,
      quizId: 1,
      quizTitle: 'Demo Assessment',
      scoreObtained: 2,
      totalScore: 2,
      percentage: 100.0,
      passingScore: 70,
      status: 'passed',
      isPassed: true,
      completedAt: 'Just now',
    );
  }

  @override
  Future<void> logQuizViolation({
    required String sessionToken,
    String violationType = 'app_backgrounded',
  }) async {}

  // ──────── STUDENT DOCUMENTS ────────

  @override
  Future<List<CertificateRecord>> getCertificates() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      CertificateRecord(
        id: 'DV-CERT-DEMO01',
        type: 'internship',
        itemId: 1,
        title: 'Full-Stack Web Development',
        studentName: 'Demo Student',
        date: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Software Development',
        durationWeeks: 6,
        verificationUrl: 'http://127.0.0.1:8000/verify.php?id=DV-CERT-DEMO01',
      ),
    ];
  }

  @override
  Future<List<OfferLetterRecord>> getOfferLetters() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      OfferLetterRecord(
        id: 1,
        offerRefNo: 'DV/OFFER/2026/0001',
        programTitle: 'Full-Stack Web Development',
        category: 'Software Development',
        durationWeeks: 6,
        issuedAt: DateTime.now().subtract(const Duration(days: 30)),
        verificationUrl: 'http://127.0.0.1:8000/verify.php?id=DV/OFFER/2026/0001',
      ),
    ];
  }

  @override
  Future<List<PaymentRecord>> getPaymentReceipts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      PaymentRecord(
        paymentId: 101,
        orderId: 'order_DEMO101',
        paymentIdRef: 'pay_DEMO101',
        type: 'internship',
        itemId: 1,
        title: 'Full-Stack Web Development',
        amount: 499,
        status: 'captured',
        method: 'UPI',
        date: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  // ──────── LEGACY PHONE OTP ────────

  @override
  Future<bool> sendOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<bool> verifyOtpLegacy(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return otp == AppConfig.demoOtp;
  }
}
