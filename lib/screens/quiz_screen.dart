// ============================================================
//  QUIZ SCREEN — Course ka final quiz
//
//  • Sawaal: assets/data/quizzes.json (course id ke hisaab se)
//  • Pass hone ke liye: AppConfig.quizPassPercent (abhi 60%)
//  • Pass → "Get Certificate" → certificate ban jata hai
//  • Fail → "Retry Quiz" (jitni baar chaho)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/models/course.dart';
import '../data/models/quiz.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import 'certificate_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.course});

  final Course course;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  late final List<QuizQuestion> _questions = context.read<AppState>().quizFor(widget.course);
  late List<int?> _answers = List<int?>.filled(_questions.length, null);
  int _index = 0;
  bool _finished = false;
  bool _issuing = false;

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].answer) count++;
    }
    return count;
  }

  int get _percent =>
      _questions.isEmpty ? 0 : ((_correctCount * 100) / _questions.length).round();

  bool get _passed => _percent >= AppConfig.quizPassPercent;

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() => _index++);
    } else {
      setState(() => _finished = true);
    }
  }

  void _retry() {
    setState(() {
      _answers = List<int?>.filled(_questions.length, null);
      _index = 0;
      _finished = false;
    });
  }

  Future<void> _getCertificate() async {
    setState(() => _issuing = true);
    final CertificateRecord record = await context.read<AppState>().issueCertificate(
          type: 'course',
          itemId: widget.course.id,
          title: widget.course.title,
          scorePercent: _percent,
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => CertificateScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Quiz')),
        body: const Center(
          child: EmptyState(
            icon: Icons.quiz_outlined,
            title: 'Quiz jald aa raha hai',
            message: 'Is course ke quiz sawaal abhi taiyaar ho rahe hain.',
          ),
        ),
      );
    }
    return _finished ? _buildResult(context) : _buildQuestion(context);
  }

  // ============================================================
  //  Ek sawaal wala page
  // ============================================================
  Widget _buildQuestion(BuildContext context) {
    final QuizQuestion q = _questions[_index];
    final bool isLast = _index == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.course.title} — Quiz', maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Text('Question ${_index + 1} of ${_questions.length}', style: AppText.small),
              const Spacer(),
              Text('Pass: ${AppConfig.quizPassPercent}%', style: AppText.small),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: const Color(0xFFE7E5E4),
            ),
          ),
          const SizedBox(height: 28),
          Text(q.question, style: AppText.h2.copyWith(fontSize: 19)),
          const SizedBox(height: 20),
          for (int i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                letter: i < _letters.length ? _letters[i] : '${i + 1}',
                text: q.options[i],
                selected: _answers[_index] == i,
                onTap: () => setState(() => _answers[_index] = i),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (_index > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _index--),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _answers[_index] == null ? null : _next,
                  child: Text(isLast ? 'Submit Quiz' : 'Next Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  Result page (score + review)
  // ============================================================
  Widget _buildResult(BuildContext context) {
    final Color color = _passed ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ---------- Score ring ----------
          Center(
            child: SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _percent / 100,
                    strokeWidth: 10,
                    color: color,
                    backgroundColor: _passed ? AppColors.successLight : const Color(0xFFFEE2E2),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_correctCount/${_questions.length}',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                        ),
                        Text('$_percent%', style: AppText.small),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _passed ? 'Passed! 🎉' : 'Pass nahi hua',
            textAlign: TextAlign.center,
            style: AppText.h1.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Text(
            _passed
                ? 'Badhai ho! Aapka certificate taiyaar hai.'
                : 'Pass hone ke liye ${AppConfig.quizPassPercent}% chahiye. Lessons dobara dekh kar phir try karein.',
            textAlign: TextAlign.center,
            style: AppText.muted.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 20),

          // ---------- Buttons ----------
          if (_passed)
            ElevatedButton.icon(
              onPressed: _issuing ? null : _getCertificate,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('Get Certificate'),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Quiz'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Lessons dobara dekhein'),
            ),
          ],

          // ---------- Review ----------
          const SizedBox(height: 28),
          const Text('Aapke jawab', style: AppText.title),
          const SizedBox(height: 10),
          for (int i = 0; i < _questions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewCard(
                number: i + 1,
                question: _questions[i],
                chosen: _answers[i],
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : AppColors.surface,
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: selected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.number, required this.question, required this.chosen});

  final int number;
  final QuizQuestion question;
  final int? chosen;

  @override
  Widget build(BuildContext context) {
    final bool right = chosen == question.answer;
    final String yours =
        chosen == null ? '—' : question.options[chosen!];
    final String correct = question.options[question.answer];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                right ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: right ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('$number. ${question.question}', style: AppText.cardTitle)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Aapka jawab: $yours',
            style: TextStyle(fontSize: 13, color: right ? AppColors.success : AppColors.error),
          ),
          if (!right)
            Text(
              'Sahi jawab: $correct',
              style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
