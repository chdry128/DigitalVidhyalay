// ============================================================
//  LESSON PLAYER — YouTube video + lessons ki list + progress
//
//  • Video ID har lesson ke "videoId" se aata hai (courses.json)
//    Na ho to AppConfig.demoVideoId chalta hai.
//  • previewOnly = true → bina enroll (sirf pehla FREE lesson)
//  • "Mark as done" / "Next" se progress phone me save hota hai
//  • Saare lessons complete → Quiz → Certificate
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/models/course.dart';
import '../data/models/payment.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../utils/launcher.dart';
import 'certificate_screen.dart';
import 'payment_screen.dart';
import 'quiz_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.course,
    this.startLesson,
    this.previewOnly = false,
  });

  final Course course;
  final PlaylistItem? startLesson; // null = pehla lesson
  final bool previewOnly;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late final List<PlaylistItem> _lessons = widget.course.playlist;
  late PlaylistItem _current;
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _current = widget.startLesson ?? _lessons.first;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _current.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        // Zaroori! Iske bina YouTube "Error 152" deta hai (package 5.x me).
        // Package 6.x pe jaoge to yahan app ka ID: 'https://com.digitalvidyalaya.digital_vidyalaya'
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
    if (!widget.previewOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AppState>().setLastLesson(widget.course, _current);
      });
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  bool _isLocked(PlaylistItem item) => widget.previewOnly && !item.isFree;

  void _open(PlaylistItem item) {
    if (_isLocked(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poora course dekhne ke liye enroll karein')),
      );
      return;
    }
    if (item.key == _current.key) return;
    setState(() => _current = item);
    _controller.loadVideoById(videoId: item.videoId);
    if (!widget.previewOnly) {
      context.read<AppState>().setLastLesson(widget.course, item);
    }
  }

  PlaylistItem? get _next =>
      _current.index + 1 < _lessons.length ? _lessons[_current.index + 1] : null;

  Future<void> _completeAndNext() async {
    final AppState state = context.read<AppState>();
    await state.setLessonDone(_current, true);
    if (!mounted) return;
    final PlaylistItem? next = _next;
    if (next != null) {
      _open(next);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Badhai ho! Aapne saare lessons complete kar liye 🎉')),
      );
    }
  }

  void _enroll() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(item: PurchaseItem.fromCourse(widget.course)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool done = state.isLessonDone(_current);
    final int doneCount = state.completedLessonCount(widget.course);

    // YoutubePlayerScaffold: fullscreen button dabane pe video poori screen pe
    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.previewOnly ? 'Free Preview' : widget.course.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    // ---------- Abhi chal raha lesson ----------
                    Text(
                      'LESSON ${_current.index + 1} OF ${_lessons.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_current.title, style: AppText.h2),
                    if (_current.moduleTitle != _current.title)
                      Text(_current.moduleTitle, style: AppText.small),
                    // Backup: app me video na chale to YouTube app me khol do
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => openYouTube(context, _current.videoId),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('Video nahi chal raha? YouTube app me dekhein'),
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (!widget.previewOnly) ...[
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: state.courseProgress(widget.course),
                                minHeight: 6,
                                color: AppColors.primary,
                                backgroundColor: const Color(0xFFE7E5E4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('$doneCount/${_lessons.length} done', style: AppText.small),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => state.setLessonDone(_current, !done),
                              icon: Icon(
                                done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                size: 18,
                              ),
                              label: Text(done ? 'Done' : 'Mark as done'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _completeAndNext,
                              child: Text(_next == null ? 'Finish' : 'Next lesson'),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      // Preview: enroll karne ka button
                      AppCard(
                        color: AppColors.primaryLight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Yeh free preview hai', style: AppText.cardTitle),
                            const SizedBox(height: 2),
                            Text(
                              'Saare ${_lessons.length} lessons, quiz aur certificate ke liye enroll karein.',
                              style: AppText.small,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _enroll,
                              child: Text('Enroll for ${widget.course.priceLabel}'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 22),
                    const Text('Course content', style: AppText.title),
                    const SizedBox(height: 8),

                    // ---------- Lessons ki list ----------
                    for (final PlaylistItem item in _lessons)
                      _LessonTile(
                        item: item,
                        isCurrent: item.key == _current.key,
                        isDone: state.isLessonDone(item),
                        isLocked: _isLocked(item),
                        onTap: () => _open(item),
                      ),

                    // ---------- Quiz ----------
                    if (!widget.previewOnly) ...[
                      const SizedBox(height: 16),
                      _QuizCard(
                        unlocked: state.isCourseCompleted(widget.course),
                        certificate: state.certificateFor('course', widget.course.id),
                        onTap: () {
                          final CertificateRecord? cert =
                              state.certificateFor('course', widget.course.id);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => cert != null
                                  ? CertificateScreen(record: cert)
                                  : QuizScreen(course: widget.course),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.item,
    required this.isCurrent,
    required this.isDone,
    required this.isLocked,
    required this.onTap,
  });

  final PlaylistItem item;
  final bool isCurrent;
  final bool isDone;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    if (isLocked) {
      icon = Icons.lock_outline_rounded;
      iconColor = AppColors.textMuted;
    } else if (isDone) {
      icon = Icons.check_circle_rounded;
      iconColor = AppColors.success;
    } else if (isCurrent) {
      icon = Icons.play_circle_fill_rounded;
      iconColor = AppColors.primary;
    } else {
      icon = Icons.play_circle_outline_rounded;
      iconColor = AppColors.textMuted;
    }

    final List<String> info = [
      if (item.duration.isNotEmpty) item.duration,
      if (item.isFree) 'FREE',
    ];

    return Material(
      color: isCurrent ? AppColors.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.index + 1}. ${item.title}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        color: isCurrent ? AppColors.primary : AppColors.textDark,
                      ),
                    ),
                    if (info.isNotEmpty) Text(info.join(' · '), style: AppText.tiny),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.unlocked, required this.certificate, required this.onTap});

  final bool unlocked;
  final CertificateRecord? certificate; // Pass ho chuke → certificate dikhao
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: unlocked ? onTap : null,
      child: Row(
        children: [
          Icon(
            certificate != null
                ? Icons.workspace_premium_rounded
                : (unlocked ? Icons.quiz_rounded : Icons.lock_outline_rounded),
            color: unlocked ? AppColors.primary : AppColors.textMuted,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate != null ? 'Aapka Certificate' : 'Final Quiz & Certificate',
                  style: AppText.cardTitle,
                ),
                Text(
                  certificate != null
                      ? 'Quiz pass ✓ · Certificate dekhein / download karein'
                      : (unlocked
                          ? 'Quiz do aur verified certificate pao'
                          : 'Saare lessons complete karne par unlock hoga'),
                  style: AppText.small,
                ),
              ],
            ),
          ),
          if (unlocked) const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
