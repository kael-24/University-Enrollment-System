import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../utils/formatters.dart';

/// Student enrollments page — view active, pending, and history.
class StudentEnrollmentsPage extends StatefulWidget {
  const StudentEnrollmentsPage({super.key});
  @override
  State<StudentEnrollmentsPage> createState() => _StudentEnrollmentsPageState();
}

class _StudentEnrollmentsPageState extends State<StudentEnrollmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final studentId = auth.currentUserId ?? '';
    final active = ep.getActiveEnrollmentsForStudent(studentId);
    final pending = ep.getPendingEnrollmentsForStudent(studentId);
    final history = ep.getHistoryForStudent(studentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Enrollments', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text('${active.length} active • ${pending.length} pending', style: AppTextStyles.caption),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white, unselectedLabelColor: AppColors.textSecondary,
                indicatorSize: TabBarIndicatorSize.tab, dividerHeight: 0,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Active (${active.length})'),
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'History (${history.length})'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildActiveTab(active, cp, ep),
                _buildPendingTab(pending, cp),
                _buildHistoryTab(history, cp),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildActiveTab(List active, CourseProvider cp, EnrollmentProvider ep) {
    if (active.isEmpty) return const EmptyState(icon: Icons.school_outlined, title: 'No active courses', subtitle: 'Browse courses to enroll');
    return ListView.builder(
      itemCount: active.length,
      itemBuilder: (ctx, i) {
        final e = active[i];
        final course = cp.getCourseById(e.courseId);
        if (course == null) return const SizedBox.shrink();
        return Dismissible(
          key: Key(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.remove_circle_outline, color: AppColors.error),
              SizedBox(height: 4),
              Text('Drop', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          confirmDismiss: (_) => showConfirmDialog(context, title: 'Drop ${course.courseCode}?', message: 'Are you sure you want to drop "${course.title}"? This action cannot be undone.'),
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
                Text(course.schedule, style: AppTextStyles.caption),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusChip(status: e.status),
                const SizedBox(height: 4),
                Text('← swipe to drop', style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.error.withValues(alpha: 0.6))),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildPendingTab(List pending, CourseProvider cp) {
    if (pending.isEmpty) return const EmptyState(icon: Icons.hourglass_empty, title: 'No pending requests', subtitle: 'Your enrollment requests will appear here');
    return ListView.builder(
      itemCount: pending.length,
      itemBuilder: (ctx, i) {
        final e = pending[i];
        final course = cp.getCourseById(e.courseId);
        if (course == null) return const SizedBox.shrink();
        return GlassCard(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.hourglass_empty_rounded, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              Text(course.title, style: AppTextStyles.caption),
              Text('Requested ${Formatters.formatShortDate(e.enrollmentDate)}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ])),
            StatusChip(status: e.status),
          ]),
        );
      },
    );
  }

  Widget _buildHistoryTab(List history, CourseProvider cp) {
    if (history.isEmpty) return const EmptyState(icon: Icons.history, title: 'No history', subtitle: 'Completed and dropped courses appear here');
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (ctx, i) {
        final e = history[i];
        final course = cp.getCourseById(e.courseId);
        if (course == null) return const SizedBox.shrink();
        return GlassCard(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (e.status == EnrollmentStatus.completed ? AppColors.secondary : AppColors.error).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                e.status == EnrollmentStatus.completed ? Icons.school_rounded : Icons.cancel_outlined,
                color: e.status == EnrollmentStatus.completed ? AppColors.secondary : AppColors.error, size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.courseCode, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              Text(course.title, style: AppTextStyles.caption),
              Text(Formatters.formatDate(e.enrollmentDate), style: AppTextStyles.caption.copyWith(fontSize: 11)),
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
    );
  }
}
