// ============================================================
//  WORKSPACE & INTERNSHIP MODELS
//  Matches PHP endpoints:
//    /mobile-api/internship/workspace.php
//    /mobile-api/internship/my-internships.php
// ============================================================

class EnrolledInternship {
  final int applicationId;
  final int internshipId;
  final String title;
  final String slug;
  final String category;
  final int durationWeeks;
  final double feeAmount;
  final String paymentStatus;
  final String completionStatus;
  final int progressPercent;
  final String? enrolledAt;

  const EnrolledInternship({
    required this.applicationId,
    required this.internshipId,
    required this.title,
    required this.slug,
    required this.category,
    required this.durationWeeks,
    required this.feeAmount,
    required this.paymentStatus,
    required this.completionStatus,
    required this.progressPercent,
    this.enrolledAt,
  });

  bool get isPaid => paymentStatus == 'paid';
  bool get isCompleted => completionStatus == 'completed';

  factory EnrolledInternship.fromJson(Map<String, dynamic> json) {
    return EnrolledInternship(
      applicationId: json['application_id'] as int? ?? 0,
      internshipId: json['internship_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      durationWeeks: json['duration_weeks'] as int? ?? 0,
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'paid',
      completionStatus: json['completion_status'] as String? ?? 'in_progress',
      progressPercent: json['progress_percent'] as int? ?? 0,
      enrolledAt: json['enrolled_at'] as String?,
    );
  }
}

class TaskSubmission {
  final int submissionId;
  final String submissionLink;
  final String? studentNotes;
  final String status; // 'pending', 'approved', 'revision_requested'
  final String? adminFeedback;
  final String? submittedAt;
  final String? reviewedAt;

  const TaskSubmission({
    required this.submissionId,
    required this.submissionLink,
    this.studentNotes,
    required this.status,
    this.adminFeedback,
    this.submittedAt,
    this.reviewedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRevisionRequested => status == 'revision_requested';

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    return TaskSubmission(
      submissionId: json['submission_id'] as int? ?? 0,
      submissionLink: json['submission_link'] as String? ?? '',
      studentNotes: json['student_notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminFeedback: json['admin_feedback'] as String?,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
    );
  }
}

class WorkspaceModule {
  final int moduleId;
  final int week;
  final int moduleOrder;
  final String title;
  final String? videoUrl;
  final String? taskInstructions;
  final String taskType;
  final bool hasQuiz;
  final TaskSubmission? submission;

  const WorkspaceModule({
    required this.moduleId,
    required this.week,
    required this.moduleOrder,
    required this.title,
    this.videoUrl,
    this.taskInstructions,
    required this.taskType,
    required this.hasQuiz,
    this.submission,
  });

  bool get isDone => submission != null && submission!.isApproved;
  bool get hasSubmission => submission != null;

  factory WorkspaceModule.fromJson(Map<String, dynamic> json) {
    final subJson = json['submission'] as Map<String, dynamic>?;
    return WorkspaceModule(
      moduleId: json['module_id'] as int? ?? 0,
      week: json['week'] as int? ?? 1,
      moduleOrder: json['module_order'] as int? ?? 1,
      title: json['title'] as String? ?? 'Module',
      videoUrl: json['video_url'] as String?,
      taskInstructions: json['task_instructions'] as String?,
      taskType: json['task_type'] as String? ?? 'url_submission',
      hasQuiz: json['has_quiz'] as bool? ?? false,
      submission: subJson != null ? TaskSubmission.fromJson(subJson) : null,
    );
  }
}

class InternshipWorkspaceInfo {
  final int id;
  final String title;
  final int durationWeeks;
  final String completionStatus;
  final int progressPercent;
  final String? enrolledAt;

  const InternshipWorkspaceInfo({
    required this.id,
    required this.title,
    required this.durationWeeks,
    required this.completionStatus,
    required this.progressPercent,
    this.enrolledAt,
  });

  factory InternshipWorkspaceInfo.fromJson(Map<String, dynamic> json) {
    return InternshipWorkspaceInfo(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      durationWeeks: json['duration_weeks'] as int? ?? 4,
      completionStatus: json['completion_status'] as String? ?? 'enrolled',
      progressPercent: json['progress_percent'] as int? ?? 0,
      enrolledAt: json['enrolled_at'] as String?,
    );
  }
}

class QuizUnlockStatus {
  final bool isUnlocked;
  final int unlockTimestamp;
  final String unlockDate;

  const QuizUnlockStatus({
    required this.isUnlocked,
    required this.unlockTimestamp,
    required this.unlockDate,
  });

  factory QuizUnlockStatus.fromJson(Map<String, dynamic> json) {
    return QuizUnlockStatus(
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockTimestamp: json['unlock_timestamp'] as int? ?? 0,
      unlockDate: json['unlock_date'] as String? ?? '',
    );
  }
}

class WorkspaceData {
  final InternshipWorkspaceInfo internship;
  final QuizUnlockStatus quizStatus;
  final List<WorkspaceModule> modules;

  const WorkspaceData({
    required this.internship,
    required this.quizStatus,
    required this.modules,
  });

  int get completedCount => modules.where((m) => m.isDone).length;
  int get totalModules => modules.length;
  bool get allModulesCompleted => totalModules > 0 && completedCount == totalModules;

  factory WorkspaceData.fromJson(Map<String, dynamic> json) {
    final iMap = json['internship'] as Map<String, dynamic>? ?? {};
    final qMap = json['quiz_status'] as Map<String, dynamic>? ?? {};
    final mList = (json['modules'] as List<dynamic>?) ?? <dynamic>[];

    return WorkspaceData(
      internship: InternshipWorkspaceInfo.fromJson(iMap),
      quizStatus: QuizUnlockStatus.fromJson(qMap),
      modules: mList
          .map((m) => WorkspaceModule.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
