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
