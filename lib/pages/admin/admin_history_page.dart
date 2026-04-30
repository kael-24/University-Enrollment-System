import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/enums.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/student_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';
import '../../utils/formatters.dart';

class AdminHistoryPage extends StatelessWidget {
  const AdminHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final records =
        ep.enrollments
            .where(
              (e) =>
                  e.status == EnrollmentStatus.dropped ||
                  e.status == EnrollmentStatus.completed ||
                  e.status == EnrollmentStatus.enrolled,
            )
            .toList()
          ..sort((a, b) => b.enrollmentDate.compareTo(a.enrollmentDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add and Drop History', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                '${records.length} enrollment records',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: records.isEmpty
                    ? const EmptyState(
                        icon: Icons.history_rounded,
                        title: 'No history found',
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (ctx, i) {
                          final e = records[i];
                          final student = sp.getStudentById(e.studentId);
                          final course = cp.getCourseById(e.courseId);
                          if (student == null || course == null) {
                            return const SizedBox.shrink();
                          }
                          return GlassCard(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${course.courseCode} - ${course.title}',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        Formatters.formatDate(e.enrollmentDate),
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusChip(status: e.status),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
