import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/capacity_bar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/enrollment_dialog.dart';
import '../../utils/formatters.dart';

/// Dashboard page — main overview of the enrollment system.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final enrollmentProvider = context.watch<EnrollmentProvider>();

    final totalStudents = studentProvider.students.length;
    final totalCourses = courseProvider.courses.length;
    final activeEnrollments = enrollmentProvider.activeEnrollments.length;

    // Calculate average enrollment rate
    int totalCapacity = 0;
    int totalEnrolled = 0;
    for (final course in courseProvider.courses) {
      totalCapacity += course.capacity;
      totalEnrolled += enrollmentProvider.getEnrolledCount(course.id);
    }
    final avgRate = totalCapacity > 0
        ? ((totalEnrolled / totalCapacity) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome Header ─────────────────────
              _buildWelcomeHeader(),
              const SizedBox(height: 24),

              // ─── Stats Grid ─────────────────────────
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
                      AppColors.warning
                    ],
                  ),
                  StatCard(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Active Enrollments',
                    value: activeEnrollments,
                    gradientColors: [AppColors.success, AppColors.secondary],
                  ),
                  StatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Enrollment Rate',
                    value: avgRate,
                    suffix: '%',
                    gradientColors: [AppColors.warning, const Color(0xFFFF6B6B)],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Quick Actions ──────────────────────
              Text('Quick Actions', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GradientButton(
                      icon: Icons.person_add_rounded,
                      label: 'Enroll Student',
                      onTap: () => showEnrollmentDialog(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientButton(
                      icon: Icons.school_rounded,
                      label: 'View Courses',
                      onTap: () => context.go('/courses'),
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ─── Recent Enrollments ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Enrollments', style: AppTextStyles.subheading),
                  TextButton(
                    onPressed: () => context.go('/enrollments'),
                    child: const Text('See all',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecentEnrollments(context, enrollmentProvider,
                  studentProvider, courseProvider),
              const SizedBox(height: 28),

              // ─── Course Capacity Overview ───────────
              Text('Course Capacity', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              ...courseProvider.courses.map((course) {
                final enrolled = enrollmentProvider.getEnrolledCount(course.id);
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(course.courseCode,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(course.title,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CapacityBar(enrolled: enrolled, capacity: course.capacity),
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

  Widget _buildWelcomeHeader() {
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.school_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EnrollHub', style: AppTextStyles.heading),
                Text(Formatters.formatDate(now), style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text('$greeting! 👋',
              style: AppTextStyles.subheading.copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildRecentEnrollments(
    BuildContext context,
    EnrollmentProvider enrollmentProvider,
    StudentProvider studentProvider,
    CourseProvider courseProvider,
  ) {
    final recent = enrollmentProvider.getRecentEnrollments(limit: 5);
    if (recent.isEmpty) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No enrollments yet',
                style: AppTextStyles.caption),
          ),
        ),
      );
    }

    return Column(
      children: recent.map((enrollment) {
        final student = studentProvider.getStudentById(enrollment.studentId);
        final course = courseProvider.getCourseById(enrollment.courseId);
        if (student == null || course == null) return const SizedBox.shrink();

        return GlassCard(
          child: Row(
            children: [
              StudentAvatar(
                initials: student.initials,
                colorIndex: studentProvider.students.indexOf(student),
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(
                        '${course.courseCode} • ${Formatters.formatShortDate(enrollment.enrollmentDate)}',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              StatusChip(status: enrollment.status),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Gradient action button for quick actions.
class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? colors;

  const _GradientButton({
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
              color: (colors?.first ?? AppColors.primary).withValues(alpha: 0.3),
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
