// ============================================================
//  APP STATE — App ka "dimaag"
//
//  • Data load karna (courses, internships, home)
//  • Login / profile / logout
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
import '../data/models/payment.dart';
import '../data/models/quiz.dart';
import '../data/models/user_profile.dart';
import '../data/repository/app_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final AppRepository repository;

  // ---------- Phone me save hone wali keys ----------
  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kPhone = 'user_phone';
  static const String _kName = 'user_name';
  static const String _kEmail = 'user_email';
  static const String _kCollege = 'user_college';
  static const String _kCity = 'user_city';
  static const String _kEnrolledCourses = 'enrolled_courses';
  static const String _kEnrolledInternships = 'enrolled_internships';
  static const String _kAppliedInternships = 'applied_internships';
  static const String _kDoneLessons = 'done_lessons';
  static const String _kDoneWeeks = 'done_weeks';
  static const String _kLastLesson = 'last_lesson';
  static const String _kPayments = 'payments';
  static const String _kCertificates = 'certificates';

  // ---------- Padhai (phone me save hota hai) ----------
  final Set<int> enrolledCourseIds = <int>{};
  final Set<int> enrolledInternshipIds = <int>{};
  final Set<int> appliedInternshipIds = <int>{}; // Stipend internships jinme apply kiya
  final Set<String> completedLessons = <String>{}; // PlaylistItem.key
  final Set<String> completedWeeks = <String>{}; // "internshipId_week"
  final Map<int, String> _lastLessonKey = <int, String>{}; // courseId → lesson key
  final List<PaymentRecord> payments = <PaymentRecord>[]; // Naya sabse upar
  final List<CertificateRecord> certificates = <CertificateRecord>[]; // Naya sabse upar

  /// Aakhri enroll internship tha? (Meri Padhai pe sahi tab kholne ke liye)
  bool lastEnrollWasInternship = false;

  // ---------- Data ----------
  HomeData home = HomeData.empty;
  List<Course> courses = [];
  InternshipCatalog internshipCatalog = InternshipCatalog.empty;
  Map<int, List<QuizQuestion>> quizzes = {};
  List<Internship> get internships => internshipCatalog.internships;

  bool isLoading = true;
  String? errorMessage;

  // ---------- User ----------
  UserProfile? user;
  bool onboardingSeen = false;
  bool get isLoggedIn => user != null && user!.isComplete;

  // ---------- Courses screen ka selected filter ----------
  String courseFilter = 'All';

  // ============================================================
  //  START — Splash screen se ek baar chalta hai
  // ============================================================
  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    onboardingSeen = prefs.getBool(_kOnboardingSeen) ?? false;

    final String? phone = prefs.getString(_kPhone);
    if (phone != null) {
      user = UserProfile(
        phone: phone,
        name: prefs.getString(_kName) ?? '',
        email: prefs.getString(_kEmail) ?? '',
        college: prefs.getString(_kCollege) ?? '',
        city: prefs.getString(_kCity) ?? '',
      );
    }
    _loadLearning(prefs);
    await loadData();
  }

  /// Phone me save kiya hua enrollment / progress padhna
  void _loadLearning(SharedPreferences prefs) {
    Set<int> readIds(String key) =>
        (prefs.getStringList(key) ?? <String>[]).map(int.tryParse).whereType<int>().toSet();

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
    for (final String entry in prefs.getStringList(_kLastLesson) ?? <String>[]) {
      final List<String> parts = entry.split('|'); // "1|1_0_2"
      final int? courseId = parts.isNotEmpty ? int.tryParse(parts.first) : null;
      if (courseId != null && parts.length == 2) _lastLessonKey[courseId] = parts[1];
    }

    certificates.clear();
    for (final String text in prefs.getStringList(_kCertificates) ?? <String>[]) {
      try {
        certificates.add(CertificateRecord.fromJson(jsonDecode(text) as Map<String, dynamic>));
      } catch (_) {
        // Kharab record chhod do
      }
    }

    payments.clear();
    for (final String text in prefs.getStringList(_kPayments) ?? <String>[]) {
      try {
        payments.add(PaymentRecord.fromJson(jsonDecode(text) as Map<String, dynamic>));
      } catch (_) {
        // Kharab record chhod do
      }
    }
  }

  /// Enrollment / progress phone me save karna
  Future<void> _saveLearning() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ids(Set<int> set) => set.map((id) => id.toString()).toList();
    await prefs.setStringList(_kEnrolledCourses, ids(enrolledCourseIds));
    await prefs.setStringList(_kEnrolledInternships, ids(enrolledInternshipIds));
    await prefs.setStringList(_kAppliedInternships, ids(appliedInternshipIds));
    await prefs.setStringList(_kDoneLessons, completedLessons.toList());
    await prefs.setStringList(_kDoneWeeks, completedWeeks.toList());
    await prefs.setStringList(
      _kLastLesson,
      _lastLessonKey.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
    await prefs.setStringList(
      _kPayments,
      payments.map((p) => jsonEncode(p.toJson())).toList(),
    );
    await prefs.setStringList(
      _kCertificates,
      certificates.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  /// Courses, internships aur home data load karo
  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final List<Object> results = await Future.wait<Object>([
        repository.getHomeData(),
        repository.getCourses(),
        repository.getInternships(),
        repository.getQuizzes(),
      ]);
      home = results[0] as HomeData;
      courses = results[1] as List<Course>;
      internshipCatalog = results[2] as InternshipCatalog;
      quizzes = results[3] as Map<int, List<QuizQuestion>>;
    } catch (e) {
      errorMessage = 'Data load nahi ho paya. Internet check karke dobara try karein.';
      debugPrint('loadData error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // ============================================================
  //  LOGIN / PROFILE
  // ============================================================
  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
  }

  /// OTP verify hone ke baad. Agar wahi number pehle se save hai to
  /// purani profile rakhte hain, warna nayi khaali profile.
  Future<void> loginWithPhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user == null || user!.phone != phone) {
      user = UserProfile(phone: phone, name: '', email: '', college: '', city: '');
    }
    await prefs.setString(_kPhone, phone);
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String college,
    required String city,
  }) async {
    final UserProfile current = user ??
        const UserProfile(phone: '', name: '', email: '', college: '', city: '');
    user = current.copyWith(
      name: name.trim(),
      email: email.trim(),
      college: college.trim(),
      city: city.trim(),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, user!.name);
    await prefs.setString(_kEmail, user!.email);
    await prefs.setString(_kCollege, user!.college);
    await prefs.setString(_kCity, user!.city);
    notifyListeners();
  }

  /// Logout: user ki details aur uski padhai ka data phone se hata do
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (final String key in [
      _kPhone, _kName, _kEmail, _kCollege, _kCity,
      _kEnrolledCourses, _kEnrolledInternships, _kAppliedInternships,
      _kDoneLessons, _kDoneWeeks, _kLastLesson, _kPayments, _kCertificates,
    ]) {
      await prefs.remove(key);
    }
    user = null;
    enrolledCourseIds.clear();
    enrolledInternshipIds.clear();
    appliedInternshipIds.clear();
    completedLessons.clear();
    completedWeeks.clear();
    _lastLessonKey.clear();
    payments.clear();
    certificates.clear();
    notifyListeners();
  }

  // ============================================================
  //  COURSES
  // ============================================================

  /// courses.json me jitni categories hain (same order me)
  List<String> get courseCategories {
    final List<String> result = [];
    for (final Course c in courses) {
      if (!result.contains(c.category)) result.add(c.category);
    }
    return result;
  }

  /// Courses screen pe filter ke hisaab se list
  List<Course> get filteredCourses {
    if (courseFilter == 'All') return courses;
    return courses.where((c) => c.category == courseFilter).toList();
  }

  void setCourseFilter(String category) {
    courseFilter = category;
    notifyListeners();
  }

  /// Home pe "Popular Courses" — sabse zyada students wale 6
  List<Course> get popularCourses {
    final List<Course> sorted = List<Course>.of(courses)
      ..sort((a, b) => b.students.compareTo(a.students));
    return sorted.take(6).toList();
  }

  // ============================================================
  //  INTERNSHIPS
  // ============================================================
  List<Internship> internshipsOfType(String type) =>
      internships.where((i) => i.type == type).toList();

  /// Ek type (e.g. paid) me kaun-kaun se domains hain
  List<String> domainsForType(String type) {
    final List<String> result = [];
    for (final Internship i in internshipsOfType(type)) {
      if (!result.contains(i.domain)) result.add(i.domain);
    }
    return result;
  }

  /// Home pe dikhane ke liye har type ki ek-ek internship
  List<Internship> get featuredInternships {
    final List<Internship> result = [];
    for (final String type in Internship.allTypes) {
      final List<Internship> ofType = internshipsOfType(type);
      if (ofType.isNotEmpty) result.add(ofType.first);
    }
    return result;
  }

  Course? courseById(int id) {
    for (final Course c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  Internship? internshipById(int id) {
    for (final Internship i in internships) {
      if (i.id == id) return i;
    }
    return null;
  }

  // ============================================================
  //  ENROLL / PAYMENT
  // ============================================================
  bool isCourseEnrolled(int id) => enrolledCourseIds.contains(id);
  bool isInternshipEnrolled(int id) => enrolledInternshipIds.contains(id);
  bool hasApplied(int internshipId) => appliedInternshipIds.contains(internshipId);

  /// Enroll kiye hue courses (naya sabse upar)
  List<Course> get enrolledCourses =>
      enrolledCourseIds.map(courseById).whereType<Course>().toList().reversed.toList();

  /// Enroll ki hui internships (naya sabse upar)
  List<Internship> get enrolledInternships => enrolledInternshipIds
      .map(internshipById)
      .whereType<Internship>()
      .toList()
      .reversed
      .toList();

  /// Payment ke baad: receipt banao + enroll karo.
  /// DEMO: asli paisa nahi katta. Backend me yahan Razorpay verify hoga.
  Future<PaymentRecord> completePurchase(PurchaseItem item, String method) async {
    final DateTime now = DateTime.now();
    final PaymentRecord record = PaymentRecord(
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

  /// Free internship (bina payment)
  Future<void> enrollFreeInternship(Internship internship) async {
    enrolledInternshipIds.add(internship.id);
    lastEnrollWasInternship = true;
    await _saveLearning();
    notifyListeners();
  }

  /// Stipend internship ke liye application
  Future<void> applyForInternship(Internship internship) async {
    appliedInternshipIds.add(internship.id);
    await _saveLearning();
    notifyListeners();
  }

  // ============================================================
  //  COURSE PROGRESS (lessons)
  // ============================================================
  bool isLessonDone(PlaylistItem item) => completedLessons.contains(item.key);

  int completedLessonCount(Course course) =>
      course.playlist.where((p) => completedLessons.contains(p.key)).length;

  /// 0.0 se 1.0 tak
  double courseProgress(Course course) {
    final int total = course.playlist.length;
    if (total == 0) return 0;
    return completedLessonCount(course) / total;
  }

  bool isCourseCompleted(Course course) {
    final List<PlaylistItem> list = course.playlist;
    return list.isNotEmpty && list.every((p) => completedLessons.contains(p.key));
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

  /// Aakhri baar kaunsa lesson khola tha (Resume ke liye)
  Future<void> setLastLesson(Course course, PlaylistItem item) async {
    _lastLessonKey.remove(course.id); // Hata ke dobara daalne se yeh "latest" ban jata hai
    _lastLessonKey[course.id] = item.key;
    await _saveLearning();
    notifyListeners();
  }

  /// Resume pe kaunsa lesson khule: aakhri khola hua → pehla adhoora → pehla
  PlaylistItem? resumeLesson(Course course) {
    final List<PlaylistItem> list = course.playlist;
    if (list.isEmpty) return null;
    final String? last = _lastLessonKey[course.id];
    for (final PlaylistItem p in list) {
      if (p.key == last) return p;
    }
    for (final PlaylistItem p in list) {
      if (!completedLessons.contains(p.key)) return p;
    }
    return list.first;
  }

  /// Home ke "Continue Learning" ke liye — sabse haal me padha course
  Course? get continueCourse {
    final List<int> recent = _lastLessonKey.keys.toList().reversed.toList();
    for (final int id in recent) {
      if (enrolledCourseIds.contains(id)) {
        final Course? c = courseById(id);
        if (c != null) return c;
      }
    }
    final List<Course> list = enrolledCourses;
    return list.isEmpty ? null : list.first;
  }

  // ============================================================
  //  INTERNSHIP PROGRESS (weeks)
  // ============================================================
  String _weekKey(Internship internship, int week) => '${internship.id}_$week';

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
      internship.weeks == 0 ? 0 : completedWeekCount(internship) / internship.weeks;

  Future<void> setWeekDone(Internship internship, int week, bool done) async {
    final String key = _weekKey(internship, week);
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

  /// Course ke quiz sawaal (quizzes.json se). Khaali = quiz nahi bana
  List<QuizQuestion> quizFor(Course course) => quizzes[course.id] ?? const [];

  /// Is course / internship ka certificate (agar mil chuka hai)
  CertificateRecord? certificateFor(String type, int itemId) {
    for (final CertificateRecord c in certificates) {
      if (c.type == type && c.itemId == itemId) return c;
    }
    return null;
  }

  /// Certificate ID se dhoondo (Verify screen)
  CertificateRecord? findCertificate(String id) {
    final String wanted = id.trim().toUpperCase();
    for (final CertificateRecord c in certificates) {
      if (c.id.toUpperCase() == wanted) return c;
    }
    return null;
  }

  /// Naya certificate banao (pehle se hai to wahi wapas).
  /// DEMO: phone me banta hai. Backend me server banayega aur ID dega.
  Future<CertificateRecord> issueCertificate({
    required String type,
    required int itemId,
    required String title,
    int? scorePercent,
  }) async {
    final CertificateRecord? existing = certificateFor(type, itemId);
    if (existing != null) return existing;

    final DateTime now = DateTime.now();
    final Random random = Random();
    String id;
    do {
      id = 'DV-${now.year}-${100000 + random.nextInt(900000)}';
    } while (findCertificate(id) != null);

    final CertificateRecord record = CertificateRecord(
      id: id,
      type: type,
      itemId: itemId,
      title: title,
      studentName: (user?.name.isNotEmpty ?? false) ? user!.name : 'Student',
      date: now,
      scorePercent: scorePercent,
    );
    certificates.insert(0, record);
    await _saveLearning();
    notifyListeners();
    return record;
  }

  // ============================================================
  //  SEARCH
  // ============================================================
  List<Course> searchCourses(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return courses
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }

  List<Internship> searchInternships(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return internships
        .where((i) => i.title.toLowerCase().contains(q) || i.domain.toLowerCase().contains(q))
        .toList();
  }
}
