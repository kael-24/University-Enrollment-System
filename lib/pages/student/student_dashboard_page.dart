import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/student_avatar.dart';
import '../../utils/formatters.dart';

/// Student dashboard — personal overview of enrollment status.
class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();

    final student = sp.getStudentById(auth.currentUserId ?? '');
    if (student == null) return const Scaffold(body: Center(child: Text('Student not found')));

    final active = ep.getActiveEnrollmentsForStudent(student.id);
    final pending = ep.getPendingEnrollmentsForStudent(student.id);
    final completed = ep.getCompletedEnrollmentsForStudent(student.id);
    final gi = sp.students.indexOf(student);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome Header ─────────────────────
              _buildWelcomeHeader(student, gi),
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
                    icon: Icons.check_circle_outline,
                    label: 'Active Courses',
                    value: active.length,
                    gradientColors: [AppColors.success, AppColors.secondary],
                  ),
                  StatCard(
                    icon: Icons.hourglass_empty_rounded,
                    label: 'Pending',
                    value: pending.length,
                    gradientColors: [AppColors.warning, const Color(0xFFFF6B6B)],
                  ),
                  StatCard(
                    icon: Icons.school_rounded,
                    label: 'Completed',
                    value: completed.length,
                    gradientColors: [AppColors.primary, AppColors.secondary],
                  ),
                  StatCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Available Courses',
                    value: cp.courses.length,
                    gradientColors: [const Color(0xFFFF6B6B), AppColors.warning],
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
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: 'Browse Courses',
                      onTap: () => context.go('/student/courses'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.list_alt_rounded,
                      label: 'My Enrollments',
                      onTap: () => context.go('/student/enrollments'),
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ─── My Active Courses ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Active Courses', style: AppTextStyles.subheading),
                  TextButton(
                    onPressed: () => context.go('/student/enrollments'),
                    child: const Text('See all', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (active.isEmpty)
                GlassCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.school_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No active courses', style: AppTextStyles.caption),
                          Text('Browse courses to get started!', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...active.take(5).map((e) {
                  final course = cp.getCourseById(e.courseId);
                  if (course == null) return const SizedBox.shrink();
                  return GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              Text(course.title, style: AppTextStyles.caption),
                              Text(course.schedule, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        StatusChip(status: e.status),
                      ],
                    ),
                  );
                }),

              // ─── Pending Requests ───────────────────
              if (pending.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Pending Requests', style: AppTextStyles.subheading),
                const SizedBox(height: 8),
                ...pending.map((e) {
                  final course = cp.getCourseById(e.courseId);
                  if (course == null) return const SizedBox.shrink();
                  return GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.hourglass_empty_rounded, color: AppColors.warning, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                              Text(course.title, style: AppTextStyles.caption),
                              Text('Awaiting professor approval', style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontSize: 11)),
                            ],
                          ),
                        ),
                        StatusChip(status: e.status),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic student, int gi) {
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
            StudentAvatar(initials: student.initials, colorIndex: gi, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName, style: AppTextStyles.headingSmall),
                  Text('${student.id} • ${student.program}', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text('$greeting! 👋', style: AppTextStyles.subheading.copyWith(color: Colors.white)),
        ),
        Text(Formatters.formatDate(now), style: AppTextStyles.caption),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? colors;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors ?? [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: (colors?.first ?? AppColors.primary).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
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
