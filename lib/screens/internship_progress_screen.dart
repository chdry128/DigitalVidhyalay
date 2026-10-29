// ============================================================
//  INTERNSHIP PROGRESS & WORKSPACE
//  Connected to PHP API:
//   - GET  /mobile-api/internship/workspace.php
//   - POST /mobile-api/internship/submit-task.php
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/certificate.dart';
import '../data/models/internship.dart';
import '../data/models/workspace_data.dart';
import '../data/repository/api_client.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/internship_card.dart';
import 'certificate_screen.dart';
import 'quiz_screen.dart';

class InternshipProgressScreen extends StatefulWidget {
  const InternshipProgressScreen({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipProgressScreen> createState() =>
      _InternshipProgressScreenState();
}

class _InternshipProgressScreenState extends State<InternshipProgressScreen> {
  WorkspaceData? _workspace;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  Future<void> _loadWorkspace() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final state = context.read<AppState>();
      final data = await state.loadWorkspace(widget.internship.id);
      if (mounted) {
        setState(() {
          _workspace = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to load internship workspace.';
        if (e is ApiException) {
          msg = e.message;
        } else {
          msg = e.toString();
        }
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCertificate(BuildContext context, AppState state) async {
    final CertificateRecord record = await state.issueCertificate(
      type: 'internship',
      itemId: widget.internship.id,
      title: widget.internship.title,
    );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CertificateScreen(record: record),
      ),
    );
  }

  void _showSubmissionSheet(BuildContext context, WorkspaceModule module) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TaskSubmissionSheet(
        internshipId: widget.internship.id,
        module: module,
        onSubmitted: () {
          _loadWorkspace();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Workspace',
            onPressed: _loadWorkspace,
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, AppState state) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 14),
            Text(
              'Loading workspace...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Workspace Error', style: AppText.h2),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppText.small,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadWorkspace,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final ws = _workspace;
    if (ws == null) {
      return const SizedBox.shrink();
    }

    final int total = ws.totalModules;
    final int done = ws.completedCount;
    final bool finished = ws.allModulesCompleted;
    final double progress = total > 0 ? done / total : 0.0;

    return RefreshIndicator(
      onRefresh: _loadWorkspace,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ---------- Upar ka summary ----------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TypeBadge(type: widget.internship.type),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: finished
                            ? AppColors.successLight
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        finished ? 'COMPLETED' : 'IN PROGRESS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: finished
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ws.internship.title.isNotEmpty
                      ? ws.internship.title
                      : widget.internship.title,
                  style: AppText.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.internship.domain} · Remote · ${ws.internship.durationWeeks} Weeks Program',
                  style: AppText.small,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color:
                              finished ? AppColors.success : AppColors.primary,
                          backgroundColor: const Color(0xFFE7E5E4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$done/$total modules approved',
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            finished ? AppColors.success : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Quiz unlock status banner ----------
          if (ws.quizStatus.isUnlocked)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(
                      internshipId: widget.internship.id,
                      title: '${ws.internship.title.isNotEmpty ? ws.internship.title : widget.internship.title} — Assessment',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: AppColors.success, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Final Assessment / Quiz is now unlocked! Tap to start.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.success),
                  ],
                ),
              ),
            )
          else if (ws.quizStatus.unlockDate.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_rounded,
                      color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Final Quiz unlocks on: ${ws.quizStatus.unlockDate}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ---------- Task Modules List ----------
          const Text('Internship Modules & Tasks', style: AppText.title),
          const SizedBox(height: 4),
          const Text(
            'Complete weekly assignments and submit your live link or repo for mentor review.',
            style: AppText.small,
          ),
          const SizedBox(height: 12),

          if (ws.modules.isEmpty)
            AppCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 44, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      const Text('No modules found', style: AppText.cardTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Tasks for this program will be published shortly.',
                        style: AppText.small
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            for (final module in ws.modules)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModuleCard(
                  module: module,
                  onSubmitTap: () => _showSubmissionSheet(context, module),
                ),
              ),

          const SizedBox(height: 10),

          // ---------- Certificate card ----------
          AppCard(
            onTap: finished ? () => _openCertificate(context, state) : null,
            child: Row(
              children: [
                Icon(
                  finished
                      ? Icons.workspace_premium_rounded
                      : Icons.lock_outline_rounded,
                  color: finished ? AppColors.primary : AppColors.textMuted,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Work Experience Certificate',
                          style: AppText.cardTitle),
                      Text(
                        finished
                            ? 'All modules approved! Tap to view/download certificate.'
                            : 'Requires all $total modules to be approved.',
                        style: AppText.small,
                      ),
                    ],
                  ),
                ),
                if (finished)
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---------- Mentor help ----------
          OutlinedButton.icon(
            onPressed: () => openWhatsApp(
              context,
              message:
                  'Hello, I am enrolled in "${widget.internship.title}". I need assistance from my mentor.',
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contact Mentor on WhatsApp'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  MODULE CARD
// ────────────────────────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.onSubmitTap,
  });

  final WorkspaceModule module;
  final VoidCallback onSubmitTap;

  @override
  Widget build(BuildContext context) {
    final sub = module.submission;
    final bool isApproved = sub?.isApproved ?? false;
    final bool isPending = sub?.isPending ?? false;
    final bool isRevision = sub?.isRevisionRequested ?? false;

    Color badgeBg;
    Color badgeText;
    String statusLabel;
    IconData statusIcon;

    if (isApproved) {
      badgeBg = AppColors.successLight;
      badgeText = AppColors.success;
      statusLabel = 'Approved ✓';
      statusIcon = Icons.check_circle_rounded;
    } else if (isPending) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFD97706);
      statusLabel = 'Under Review ⏳';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (isRevision) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = AppColors.error;
      statusLabel = 'Needs Revision ⚠️';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      badgeBg = const Color(0xFFF3F4F6);
      badgeText = AppColors.textMuted;
      statusLabel = 'Not Submitted';
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Week badge + Title + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isApproved
                      ? AppColors.successLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'W${module.week}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color:
                        isApproved ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Module ${module.moduleOrder}: ${module.title}',
                      style: AppText.cardTitle.copyWith(
                        fontSize: 15,
                        decoration: isApproved ? TextDecoration.none : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: badgeText),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: badgeText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (module.hasQuiz) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Quiz',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7E22CE),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Task instructions
          if (module.taskInstructions != null &&
              module.taskInstructions!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                module.taskInstructions!.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Briefing video button (if available)
          if (module.videoUrl != null &&
              module.videoUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => openLink(context, module.videoUrl!.trim()),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_outline_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Watch Briefing Video',
                      style: AppText.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Existing submission details
          if (sub != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link_rounded,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              openLink(context, sub.submissionLink),
                          child: Text(
                            sub.submissionLink,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0284C7),
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sub.studentNotes != null &&
                      sub.studentNotes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${sub.studentNotes!.trim()}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF475569)),
                    ),
                  ],
                  if (sub.submittedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Submitted: ${sub.submittedAt}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                  // Admin feedback box
                  if (sub.adminFeedback != null &&
                      sub.adminFeedback!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? AppColors.successLight
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isApproved
                              ? AppColors.success.withValues(alpha: 0.3)
                              : const Color(0xFFFED7AA),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 16,
                            color: isApproved
                                ? AppColors.success
                                : const Color(0xFFEA580C),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Mentor Feedback: ${sub.adminFeedback!.trim()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isApproved
                                    ? AppColors.success
                                    : const Color(0xFF9A3412),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Button: Submit / Resubmit / Approved
          if (isApproved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Task Completed & Approved',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmitTap,
                icon: Icon(
                  sub != null
                      ? Icons.edit_note_rounded
                      : Icons.cloud_upload_rounded,
                  size: 18,
                ),
                label: Text(
                  sub != null ? 'Update Submission' : 'Submit Task',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isRevision ? AppColors.primary : AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  TASK SUBMISSION BOTTOM SHEET
// ────────────────────────────────────────────────────────────
class _TaskSubmissionSheet extends StatefulWidget {
  const _TaskSubmissionSheet({
    required this.internshipId,
    required this.module,
    required this.onSubmitted,
  });

  final int internshipId;
  final WorkspaceModule module;
  final VoidCallback onSubmitted;

  @override
  State<_TaskSubmissionSheet> createState() => _TaskSubmissionSheetState();
}

class _TaskSubmissionSheetState extends State<_TaskSubmissionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _linkCtrl;
  late final TextEditingController _notesCtrl;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _linkCtrl = TextEditingController(
      text: widget.module.submission?.submissionLink ?? '',
    );
    _notesCtrl = TextEditingController(
      text: widget.module.submission?.studentNotes ?? '',
    );
  }

  @override
  void dispose() {
    _linkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Please enter project link or repository URL';
    }
    final uri = Uri.tryParse(v);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Please enter a valid URL starting with http:// or https://';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final state = context.read<AppState>();
      await state.submitTask(
        internshipId: widget.internshipId,
        moduleId: widget.module.moduleId,
        submissionLink: _linkCtrl.text.trim(),
        studentNotes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Task submitted successfully! Your mentor will review it soon.',
            ),
          ),
        );
        widget.onSubmitted();
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to submit task.';
        if (e is ApiException) {
          msg = e.message;
        } else {
          msg = e.toString();
        }
        setState(() {
          _submitError = msg;
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Task — Module ${widget.module.moduleOrder}',
                          style: AppText.cardTitle.copyWith(fontSize: 16),
                        ),
                        Text(
                          widget.module.title,
                          style: AppText.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              if (_submitError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _submitError!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.error),
                  ),
                ),
              ],

              // URL Input field
              const Text(
                'Project / Repository URL *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _linkCtrl,
                keyboardType: TextInputType.url,
                validator: _validateUrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link_rounded),
                  hintText: 'https://github.com/username/project or Drive URL',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notes Input field
              const Text(
                'Notes for Mentor (optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.notes_rounded),
                  hintText:
                      'Mention branches, test instructions, or questions...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.module.hasSubmission
                              ? 'Update Submission'
                              : 'Submit Project',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
