import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/professor_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/formatters.dart';

/// Professor dashboard — overview with pending enrollment management.
class ProfessorDashboardPage extends StatelessWidget {
  const ProfessorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final prof = context.watch<ProfessorProvider>().getProfessorById(
      auth.currentUserId ?? '',
    );
    final managedCourseIds = cp
        .getCoursesForProfessor(auth.currentUserId ?? '')
        .map((c) => c.id)
        .toSet();
    final scopedEnrollments = ep.enrollments
        .where((e) => managedCourseIds.contains(e.courseId))
        .toList();
    final pendingEnrollments = scopedEnrollments
        .where(
          (e) =>
              e.status == EnrollmentStatus.pending ||
              e.status == EnrollmentStatus.dropPending,
        )
        .toList();

    final totalStudents = scopedEnrollments
        .map((e) => e.studentId)
        .toSet()
        .length;
    final totalCourses = managedCourseIds.length;
    final pendingCount = pendingEnrollments.length;
    final activeCount = scopedEnrollments
        .where((e) => e.status == EnrollmentStatus.enrolled)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _buildWelcomeHeader(prof),
              const SizedBox(height: 24),

              // Stats
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    icon: Icons.people_rounded,
                    label: 'Total Students',
                    value: totalStudents,
                    gradientColors: [AppColors.primary, AppColors.secondary],
                  ),
                  StatCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Total Courses',
                    value: totalCourses,
                    gradientColors: [
                      const Color(0xFFFF6B6B),
                      AppColors.warning,
                    ],
                  ),
                  StatCard(
                    icon: Icons.hourglass_empty_rounded,
                    label: 'Pending',
                    value: pendingCount,
                    gradientColors: [
                      AppColors.warning,
                      const Color(0xFFFF6B6B),
                    ],
                  ),
                  StatCard(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Active',
                    value: activeCount,
                    gradientColors: [AppColors.success, AppColors.secondary],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text('Quick Actions', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.pending_actions,
                      label: 'Review Pending',
                      onTap: () => context.go('/professor/enrollments'),
                      colors: [AppColors.warning, const Color(0xFFFF6B6B)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.menu_book_rounded,
                      label: 'Manage Courses',
                      onTap: () => context.go('/professor/courses'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Pending enrollments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending Enrollments', style: AppTextStyles.subheading),
                  if (pendingCount > 0)
                    TextButton(
                      onPressed: () => context.go('/professor/enrollments'),
                      child: const Text(
                        'See all',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (pendingCount == 0)
                GlassCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 40,
                            color: AppColors.success.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text('All caught up!', style: AppTextStyles.caption),
                          Text(
                            'No pending enrollment requests',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendingEnrollments.take(5).map((enrollment) {
                  final student = sp.getStudentById(enrollment.studentId);
                  final course = cp.getCourseById(enrollment.courseId);
                  if (student == null || course == null)
                    return const SizedBox.shrink();
                  final gi = sp.students.indexOf(student);
                  return GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            StudentAvatar(
                              initials: student.initials,
                              colorIndex: gi,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${course.courseCode} • ${course.title}',
                                    style: AppTextStyles.caption,
                                  ),
                                  Text(
                                    Formatters.formatShortDate(
                                      enrollment.enrollmentDate,
                                    ),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(status: enrollment.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                label: const Text(
                                  'Reject',
                                  style: TextStyle(color: AppColors.error),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  final isDrop =
                                      enrollment.status ==
                                      EnrollmentStatus.dropPending;
                                  final confirmed = await showConfirmDialog(
                                    context,
                                    title: isDrop
                                        ? 'Reject drop request?'
                                        : 'Reject enrollment?',
                                    message: isDrop
                                        ? 'Keep ${student.fullName} enrolled in ${course.courseCode}?'
                                        : 'Reject ${student.fullName}\'s request for ${course.courseCode}?',
                                    confirmText: 'Reject',
                                  );
                                  if (confirmed != true || !context.mounted)
                                    return;
                                  isDrop
                                      ? ep.rejectDropRequest(enrollment.id)
                                      : ep.rejectEnrollment(enrollment.id);
                                  showAppSnackbar(
                                    context,
                                    message: isDrop
                                        ? 'Drop request rejected'
                                        : 'Enrollment rejected',
                                    type: SnackbarType.warning,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final isDrop =
                                        enrollment.status ==
                                        EnrollmentStatus.dropPending;
                                    final confirmed = await showConfirmDialog(
                                      context,
                                      title: isDrop
                                          ? 'Approve drop request?'
                                          : 'Approve enrollment?',
                                      message: isDrop
                                          ? 'Drop ${student.fullName} from ${course.courseCode}?'
                                          : 'Enroll ${student.fullName} in ${course.courseCode}?',
                                      confirmText: 'Approve',
                                      confirmColor: AppColors.primary,
                                    );
                                    if (confirmed != true || !context.mounted)
                                      return;
                                    isDrop
                                        ? ep.approveDropRequest(enrollment.id)
                                        : ep.approveEnrollment(enrollment.id);
                                    showAppSnackbar(
                                      context,
                                      message: isDrop
                                          ? '${student.fullName} dropped from ${course.courseCode}'
                                          : '${student.fullName} enrolled in ${course.courseCode}',
                                      type: SnackbarType.success,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic prof) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prof != null ? prof.fullName : 'Professor',
                    style: AppTextStyles.headingSmall,
                  ),
                  Text(
                    prof != null ? '${prof.department} Department' : '',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            '$greeting! 👋',
            style: AppTextStyles.subheading.copyWith(color: Colors.white),
          ),
        ),
        Text(Formatters.formatDate(now), style: AppTextStyles.caption),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? colors;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.colors,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors ?? [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (colors?.first ?? AppColors.primary).withValues(
                alpha: 0.3,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }
}
