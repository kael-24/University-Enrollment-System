import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/capacity_bar.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/enrollment_dialog.dart';
import '../../utils/formatters.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final sp = context.watch<StudentProvider>();
    final ep = context.watch<EnrollmentProvider>();
    final course = cp.getCourseById(courseId);

    if (course == null) {
      return Scaffold(backgroundColor: AppColors.background, body: const Center(child: Text('Course not found')));
    }

    final enrolled = ep.getEnrolledCount(courseId);
    final activeEnrollments = ep.getActiveEnrollmentsForCourse(courseId);
    final prereq = course.prerequisiteCourseId != null ? cp.getCourseById(course.prerequisiteCourseId!) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.secondary.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(course.category.shortLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                const Spacer(),
                Text('${course.units} units', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              Text(course.courseCode, style: AppTextStyles.heading.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(course.title, style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              CapacityBar(enrolled: enrolled, capacity: course.capacity),
            ]),
          ),
          const SizedBox(height: 20),

          // Info section
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Course Information', style: AppTextStyles.subheading),
              const SizedBox(height: 12),
              Text(course.description, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5)),
              const Divider(color: AppColors.divider, height: 24),
              _infoRow(Icons.person_outline, 'Instructor', course.instructor),
              _infoRow(Icons.schedule, 'Schedule', course.schedule),
              _infoRow(Icons.book_outlined, 'Units', '${course.units}'),
              if (prereq != null) _infoRow(Icons.lock_outline, 'Prerequisite', prereq.courseCode),
            ]),
          ),
          const SizedBox(height: 20),

          // Enrolled students
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Enrolled Students', style: AppTextStyles.subheading),
            Text('${activeEnrollments.length}', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          if (activeEnrollments.isEmpty)
            const EmptyState(icon: Icons.people_outline, title: 'No students enrolled', subtitle: 'Be the first to enroll a student')
          else
            ...activeEnrollments.map((e) {
              final student = sp.getStudentById(e.studentId);
              if (student == null) return const SizedBox.shrink();
              final gi = sp.students.indexOf(student);
              return GlassCard(
                child: Row(children: [
                  StudentAvatar(initials: student.initials, colorIndex: gi, size: 40),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(student.fullName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('${student.program} • ${Formatters.formatShortDate(e.enrollmentDate)}', style: AppTextStyles.caption),
                  ])),
                ]),
              );
            }),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEnrollmentDialog(context, preselectedCourseId: courseId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Enroll Student'),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyles.caption),
        Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
