// ============================================================
//  QUIZ MODEL — Ek sawaal, uske 4 options aur sahi jawab
//  Data: assets/data/quizzes.json
// ============================================================

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer; // Sahi option ka number (0 se shuru)

  const QuizQuestion({required this.question, required this.options, required this.answer});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> opts = (json['options'] as List<dynamic>?) ?? <dynamic>[];
    return QuizQuestion(
      question: (json['question'] as String?) ?? '',
      options: opts.map((o) => o.toString()).toList(),
      answer: (json['answer'] as num?)?.toInt() ?? 0,
    );
  }

  /// quizzes.json padh kar: courseId → sawaalon ki list
  static Map<int, List<QuizQuestion>> catalogFromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> raw = (json['quizzes'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<int, List<QuizQuestion>> result = {};
    raw.forEach((key, value) {
      final int? courseId = int.tryParse(key);
      if (courseId == null || value is! List) return;
      result[courseId] =
          value.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>)).toList();
    });
    return result;
  }
}

// ────────────────────────────────────────────────────────────
//  BACKEND API QUIZ MODELS
//  Matches PHP endpoints under /mobile-api/quiz/
// ────────────────────────────────────────────────────────────

class QuizAttemptSummary {
  final int attemptId;
  final int scoreObtained;
  final int totalScore;
  final double percentage;
  final String status; // 'passed' | 'failed'
  final String? completedAt;

  const QuizAttemptSummary({
    required this.attemptId,
    required this.scoreObtained,
    required this.totalScore,
    required this.percentage,
    required this.status,
    this.completedAt,
  });

  bool get isPassed => status == 'passed';

  factory QuizAttemptSummary.fromJson(Map<String, dynamic> json) {
    return QuizAttemptSummary(
      attemptId: json['attempt_id'] as int? ?? 0,
      scoreObtained: json['score_obtained'] as int? ?? 0,
      totalScore: json['total_score'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'failed',
      completedAt: json['completed_at'] as String?,
    );
  }
}

class QuizInfo {
  final int id;
  final int internshipId;
  final String title;
  final int timeLimitMinutes;
  final int passingScore;
  final int maxAttempts;
  final int totalQuestions;
  final int totalMarks;
  final int attemptsUsed;
  final bool canAttempt;
  final bool isPassed;
  final double highestScorePercent;
  final List<QuizAttemptSummary> attemptsHistory;

  const QuizInfo({
    required this.id,
    required this.internshipId,
    required this.title,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.maxAttempts,
    required this.totalQuestions,
    required this.totalMarks,
    required this.attemptsUsed,
    required this.canAttempt,
    required this.isPassed,
    required this.highestScorePercent,
    required this.attemptsHistory,
  });

  int get attemptsRemaining => (maxAttempts - attemptsUsed).clamp(0, maxAttempts);

  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['attempts_history'] as List<dynamic>? ?? [];
    return QuizInfo(
      id: json['id'] as int? ?? 0,
      internshipId: json['internship_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Assessment',
      timeLimitMinutes: json['time_limit_minutes'] as int? ?? 30,
      passingScore: json['passing_score'] as int? ?? 70,
      maxAttempts: json['max_attempts'] as int? ?? 2,
      totalQuestions: json['total_questions'] as int? ?? 0,
      totalMarks: json['total_marks'] as int? ?? 0,
      attemptsUsed: json['attempts_used'] as int? ?? 0,
      canAttempt: json['can_attempt'] as bool? ?? false,
      isPassed: json['is_passed'] as bool? ?? false,
      highestScorePercent: (json['highest_score_percent'] as num?)?.toDouble() ?? 0.0,
      attemptsHistory: rawHistory
          .map((a) => QuizAttemptSummary.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizSession {
  final String sessionToken;
  final int quizId;
  final String quizTitle;
  final int durationMinutes;
  final String? expiresAt;
  final int expiresInSeconds;

  const QuizSession({
    required this.sessionToken,
    required this.quizId,
    required this.quizTitle,
    required this.durationMinutes,
    this.expiresAt,
    required this.expiresInSeconds,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      sessionToken: json['session_token'] as String? ?? '',
      quizId: json['quiz_id'] as int? ?? 0,
      quizTitle: json['quiz_title'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ??
          (json['expires_in_seconds'] != null
              ? (json['expires_in_seconds'] as int) ~/ 60
              : 30),
      expiresAt: json['expires_at'] as String?,
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 1800,
    );
  }
}

class ApiQuizQuestion {
  final int questionNumber;
  final int questionId;
  final String questionText;
  final Map<String, String> options;
  final int marks;
  String? selectedOption;
  bool isReview;

  ApiQuizQuestion({
    required this.questionNumber,
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.marks,
    this.selectedOption,
    this.isReview = false,
  });

  factory ApiQuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOpts = json['options'] as Map<String, dynamic>? ?? {};
    final Map<String, String> opts = {};
    rawOpts.forEach((k, v) => opts[k] = v.toString());

    return ApiQuizQuestion(
      questionNumber: json['question_number'] as int? ?? 1,
      questionId: json['question_id'] as int? ?? 0,
      questionText: json['question_text'] as String? ?? '',
      options: opts,
      marks: json['marks'] as int? ?? 1,
      selectedOption: json['selected_option'] as String?,
      isReview: json['is_review'] as bool? ?? false,
    );
  }
}

class QuizQuestionReview {
  final int questionNumber;
  final int questionId;
  final String questionText;
  final Map<String, String> options;
  final String? selectedOption;
  final String correctOption;
  final bool isCorrect;
  final int marksAwarded;
  final int maxMarks;

  const QuizQuestionReview({
    required this.questionNumber,
    required this.questionId,
    required this.questionText,
    required this.options,
    this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    required this.marksAwarded,
    required this.maxMarks,
  });

  factory QuizQuestionReview.fromJson(Map<String, dynamic> json) {
    final rawOpts = json['options'] as Map<String, dynamic>? ?? {};
    final Map<String, String> opts = {};
    rawOpts.forEach((k, v) => opts[k] = v.toString());

    return QuizQuestionReview(
      questionNumber: json['question_number'] as int? ?? 1,
      questionId: json['question_id'] as int? ?? 0,
      questionText: json['question_text'] as String? ?? '',
      options: opts,
      selectedOption: json['selected_option'] as String?,
      correctOption: json['correct_option'] as String? ?? 'A',
      isCorrect: json['is_correct'] as bool? ?? false,
      marksAwarded: json['marks_awarded'] as int? ?? 0,
      maxMarks: json['max_marks'] as int? ?? 1,
    );
  }
}

class QuizResult {
  final int attemptId;
  final int quizId;
  final String quizTitle;
  final int scoreObtained;
  final int totalScore;
  final double percentage;
  final int passingScore;
  final String status;
  final bool isPassed;
  final String? completedAt;
  final List<QuizQuestionReview> breakdown;

  const QuizResult({
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    required this.scoreObtained,
    required this.totalScore,
    required this.percentage,
    required this.passingScore,
    required this.status,
    required this.isPassed,
    this.completedAt,
    this.breakdown = const [],
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? json;
    final rawBreakdown = (json['breakdown'] as List<dynamic>?) ?? [];

    return QuizResult(
      attemptId: summary['attempt_id'] as int? ?? summary['id'] as int? ?? 0,
      quizId: summary['quiz_id'] as int? ?? 0,
      quizTitle: summary['quiz_title'] as String? ?? '',
      scoreObtained: summary['score_obtained'] as int? ?? 0,
      totalScore: summary['total_score'] as int? ?? 0,
      percentage: (summary['percentage'] as num?)?.toDouble() ?? 0.0,
      passingScore: summary['passing_score'] as int? ?? 70,
      status: summary['status'] as String? ?? 'failed',
      isPassed: summary['is_passed'] as bool? ?? (summary['status'] == 'passed'),
      completedAt: summary['completed_at'] as String?,
      breakdown: rawBreakdown
          .map((b) => QuizQuestionReview.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}
