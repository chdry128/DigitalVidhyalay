// ============================================================
//  QUIZ SCREEN — Course & Internship Assessment
//  Connected to local PHP backend:
//   - GET  /mobile-api/quiz/list.php
//   - POST /mobile-api/quiz/start-session.php
//   - GET  /mobile-api/quiz/questions.php
//   - POST /mobile-api/quiz/save-draft.php
//   - POST /mobile-api/quiz/submit.php
//   - GET  /mobile-api/quiz/result.php
//   - POST /mobile-api/quiz/log-violation.php
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/models/course.dart';
import '../data/models/quiz.dart';
import '../data/repository/api_client.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import 'certificate_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.course,
    this.quizId,
    this.internshipId,
    this.title,
  });

  final Course? course;
  final int? quizId;
  final int? internshipId;
  final String? title;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ── Mode determination ─────────────────────────────────────
  bool get _isMockMode => AppConfig.useMockData;

  // ── API Quiz State ─────────────────────────────────────────
  bool _isLoading = true;
  String? _errorMessage;
  QuizInfo? _quizInfo;

  QuizSession? _activeSession;
  List<ApiQuizQuestion> _apiQuestions = [];
  int _currentIndex = 0;
  bool _isTakingQuiz = false;
  bool _isSubmitting = false;

  // Timer state
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  // Final submission result
  QuizResult? _quizResult;

  // ── Mock Quiz State (Fallback) ─────────────────────────────
  List<QuizQuestion> _mockQuestions = [];
  List<int?> _mockAnswers = [];
  bool _mockFinished = false;
  bool _issuingCertificate = false;

  @override
  void initState() {
    super.initState();
    if (_isMockMode) {
      _initMockMode();
    } else {
      _initApiMode();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  //  MOCK MODE FLOW
  // ────────────────────────────────────────────────────────────
  void _initMockMode() {
    if (widget.course != null) {
      _mockQuestions = context.read<AppState>().quizFor(widget.course!);
    }
    _mockAnswers = List<int?>.filled(_mockQuestions.length, null);
    _isLoading = false;
  }

  int get _mockCorrectCount {
    int count = 0;
    for (int i = 0; i < _mockQuestions.length; i++) {
      if (_mockAnswers[i] == _mockQuestions[i].answer) count++;
    }
    return count;
  }

  int get _mockPercent => _mockQuestions.isEmpty
      ? 0
      : ((_mockCorrectCount * 100) / _mockQuestions.length).round();

  bool get _mockPassed => _mockPercent >= AppConfig.quizPassPercent;

  // ────────────────────────────────────────────────────────────
  //  API MODE FLOW
  // ────────────────────────────────────────────────────────────
  Future<void> _initApiMode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final state = context.read<AppState>();
      final int? qId = widget.quizId;
      final int? iId = widget.internshipId ?? widget.course?.id;

      final list = await state.loadQuizzes(quizId: qId, internshipId: iId);
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _quizInfo = list.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startApiQuiz() async {
    final qz = _quizInfo;
    if (qz == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final state = context.read<AppState>();
      // 1. Start or resume session
      final session = await state.startQuizSession(qz.id);
      // 2. Fetch questions for session
      final questions = await state.loadQuizQuestions(session.sessionToken);

      if (mounted) {
        setState(() {
          _activeSession = session;
          _apiQuestions = questions;
          _currentIndex = 0;
          _secondsRemaining = session.expiresInSeconds;
          _isTakingQuiz = true;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        _autoSubmitOnTimeout();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _autoSubmitOnTimeout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.error,
        content: Text("Time's up! Submitting your answers automatically..."),
      ),
    );
    _submitApiQuiz();
  }

  Future<void> _onSelectOption(String optionLetter) async {
    if (_apiQuestions.isEmpty) return;
    final currentQ = _apiQuestions[_currentIndex];

    setState(() {
      currentQ.selectedOption = optionLetter;
    });

    // Save draft in background
    final session = _activeSession;
    if (session != null) {
      try {
        await context.read<AppState>().saveQuizDraftAnswer(
              sessionToken: session.sessionToken,
              questionId: currentQ.questionId,
              selectedOption: optionLetter,
            );
      } catch (_) {
        // Draft save is best-effort; submission will bundle all answers
      }
    }
  }

  Future<void> _confirmSubmit() async {
    final int answered =
        _apiQuestions.where((q) => q.selectedOption != null).length;
    final int total = _apiQuestions.length;

    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Submit Assessment?'),
        content: Text(
          'You have answered $answered of $total questions.\n\nOnce submitted, your answers will be evaluated and recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Review Answers'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      _submitApiQuiz();
    }
  }

  Future<void> _submitApiQuiz() async {
    final session = _activeSession;
    if (session == null || _isSubmitting) return;

    _countdownTimer?.cancel();
    setState(() => _isSubmitting = true);

    try {
      final state = context.read<AppState>();
      // Collect answers map
      final Map<int, String> answersMap = {};
      for (final q in _apiQuestions) {
        if (q.selectedOption != null) {
          answersMap[q.questionId] = q.selectedOption!;
        }
      }

      final result = await state.submitQuiz(
        sessionToken: session.sessionToken,
        answers: answersMap,
      );

      // Load full review with questions breakdown
      QuizResult detailedResult = result;
      try {
        detailedResult = await state.loadQuizResult(result.attemptId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _quizResult = detailedResult;
          _isTakingQuiz = false;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              e is ApiException ? e.message : 'Submission failed: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _claimCertificate() async {
    setState(() => _issuingCertificate = true);
    final itemId = widget.course?.id ?? widget.internshipId ?? _quizInfo?.id ?? 1;
    final itemTitle = widget.title ?? widget.course?.title ?? _quizInfo?.title ?? 'Assessment';
    final type = widget.course != null ? 'course' : 'internship';

    final score = _quizResult?.percentage.round() ?? _mockPercent;

    final CertificateRecord record = await context.read<AppState>().issueCertificate(
          type: type,
          itemId: itemId,
          title: itemTitle,
          scorePercent: score,
        );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CertificateScreen(record: record),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ────────────────────────────────────────────────────────────
  //  BUILD DISPATCHER
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Assessment')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 14),
              Text('Loading assessment...', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    if (_isMockMode) {
      if (_mockQuestions.isEmpty) {
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
      return _mockFinished ? _buildMockResult(context) : _buildMockQuestion(context);
    }

    // API Mode
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Assessment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
                const SizedBox(height: 12),
                const Text('Assessment Error', style: AppText.h2),
                const SizedBox(height: 8),
                Text(_errorMessage!, textAlign: TextAlign.center, style: AppText.small),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _initApiMode,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quizResult != null) {
      return _buildApiResult(context);
    }

    if (_isTakingQuiz) {
      return _buildApiQuestion(context);
    }

    return _buildPreQuizOverview(context);
  }

  // ────────────────────────────────────────────────────────────
  //  API MODE: PRE-QUIZ OVERVIEW
  // ────────────────────────────────────────────────────────────
  Widget _buildPreQuizOverview(BuildContext context) {
    final qz = _quizInfo;
    if (qz == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Assessment')),
        body: const Center(
          child: EmptyState(
            icon: Icons.quiz_outlined,
            title: 'No Assessment Found',
            message: 'There are no active assessments configured for this program.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(qz.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Header Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: qz.isPassed ? AppColors.successLight : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    qz.isPassed ? 'PASSED ✓' : 'FINAL ASSESSMENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: qz.isPassed ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(qz.title, style: AppText.h2),
                const SizedBox(height: 6),
                const Text(
                  'Proctored assessment covering all program topics. Please ensure a stable internet connection.',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Assessment Metrics Grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.schedule_rounded,
                  label: 'Time Limit',
                  value: '${qz.timeLimitMinutes} Mins',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.percent_rounded,
                  label: 'Passing Score',
                  value: '${qz.passingScore}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Questions',
                  value: '${qz.totalQuestions}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.repeat_rounded,
                  label: 'Attempts Left',
                  value: '${qz.attemptsRemaining} of ${qz.maxAttempts}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Previous Attempts History
          if (qz.attemptsHistory.isNotEmpty) ...[
            const Text('Previous Attempts', style: AppText.title),
            const SizedBox(height: 8),
            for (final att in qz.attemptsHistory)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        att.isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: att.isPassed ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Score: ${att.scoreObtained}/${att.totalScore} (${att.percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      Text(
                        att.completedAt ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Rules List
          const AppCard(
            color: Color(0xFFF9FAFB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: AppColors.navy),
                    SizedBox(width: 6),
                    Text('Assessment Rules', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),
                _RuleItem(text: 'Timer starts as soon as you tap "Start Assessment".'),
                _RuleItem(text: 'Answers are auto-saved as you select them.'),
                _RuleItem(text: 'You cannot pause or restart once the session begins.'),
                _RuleItem(text: 'Exceeding the time limit will auto-submit answered questions.'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          if (qz.isPassed)
            ElevatedButton.icon(
              onPressed: _claimCertificate,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('View / Claim Certificate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else if (!qz.canAttempt)
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Maximum Attempts Reached'),
            )
          else
            ElevatedButton.icon(
              onPressed: _startApiQuiz,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Assessment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  API MODE: LIVE QUESTION SCREEN
  // ────────────────────────────────────────────────────────────
  Widget _buildApiQuestion(BuildContext context) {
    if (_apiQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final ApiQuizQuestion q = _apiQuestions[_currentIndex];
    final bool isLast = _currentIndex == _apiQuestions.length - 1;
    final bool isLowTime = _secondsRemaining < 300; // < 5 mins

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool? leave = await showDialog<bool>(
          context: context,
          builder: (dCtx) => AlertDialog(
            title: const Text('Leave Assessment?'),
            content: const Text(
              'Your timer is still running in the background. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('Stay')),
              TextButton(onPressed: () => Navigator.of(dCtx).pop(true), child: const Text('Leave')),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_activeSession?.quizTitle ?? 'Assessment', maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            // Timer Badge
            Container(
              margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLowTime ? const Color(0xFFFEE2E2) : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLowTime ? AppColors.error : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 15,
                    color: isLowTime ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isLowTime ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _isSubmitting
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 14),
                    Text('Evaluating your assessment...', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Progress Row
                  Row(
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${_apiQuestions.length}',
                        style: AppText.small.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text('Marks: ${q.marks}', style: AppText.small),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _apiQuestions.length,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: const Color(0xFFE7E5E4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Text
                  Text(q.questionText, style: AppText.h2.copyWith(fontSize: 18, height: 1.35)),
                  const SizedBox(height: 20),

                  // Options List
                  for (final entry in q.options.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionTile(
                        letter: entry.key,
                        text: entry.value,
                        selected: q.selectedOption == entry.key,
                        onTap: () => _onSelectOption(entry.key),
                      ),
                    ),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                if (_currentIndex > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentIndex--),
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _confirmSubmit();
                      } else {
                        setState(() => _currentIndex++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isLast ? 'Submit Assessment' : 'Next Question'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  API MODE: RESULT SCREEN
  // ────────────────────────────────────────────────────────────
  Widget _buildApiResult(BuildContext context) {
    final res = _quizResult!;
    final bool passed = res.isPassed;
    final Color color = passed ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Circular Score Ring
          Center(
            child: SizedBox(
              width: 136,
              height: 136,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (res.percentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    color: color,
                    backgroundColor: passed ? AppColors.successLight : const Color(0xFFFEE2E2),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${res.scoreObtained}/${res.totalScore}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${res.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            passed ? 'Assessment Passed! 🎉' : 'Assessment Not Passed',
            textAlign: TextAlign.center,
            style: AppText.h1.copyWith(color: color, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            passed
                ? 'Congratulations! You met the passing criteria (${res.passingScore}%). Your certificate is unlocked.'
                : 'You scored ${res.percentage.toStringAsFixed(1)}%. Minimum passing score is ${res.passingScore}%.',
            textAlign: TextAlign.center,
            style: AppText.small,
          ),
          const SizedBox(height: 20),

          // Action Buttons
          if (passed)
            ElevatedButton.icon(
              onPressed: _issuingCertificate ? null : _claimCertificate,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('View / Claim Certificate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _quizResult = null;
                  _isTakingQuiz = false;
                });
                _initApiMode();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Back to Assessment Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],

          // Question Breakdown Review
          if (res.breakdown.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text('Question Breakdown', style: AppText.title),
            const SizedBox(height: 10),
            for (final rev in res.breakdown)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            rev.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: rev.isCorrect ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${rev.questionNumber}. ${rev.questionText}',
                              style: AppText.cardTitle.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${rev.selectedOption ?? 'Not Answered'}${rev.selectedOption != null && rev.options.containsKey(rev.selectedOption!) ? ' — ${rev.options[rev.selectedOption!]}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: rev.isCorrect ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!rev.isCorrect) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Correct Answer: ${rev.correctOption}${rev.options.containsKey(rev.correctOption) ? ' — ${rev.options[rev.correctOption]}' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  MOCK MODE: QUESTION & RESULT
  // ────────────────────────────────────────────────────────────
  Widget _buildMockQuestion(BuildContext context) {
    final QuizQuestion q = _mockQuestions[_currentIndex];
    final bool isLast = _currentIndex == _mockQuestions.length - 1;
    final List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.course?.title ?? 'Quiz'} — Demo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Text('Question ${_currentIndex + 1} of ${_mockQuestions.length}', style: AppText.small),
              const Spacer(),
              const Text('Pass: ${AppConfig.quizPassPercent}%', style: AppText.small),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _mockQuestions.length,
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
                letter: i < letters.length ? letters[i] : '${i + 1}',
                text: q.options[i],
                selected: _mockAnswers[_currentIndex] == i,
                onTap: () => setState(() => _mockAnswers[_currentIndex] = i),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (_currentIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _mockAnswers[_currentIndex] == null
                      ? null
                      : () {
                          if (isLast) {
                            setState(() => _mockFinished = true);
                          } else {
                            setState(() => _currentIndex++);
                          }
                        },
                  child: Text(isLast ? 'Submit Quiz' : 'Next Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockResult(BuildContext context) {
    final Color color = _mockPassed ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _mockPercent / 100,
                    strokeWidth: 10,
                    color: color,
                    backgroundColor: _mockPassed ? AppColors.successLight : const Color(0xFFFEE2E2),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_mockCorrectCount/${_mockQuestions.length}',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                        ),
                        Text('$_mockPercent%', style: AppText.small),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _mockPassed ? 'Passed! 🎉' : 'Pass nahi hua',
            textAlign: TextAlign.center,
            style: AppText.h1.copyWith(color: color),
          ),
          const SizedBox(height: 20),
          if (_mockPassed)
            ElevatedButton.icon(
              onPressed: _claimCertificate,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('Get Certificate'),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _mockAnswers = List<int?>.filled(_mockQuestions.length, null);
                  _currentIndex = 0;
                  _mockFinished = false;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Quiz'),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  HELPER WIDGETS
// ────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3))),
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
