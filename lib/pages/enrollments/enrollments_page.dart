import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/enrollment_dialog.dart';
import '../../utils/formatters.dart';

class EnrollmentsPage extends StatefulWidget {
  const EnrollmentsPage({super.key});
  @override
  State<EnrollmentsPage> createState() => _EnrollmentsPageState();
}

class _EnrollmentsPageState extends State<EnrollmentsPage>
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enrollments', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                '${ep.enrollments.length} total records',
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Dropped'),
                    Tab(text: 'Done'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(ep.enrollments, sp, cp, ep),
                    _buildList(ep.activeEnrollments, sp, cp, ep),
                    _buildList(ep.droppedEnrollments, sp, cp, ep),
                    _buildList(ep.completedEnrollments, sp, cp, ep),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showEnrollmentDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildList(
    List enrollments,
    StudentProvider sp,
    CourseProvider cp,
    EnrollmentProvider ep,
  ) {
    var filtered = enrollments;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = enrollments.where((e) {
        final student = sp.getStudentById(e.studentId);
        final course = cp.getCourseById(e.courseId);
        return (student?.fullName.toLowerCase().contains(q) ?? false) ||
            (course?.courseCode.toLowerCase().contains(q) ?? false) ||
            (course?.title.toLowerCase().contains(q) ?? false);
      }).toList();
    }

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
                    const SizedBox(height: 2),
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
                      style: AppTextStyles.caption,
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
}
