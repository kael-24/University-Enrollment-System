import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/enums.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/formatters.dart';

/// Professor enrollments page â€” manage all enrollments with approve/reject.
class ProfessorEnrollmentsPage extends StatefulWidget {
  const ProfessorEnrollmentsPage({super.key});
  @override
  State<ProfessorEnrollmentsPage> createState() =>
      _ProfessorEnrollmentsPageState();
}

class _ProfessorEnrollmentsPageState extends State<ProfessorEnrollmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final auth = context.watch<AuthProvider>();
    final scoped = auth.isAdmin
        ? ep.enrollments
        : ep.enrollments
              .where(
                (e) =>
                    cp.getCourseById(e.courseId)?.professorId ==
                    auth.currentUserId,
              )
              .toList();
    final pending = scoped
        .where(
          (e) =>
              e.status == EnrollmentStatus.pending ||
              e.status == EnrollmentStatus.dropPending,
        )
        .toList();
    final active = scoped
        .where((e) => e.status == EnrollmentStatus.enrolled)
        .toList();
    final completed = scoped
        .where((e) => e.status == EnrollmentStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.isAdmin ? 'All Requests' : 'My Course Requests',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 4),
              Text(
                '${pending.length} pending | ${active.length} active',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              CustomSearchBar(
                controller: _searchCtrl,
                hintText: 'Search by student or course...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: 'Pending (${pending.length})'),
                    const Tab(text: 'Active'),
                    const Tab(text: 'Done'),
                    const Tab(text: 'All'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildPendingList(pending, sp, cp, ep),
                    _buildList(active, sp, cp),
                    _buildList(completed, sp, cp),
                    _buildList(scoped, sp, cp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList(
    List enrollments,
    StudentProvider sp,
    CourseProvider cp,
    EnrollmentProvider ep,
  ) {
    var filtered = _filterList(enrollments, sp, cp);
    if (filtered.isEmpty)
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No pending enrollments',
        subtitle: 'All enrollment requests have been processed',
      );

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final e = filtered[i];
        final student = sp.getStudentById(e.studentId);
        final course = cp.getCourseById(e.courseId);
        if (student == null || course == null) return const SizedBox.shrink();
        final gi = sp.students.indexOf(student);

        return GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  StudentAvatar(
                    initials: student.initials,
                    colorIndex: gi,
                    size: 42,
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
                        Row(
                          children: [
                            Text(
                              course.courseCode,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                course.title,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Requested ${Formatters.formatShortDate(e.enrollmentDate)}',
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: e.status),
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
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () async {
                        final isDrop = e.status == EnrollmentStatus.dropPending;
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
                        if (confirmed != true || !context.mounted) return;
                        isDrop
                            ? ep.rejectDropRequest(e.id)
                            : ep.rejectEnrollment(e.id);
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
                        label: const Text(
                          'Approve',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () async {
                          final isDrop =
                              e.status == EnrollmentStatus.dropPending;
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
                          if (confirmed != true || !context.mounted) return;
                          isDrop
                              ? ep.approveDropRequest(e.id)
                              : ep.approveEnrollment(e.id);
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
      },
    );
  }

  Widget _buildList(List enrollments, StudentProvider sp, CourseProvider cp) {
    var filtered = _filterList(enrollments, sp, cp);
    if (filtered.isEmpty)
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'No enrollments found',
      );

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final e = filtered[i];
        final student = sp.getStudentById(e.studentId);
        final course = cp.getCourseById(e.courseId);
        if (student == null || course == null) return const SizedBox.shrink();
        final gi = sp.students.indexOf(student);

        return GlassCard(
          child: Row(
            children: [
              StudentAvatar(
                initials: student.initials,
                colorIndex: gi,
                size: 42,
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
                    Row(
                      children: [
                        Text(
                          course.courseCode,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            course.title,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.formatDate(e.enrollmentDate),
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: e.status),
                  if (e.grade != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatGrade(e.grade),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List _filterList(List enrollments, StudentProvider sp, CourseProvider cp) {
    if (_query.isEmpty) return enrollments;
    final q = _query.toLowerCase();
    return enrollments.where((e) {
      final student = sp.getStudentById(e.studentId);
      final course = cp.getCourseById(e.courseId);
      return (student?.fullName.toLowerCase().contains(q) ?? false) ||
          (course?.courseCode.toLowerCase().contains(q) ?? false) ||
          (course?.title.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
