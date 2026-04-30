import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/glass_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Overview', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Full system access and records',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
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
                    label: 'Students',
                    value: sp.students.length,
                    gradientColors: [AppColors.primary, AppColors.secondary],
                  ),
                  StatCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Courses',
                    value: cp.courses.length,
                    gradientColors: [AppColors.warning, AppColors.primary],
                  ),
                  StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Requests',
                    value: ep.pendingEnrollments.length,
                    gradientColors: [
                      AppColors.warning,
                      const Color(0xFFFF6B6B),
                    ],
                  ),
                  StatCard(
                    icon: Icons.history_rounded,
                    label: 'History',
                    value:
                        ep.droppedEnrollments.length +
                        ep.completedEnrollments.length,
                    gradientColors: [AppColors.success, AppColors.secondary],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Admin Actions', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.menu_book_rounded,
                      label: 'Manage every course',
                      onTap: () => context.go('/admin/courses'),
                    ),
                    const Divider(color: AppColors.divider),
                    _ActionRow(
                      icon: Icons.assignment_rounded,
                      label: 'Approve enrollments and drops',
                      onTap: () => context.go('/admin/enrollments'),
                    ),
                    const Divider(color: AppColors.divider),
                    _ActionRow(
                      icon: Icons.manage_accounts_rounded,
                      label: 'Change usernames and passwords',
                      onTap: () => context.go('/admin/accounts'),
                    ),
                    const Divider(color: AppColors.divider),
                    _ActionRow(
                      icon: Icons.history_rounded,
                      label: 'View add/drop history',
                      onTap: () => context.go('/admin/history'),
                    ),
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

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
