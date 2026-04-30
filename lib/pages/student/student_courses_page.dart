import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/capacity_bar.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});
  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CourseCategory? _category;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final studentId = auth.currentUserId ?? '';
    var list = _query.isNotEmpty ? cp.search(_query) : cp.courses;
    if (_category != null) list = list.where((c) => c.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Browse Courses', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text('Find and enroll in courses', style: AppTextStyles.caption),
            const SizedBox(height: 16),
            CustomSearchBar(controller: _searchCtrl, hintText: 'Search courses...', onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _catChip('All', null),
                ...CourseCategory.values.map((c) => _catChip(c.shortLabel, c)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(icon: Icons.menu_book_outlined, title: 'No courses found')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, i) => _buildCourseCard(list[i], studentId, ep, cp),
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCourseCard(dynamic course, String studentId, EnrollmentProvider ep, CourseProvider cp) {
    final enrolled = ep.getEnrolledCount(course.id);
    final isFull = enrolled >= course.capacity;
    final isEnrolled = ep.isStudentEnrolledInCourse(studentId, course.id);
    final isPending = ep.isStudentPendingInCourse(studentId, course.id);
    final hasCompleted = ep.hasStudentCompletedCourse(studentId, course.id);
    bool hasPrereq = true;
    String? prereqWarning;
    if (course.prerequisiteCourseId != null) {
      hasPrereq = ep.hasStudentCompletedCourse(studentId, course.prerequisiteCourseId!);
      if (!hasPrereq) {
        final pc = cp.getCourseById(course.prerequisiteCourseId!);
        prereqWarning = 'Requires ${pc?.courseCode ?? 'prerequisite'}';
      }
    }
    final canEnroll = !isFull && !isEnrolled && !isPending && hasPrereq && !hasCompleted;

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(course.courseCode, style: AppTextStyles.subheading.copyWith(color: AppColors.primary)),
          const Spacer(),
          _statusBadge(isEnrolled, isPending, hasCompleted, isFull, course.capacity - enrolled),
        ]),
        const SizedBox(height: 4),
        Text(course.title, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(course.instructor, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(course.schedule, style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 4),
        Text('${course.units} units', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CapacityBar(enrolled: enrolled, capacity: course.capacity),
        if (course.prerequisiteCourseId != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(hasPrereq ? Icons.check_circle : Icons.warning_amber_rounded, size: 14, color: hasPrereq ? AppColors.success : AppColors.warning),
            const SizedBox(width: 6),
            Expanded(child: Text(
              hasPrereq ? 'Prerequisite ${cp.getCourseById(course.prerequisiteCourseId!)?.courseCode ?? ''} ✓' : prereqWarning ?? 'Prerequisite not met',
              style: AppTextStyles.caption.copyWith(color: hasPrereq ? AppColors.success : AppColors.warning, fontSize: 11),
            )),
          ]),
        ],
        if (canEnroll) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Enroll in Course'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => _requestEnrollment(course, studentId, ep),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _statusBadge(bool isEnrolled, bool isPending, bool hasCompleted, bool isFull, int slots) {
    if (isEnrolled) return _badge('ENROLLED', AppColors.success);
    if (isPending) return _badge('PENDING', AppColors.warning);
    if (hasCompleted) return _badge('COMPLETED', AppColors.secondary);
    if (isFull) return _badge('FULL', AppColors.error);
    return _badge('$slots slots', AppColors.success);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _requestEnrollment(dynamic course, String studentId, EnrollmentProvider ep) async {
    final confirmed = await showConfirmDialog(context, title: 'Enroll in ${course.courseCode}?', message: 'Your request for "${course.title}" will be sent for professor approval.');
    if (confirmed != true || !mounted) return;
    final result = ep.requestEnrollment(studentId: studentId, courseId: course.id, courseCapacity: course.capacity, prerequisiteCourseId: course.prerequisiteCourseId);
    if (!mounted) return;
    if (result != null) {
      showAppSnackbar(context, message: result, type: SnackbarType.error);
    } else {
      showAppSnackbar(context, message: 'Request submitted! Waiting for approval.', type: SnackbarType.success);
    }
  }

  Widget _catChip(String label, CourseCategory? cat) {
    final sel = _category == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: sel, onSelected: (_) => setState(() => _category = cat), selectedColor: AppColors.primary.withValues(alpha: 0.2), side: BorderSide(color: sel ? AppColors.primary : AppColors.divider), labelStyle: TextStyle(color: sel ? AppColors.primary : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
    );
  }
}
