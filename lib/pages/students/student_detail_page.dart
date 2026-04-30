import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/grade_input_sheet.dart';
import '../../widgets/enrollment_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../utils/formatters.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final student = sp.getStudentById(studentId);

    if (student == null) {
      return Scaffold(backgroundColor: AppColors.background, body: const Center(child: Text('Student not found', style: TextStyle(color: AppColors.textSecondary))));
    }

    final gi = sp.students.indexOf(student);
    final active = ep.getActiveEnrollmentsForStudent(studentId);
    final history = ep.getHistoryForStudent(studentId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
        ),
        body: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              StudentAvatar(initials: student.initials, colorIndex: gi, size: 64),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(student.fullName, style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text(student.id, style: AppTextStyles.caption),
                Text('${student.program} • Year ${student.yearLevel}', style: AppTextStyles.caption),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              tabs: [
                Tab(text: 'Enrolled (${active.length})'),
                Tab(text: 'History (${history.length})'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab views
          Expanded(
            child: TabBarView(children: [
              // Active enrollments
              active.isEmpty
                  ? const EmptyState(icon: Icons.school_outlined, title: 'No active enrollments', subtitle: 'Enroll this student in a course')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: active.length,
                      itemBuilder: (ctx, i) {
                        final e = active[i];
                        final course = cp.getCourseById(e.courseId);
                        if (course == null) return const SizedBox.shrink();
                        return Dismissible(
                          key: Key(e.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.delete_outline, color: AppColors.error),
                          ),
                          confirmDismiss: (_) => showConfirmDialog(context, title: 'Drop Course', message: 'Are you sure you want to drop ${course.courseCode}? This action cannot be undone.'),
                          onDismissed: (_) {
                            ep.dropEnrollment(e.id);
                            showAppSnackbar(context, message: 'Dropped ${course.courseCode}', type: SnackbarType.warning);
                          },
                          child: GlassCard(
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                Text(course.title, style: AppTextStyles.body),
                                const SizedBox(height: 2),
                                Text(course.schedule, style: AppTextStyles.caption),
                              ])),
                              StatusChip(status: e.status),
                            ]),
                          ),
                        );
                      },
                    ),
              // History
              history.isEmpty
                  ? const EmptyState(icon: Icons.history, title: 'No history', subtitle: 'Dropped and completed courses will appear here')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: history.length,
                      itemBuilder: (ctx, i) {
                        final e = history[i];
                        final course = cp.getCourseById(e.courseId);
                        if (course == null) return const SizedBox.shrink();
                        return GlassCard(
                          onTap: e.status == EnrollmentStatus.completed ? () async {
                            final grade = await showGradeInputSheet(context, currentGrade: e.grade);
                            if (grade != null) {
                              ep.updateGrade(e.id, grade);
                              if (context.mounted) showAppSnackbar(context, message: 'Grade updated to ${grade.toStringAsFixed(1)}', type: SnackbarType.success);
                            }
                          } : null,
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (e.status == EnrollmentStatus.completed ? AppColors.secondary : AppColors.error).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(e.status == EnrollmentStatus.completed ? Icons.school_rounded : Icons.cancel_outlined, color: e.status == EnrollmentStatus.completed ? AppColors.secondary : AppColors.error, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                              Text(course.title, style: AppTextStyles.caption),
                              Text(Formatters.formatDate(e.enrollmentDate), style: AppTextStyles.caption),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              StatusChip(status: e.status),
                              if (e.grade != null) ...[
                                const SizedBox(height: 4),
                                Text('Grade: ${Formatters.formatGrade(e.grade)}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ]),
                          ]),
                        );
                      },
                    ),
            ]),
          ),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showEnrollmentDialog(context, preselectedStudentId: studentId),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Enroll'),
        ),
      ),
    );
  }
}
