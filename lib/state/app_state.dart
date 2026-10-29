// ============================================================
//  APP STATE — App ka "dimaag"
//
//  • Data load karna (courses, internships, home) — ab PHP server se
//  • Login / register / OTP verify / logout
//  • JWT token manage karna
//  • Phone me save karna (app band karke kholne pe bhi yaad rahe)
//
//  Koi bhi screen isse data aise leti hai:
//      final state = context.watch<AppState>();
//      state.courses
// ============================================================
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/certificate.dart';
import '../data/models/course.dart';
import '../data/models/home_data.dart';
import '../data/models/internship.dart';
import '../data/models/offer_letter.dart';
import '../data/models/payment.dart';
import '../data/models/quiz.dart';
import '../data/models/user_profile.dart';
import '../data/models/workspace_data.dart';
import '../data/repository/api_client.dart';
import '../data/repository/app_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final AppRepository repository;

  // ── SharedPreferences keys ──────────────────────────────────
  static const String _kOnboardingSeen      = 'onboarding_seen';
  static const String _kUserJson            = 'user_json';      // NEW: full user JSON
  static const String _kEnrolledCourses     = 'enrolled_courses';
  static const String _kEnrolledInternships = 'enrolled_internships';
  static const String _kAppliedInternships  = 'applied_internships';
  static const String _kDoneLessons         = 'done_lessons';
  static const String _kDoneWeeks           = 'done_weeks';
  static const String _kLastLesson          = 'last_lesson';
  static const String _kPayments            = 'payments';
  static const String _kCertificates        = 'certificates';

  // ── Learning data (locally cached) ─────────────────────────
  final Set<int>    enrolledCourseIds     = <int>{};
  final Set<int>    enrolledInternshipIds = <int>{};
  final Set<int>    appliedInternshipIds  = <int>{};
  final Set<String> completedLessons      = <String>{}; // PlaylistItem.key
  final Set<String> completedWeeks        = <String>{}; // "internshipId_week"
  final Map<int, String>        _lastLessonKey = <int, String>{};
  final List<PaymentRecord>     payments       = <PaymentRecord>[];
  final List<CertificateRecord> certificates   = <CertificateRecord>[];
  final List<OfferLetterRecord> offerLetters   = <OfferLetterRecord>[];

  bool isLoadingCertificates = false;
  String? certificatesError;
  bool isLoadingOfferLetters = false;
  String? offerLettersError;
  bool isLoadingPayments = false;
  String? paymentsError;

  bool lastEnrollWasInternship = false;

  // ── Catalog data ────────────────────────────────────────────
  HomeData home                        = HomeData.empty;
  List<Course> courses                 = [];
  InternshipCatalog internshipCatalog  = InternshipCatalog.empty;
  Map<int, List<QuizQuestion>> quizzes = {};
  List<Internship> get internships => internshipCatalog.internships;

  bool isLoading = true;
  String? errorMessage;

  // ── User / Auth ─────────────────────────────────────────────
  UserProfile? user;
  bool onboardingSeen = false;
  bool get isLoggedIn => user != null && user!.isComplete;

  // ── Courses screen filter ───────────────────────────────────
  String courseFilter = 'All';

  // ── Auth state for register → OTP flow ─────────────────────
  String? pendingEmail; // Email awaiting OTP verification

  // ============================================================
  //  INIT — Splash screen se ek baar
  // ============================================================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    onboardingSeen = prefs.getBool(_kOnboardingSeen) ?? false;

    // Restore session: check secure storage for JWT token
    final token = await ApiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        // Authenticated live profile fetch from local PHP server
        user = await repository.getProfile();
        await syncMyInternships();
      } catch (e) {
        if (e is ApiException && e.statusCode == 401) {
          // Token is expired, invalid, or student blocked -> wipe session
          await logout();
        } else {
          // Offline / local cache fallback
          final userJsonStr = prefs.getString(_kUserJson);
          if (userJsonStr != null) {
            try {
              final map = jsonDecode(userJsonStr) as Map<String, dynamic>;
              user = UserProfile.fromPrefsMap(map);
            } catch (_) {
              user = null;
            }
          }
        }
      }
    } else {
      user = null;
    }

    _loadLearning(prefs);
    await loadData();
  }

  // ── Learning data restore ───────────────────────────────────
  void _loadLearning(SharedPreferences prefs) {
    Set<int> readIds(String key) =>
        (prefs.getStringList(key) ?? <String>[])
            .map(int.tryParse)
            .whereType<int>()
            .toSet();

    enrolledCourseIds
      ..clear()
      ..addAll(readIds(_kEnrolledCourses));
    enrolledInternshipIds
      ..clear()
      ..addAll(readIds(_kEnrolledInternships));
    appliedInternshipIds
      ..clear()
      ..addAll(readIds(_kAppliedInternships));
    completedLessons
      ..clear()
      ..addAll(prefs.getStringList(_kDoneLessons) ?? <String>[]);
    completedWeeks
      ..clear()
      ..addAll(prefs.getStringList(_kDoneWeeks) ?? <String>[]);

    _lastLessonKey.clear();
    for (final entry in prefs.getStringList(_kLastLesson) ?? <String>[]) {
      final parts = entry.split('|'); // "1|1_0_2"
      final courseId = parts.isNotEmpty ? int.tryParse(parts.first) : null;
      if (courseId != null && parts.length == 2) {
        _lastLessonKey[courseId] = parts[1];
      }
    }

    certificates.clear();
    for (final text in prefs.getStringList(_kCertificates) ?? <String>[]) {
      try {
        certificates
            .add(CertificateRecord.fromJson(jsonDecode(text) as Map<String, dynamic>));
      } catch (_) {}
    }

    payments.clear();
    for (final text in prefs.getStringList(_kPayments) ?? <String>[]) {
      try {
        payments
            .add(PaymentRecord.fromJson(jsonDecode(text) as Map<String, dynamic>));
      } catch (_) {}
    }
  }

  Future<void> _saveLearning() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids(Set<int> set) =>
        set.map((id) => id.toString()).toList();
    await prefs.setStringList(_kEnrolledCourses, ids(enrolledCourseIds));
    await prefs.setStringList(
        _kEnrolledInternships, ids(enrolledInternshipIds));
    await prefs.setStringList(
        _kAppliedInternships, ids(appliedInternshipIds));
    await prefs.setStringList(_kDoneLessons, completedLessons.toList());
    await prefs.setStringList(_kDoneWeeks, completedWeeks.toList());
    await prefs.setStringList(
      _kLastLesson,
      _lastLessonKey.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
    await prefs.setStringList(
        _kPayments, payments.map((p) => jsonEncode(p.toJson())).toList());
    await prefs.setStringList(_kCertificates,
        certificates.map((c) => jsonEncode(c.toJson())).toList());
  }

  // ============================================================
  //  DATA LOADING — Catalog (courses, internships, home)
  // ============================================================
  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        repository.getHomeData(),
        repository.getCourses(),
        repository.getInternships(),
        repository.getQuizzes(),
      ]);
      home               = results[0] as HomeData;
      courses            = results[1] as List<Course>;
      internshipCatalog  = results[2] as InternshipCatalog;
      quizzes            = results[3] as Map<int, List<QuizQuestion>>;
    } catch (e) {
      errorMessage =
          'Data load nahi ho paya. Server / internet check karein.';
      debugPrint('loadData error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // ============================================================
  //  ONBOARDING
  // ============================================================
  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
    notifyListeners();
  }

  // ============================================================
  //  AUTH — Register / OTP / Login / Logout
  // ============================================================

  /// Step 1 — New user: register (sends 6-digit OTP to email)
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    pendingEmail = email;
    notifyListeners();
  }

  /// Step 2 — Verify OTP (after register OR resend)
  Future<void> verifyOtp({required String email, required String otp}) async {
    final result = await repository.verifyOtp(email: email, otp: otp);
    user = result.user;
    pendingEmail = null;
    await _saveUserToPrefs();
    await syncMyInternships();
    notifyListeners();
  }

  /// Direct login (existing verified user: email + password)
  Future<void> login({required String email, required String password}) async {
    final result = await repository.login(email: email, password: password);
    user = result.user;
    await _saveUserToPrefs();
    await syncMyInternships();
    notifyListeners();
  }

  /// Resend OTP to email
  Future<void> resendOtp({required String email}) async {
    await repository.resendOtp(email: email);
  }

  /// Legacy phone OTP (mock mode only)
  Future<bool> sendOtp(String phone) =>
      repository.sendOtp(phone);

  /// Legacy phone OTP verify (mock mode only)
  Future<bool> verifyOtpLegacy(String phone, String otp) =>
      repository.verifyOtpLegacy(phone, otp);

  /// Used by legacy OTP screen to set user after mock verify
  Future<void> loginWithPhone(String phone) async {
    if (user == null || (user!.phone != phone && phone.isNotEmpty)) {
      user = UserProfile(
          id: 0,
          phone: phone,
          name: '',
          email: '',
          college: '',
          city: '');
    }
    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String college,
    required String city,
  }) async {
    final current = user ??
        const UserProfile(
            id: 0, phone: '', name: '', email: '', college: '', city: '');
    user = current.copyWith(
      name: name.trim(),
      email: email.trim(),
      college: college.trim(),
      city: city.trim(),
    );
    await _saveUserToPrefs();

    // Also push to server if logged in via API
    try {
      await repository.updateProfile(
        name: name.trim(),
        phone: current.phone,
        college: college.trim(),
      );
    } catch (_) {
      // Non-fatal — local save still worked
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserJson);
    await ApiClient.clearToken();
    for (final key in [
      _kEnrolledCourses, _kEnrolledInternships, _kAppliedInternships,
      _kDoneLessons, _kDoneWeeks, _kLastLesson, _kPayments, _kCertificates,
    ]) {
      await prefs.remove(key);
    }
    user = null;
    pendingEmail = null;
    enrolledCourseIds.clear();
    enrolledInternshipIds.clear();
    appliedInternshipIds.clear();
    completedLessons.clear();
    completedWeeks.clear();
    _lastLessonKey.clear();
    payments.clear();
    certificates.clear();
    offerLetters.clear();
    certificatesError = null;
    offerLettersError = null;
    paymentsError = null;
    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserJson, jsonEncode(user!.toPrefsMap()));
  }

  // ============================================================
  //  COURSES
  // ============================================================
  List<String> get courseCategories {
    final result = <String>[];
    for (final c in courses) {
      if (!result.contains(c.category)) result.add(c.category);
    }
    return result;
  }

  List<Course> get filteredCourses {
    if (courseFilter == 'All') return courses;
    return courses.where((c) => c.category == courseFilter).toList();
  }

  void setCourseFilter(String category) {
    courseFilter = category;
    notifyListeners();
  }

  List<Course> get popularCourses {
    final sorted = List<Course>.of(courses)
      ..sort((a, b) => b.students.compareTo(a.students));
    return sorted.take(6).toList();
  }

  // ============================================================
  //  INTERNSHIPS
  // ============================================================
  List<Internship> internshipsOfType(String type) =>
      internships.where((i) => i.type == type).toList();

  List<String> domainsForType(String type) {
    final result = <String>[];
    for (final i in internshipsOfType(type)) {
      if (!result.contains(i.domain)) result.add(i.domain);
    }
    return result;
  }

  List<Internship> get featuredInternships {
    final result = <Internship>[];
    for (final type in Internship.allTypes) {
      final ofType = internshipsOfType(type);
      if (ofType.isNotEmpty) result.add(ofType.first);
    }
    return result;
  }

  Course? courseById(int id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  Internship? internshipById(int id) {
    for (final i in internships) {
      if (i.id == id) return i;
    }
    return null;
  }

  // ============================================================
  //  ENROLL / PAYMENT
  // ============================================================
  bool isCourseEnrolled(int id)     => enrolledCourseIds.contains(id);
  bool isInternshipEnrolled(int id) => enrolledInternshipIds.contains(id);
  bool hasApplied(int internshipId) => appliedInternshipIds.contains(internshipId);

  List<Course> get enrolledCourses =>
      enrolledCourseIds
          .map(courseById)
          .whereType<Course>()
          .toList()
          .reversed
          .toList();

  List<Internship> get enrolledInternships =>
      enrolledInternshipIds
          .map(internshipById)
          .whereType<Internship>()
          .toList()
          .reversed
          .toList();

  /// DEMO payment: receipt banao + enroll karo (no real money)
  Future<PaymentRecord> completePurchase(
      PurchaseItem item, String method) async {
    final now = DateTime.now();
    final record = PaymentRecord(
      orderId: 'DV${now.millisecondsSinceEpoch.toString().substring(5)}',
      type: item.type,
      itemId: item.id,
      title: item.title,
      amount: item.amount,
      method: method,
      date: now,
    );
    payments.insert(0, record);
    if (item.isCourse) {
      enrolledCourseIds.add(item.id);
    } else {
      enrolledInternshipIds.add(item.id);
    }
    lastEnrollWasInternship = !item.isCourse;
    await _saveLearning();
    notifyListeners();
    return record;
  }

  Future<void> enrollFreeInternship(Internship internship) async {
    // Try server first (auth), fallback to local only
    try {
      await repository.enrollFreeInternship(
          internshipId: internship.id);
    } catch (_) {
      // If server fails, still enroll locally (mock / offline)
    }
    enrolledInternshipIds.add(internship.id);
    lastEnrollWasInternship = true;
    await _saveLearning();
    notifyListeners();
  }

  Future<void> applyForInternship(Internship internship) async {
    appliedInternshipIds.add(internship.id);
    await _saveLearning();
    notifyListeners();
  }

  // ============================================================
  //  WORKSPACE & TASKS (API)
  // ============================================================
  Future<List<EnrolledInternship>> syncMyInternships() async {
    try {
      final list = await repository.getMyInternships();
      for (final item in list) {
        enrolledInternshipIds.add(item.internshipId);
      }
      await _saveLearning();
      notifyListeners();
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<WorkspaceData> loadWorkspace(int internshipId) {
    return repository.getWorkspace(internshipId);
  }

  Future<TaskSubmission> submitTask({
    required int internshipId,
    required int moduleId,
    required String submissionLink,
    String? studentNotes,
  }) async {
    final sub = await repository.submitTask(
      internshipId: internshipId,
      moduleId: moduleId,
      submissionLink: submissionLink,
      studentNotes: studentNotes,
    );
    notifyListeners();
    return sub;
  }

  // ============================================================
  //  COURSE PROGRESS
  // ============================================================
  bool isLessonDone(PlaylistItem item) =>
      completedLessons.contains(item.key);

  int completedLessonCount(Course course) =>
      course.playlist.where((p) => completedLessons.contains(p.key)).length;

  double courseProgress(Course course) {
    final total = course.playlist.length;
    if (total == 0) return 0;
    return completedLessonCount(course) / total;
  }

  bool isCourseCompleted(Course course) {
    final list = course.playlist;
    return list.isNotEmpty &&
        list.every((p) => completedLessons.contains(p.key));
  }

  Future<void> setLessonDone(PlaylistItem item, bool done) async {
    if (done) {
      completedLessons.add(item.key);
    } else {
      completedLessons.remove(item.key);
    }
    await _saveLearning();
    notifyListeners();
  }

  Future<void> setLastLesson(Course course, PlaylistItem item) async {
    _lastLessonKey.remove(course.id);
    _lastLessonKey[course.id] = item.key;
    await _saveLearning();
    notifyListeners();
  }

  PlaylistItem? resumeLesson(Course course) {
    final list = course.playlist;
    if (list.isEmpty) return null;
    final last = _lastLessonKey[course.id];
    for (final p in list) {
      if (p.key == last) return p;
    }
    for (final p in list) {
      if (!completedLessons.contains(p.key)) return p;
    }
    return list.first;
  }

  Course? get continueCourse {
    final recent = _lastLessonKey.keys.toList().reversed.toList();
    for (final id in recent) {
      if (enrolledCourseIds.contains(id)) {
        final c = courseById(id);
        if (c != null) return c;
      }
    }
    final list = enrolledCourses;
    return list.isEmpty ? null : list.first;
  }

  // ============================================================
  //  INTERNSHIP PROGRESS
  // ============================================================
  String _weekKey(Internship internship, int week) =>
      '${internship.id}_$week';

  bool isWeekDone(Internship internship, int week) =>
      completedWeeks.contains(_weekKey(internship, week));

  int completedWeekCount(Internship internship) {
    int count = 0;
    for (int w = 1; w <= internship.weeks; w++) {
      if (isWeekDone(internship, w)) count++;
    }
    return count;
  }

  double internshipProgress(Internship internship) =>
      internship.weeks == 0
          ? 0
          : completedWeekCount(internship) / internship.weeks;

  Future<void> setWeekDone(
      Internship internship, int week, bool done) async {
    final key = _weekKey(internship, week);
    if (done) {
      completedWeeks.add(key);
    } else {
      completedWeeks.remove(key);
    }
    await _saveLearning();
    notifyListeners();
  }

  // ============================================================
  //  QUIZ & CERTIFICATE
  // ============================================================
  Future<List<QuizInfo>> loadQuizzes({int? internshipId, int? quizId}) {
    return repository.getQuizList(internshipId: internshipId, quizId: quizId);
  }

  Future<QuizSession> startQuizSession(int quizId) {
    return repository.startQuizSession(quizId);
  }

  Future<List<ApiQuizQuestion>> loadQuizQuestions(String sessionToken) {
    return repository.getQuizQuestions(sessionToken);
  }

  Future<void> saveQuizDraftAnswer({
    required String sessionToken,
    required int questionId,
    required String selectedOption,
    bool isReview = false,
  }) {
    return repository.saveQuizDraftAnswer(
      sessionToken: sessionToken,
      questionId: questionId,
      selectedOption: selectedOption,
      isReview: isReview,
    );
  }

  Future<QuizResult> submitQuiz({
    required String sessionToken,
    Map<int, String>? answers,
  }) {
    return repository.submitQuiz(
      sessionToken: sessionToken,
      answers: answers,
    );
  }

  Future<QuizResult> loadQuizResult(int attemptId) {
    return repository.getQuizResult(attemptId);
  }

  Future<void> logQuizViolation({
    required String sessionToken,
    String violationType = 'app_backgrounded',
  }) {
    return repository.logQuizViolation(
      sessionToken: sessionToken,
      violationType: violationType,
    );
  }

  List<QuizQuestion> quizFor(Course course) =>
      quizzes[course.id] ?? const [];

  CertificateRecord? certificateFor(String type, int itemId) {
    for (final c in certificates) {
      if (c.type == type && c.itemId == itemId) return c;
    }
    return null;
  }

  CertificateRecord? findCertificate(String id) {
    final wanted = id.trim().toUpperCase();
    for (final c in certificates) {
      if (c.id.toUpperCase() == wanted) return c;
    }
    return null;
  }

  Future<CertificateRecord> issueCertificate({
    required String type,
    required int itemId,
    required String title,
    int? scorePercent,
  }) async {
    final existing = certificateFor(type, itemId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final random = Random();
    String id;
    do {
      id = 'DV-${now.year}-${100000 + random.nextInt(900000)}';
    } while (findCertificate(id) != null);

    final record = CertificateRecord(
      id: id,
      type: type,
      itemId: itemId,
      title: title,
      studentName:
          (user?.name.isNotEmpty ?? false) ? user!.name : 'Student',
      date: now,
      scorePercent: scorePercent,
    );
    certificates.insert(0, record);
    await _saveLearning();
    notifyListeners();
    return record;
  }

  // ============================================================
  //  STUDENT DOCUMENTS (API / LOCAL)
  // ============================================================

  Future<List<CertificateRecord>> loadCertificates({bool forceRefresh = false}) async {
    if (isLoadingCertificates) return certificates;
    isLoadingCertificates = true;
    certificatesError = null;
    notifyListeners();
    try {
      final list = await repository.getCertificates();
      certificates
        ..clear()
        ..addAll(list);
      await _saveLearning();
      return certificates;
    } catch (e) {
      certificatesError = e.toString();
      return certificates;
    } finally {
      isLoadingCertificates = false;
      notifyListeners();
    }
  }

  Future<List<OfferLetterRecord>> loadOfferLetters({bool forceRefresh = false}) async {
    if (isLoadingOfferLetters) return offerLetters;
    isLoadingOfferLetters = true;
    offerLettersError = null;
    notifyListeners();
    try {
      final list = await repository.getOfferLetters();
      offerLetters
        ..clear()
        ..addAll(list);
      return offerLetters;
    } catch (e) {
      offerLettersError = e.toString();
      return offerLetters;
    } finally {
      isLoadingOfferLetters = false;
      notifyListeners();
    }
  }

  Future<List<PaymentRecord>> loadPaymentReceipts({bool forceRefresh = false}) async {
    if (isLoadingPayments) return payments;
    isLoadingPayments = true;
    paymentsError = null;
    notifyListeners();
    try {
      final list = await repository.getPaymentReceipts();
      payments
        ..clear()
        ..addAll(list);
      await _saveLearning();
      return payments;
    } catch (e) {
      paymentsError = e.toString();
      return payments;
    } finally {
      isLoadingPayments = false;
      notifyListeners();
    }
  }

  Future<void> loadAllStudentDocuments({bool forceRefresh = false}) async {
    await Future.wait([
      loadCertificates(forceRefresh: forceRefresh),
      loadOfferLetters(forceRefresh: forceRefresh),
      loadPaymentReceipts(forceRefresh: forceRefresh),
    ]);
  }

  // ============================================================
  //  SEARCH
  // ============================================================
  List<Course> searchCourses(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return courses
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }

  List<Internship> searchInternships(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return internships
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            i.domain.toLowerCase().contains(q))
        .toList();
  }
}
