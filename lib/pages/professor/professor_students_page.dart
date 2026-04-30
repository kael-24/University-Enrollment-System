import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/grade_input_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../utils/formatters.dart';

/// Professor students page — view students, their enrollments, and assign grades.
class ProfessorStudentsPage extends StatefulWidget {
  const ProfessorStudentsPage({super.key});
  @override
  State<ProfessorStudentsPage> createState() => _ProfessorStudentsPageState();
}

class _ProfessorStudentsPageState extends State<ProfessorStudentsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _expandedStudentId;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    var list = _query.isNotEmpty ? sp.search(_query) : sp.students;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Students', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text('${sp.students.length} registered students', style: AppTextStyles.caption),
            const SizedBox(height: 16),
            CustomSearchBar(controller: _searchCtrl, hintText: 'Search by name, ID, or program...', onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(icon: Icons.people_outline, title: 'No students found')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final s = list[i];
                        final gi = sp.students.indexOf(s);
                        final enrollments = ep.getEnrollmentsForStudent(s.id);
                        final activeCount = ep.getActiveEnrollmentsForStudent(s.id).length;
                        final isExpanded = _expandedStudentId == s.id;

                        return GlassCard(
                          onTap: () => setState(() => _expandedStudentId = isExpanded ? null : s.id),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              StudentAvatar(initials: s.initials, colorIndex: gi, size: 48),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s.fullName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                                Text('${s.id} • ${s.program}', style: AppTextStyles.caption),
                                Text('Year ${s.yearLevel}', style: AppTextStyles.caption),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                child: Text('$activeCount courses', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 4),
                              Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
                            ]),
                            // Expanded section — show enrollments
                            if (isExpanded) ...[
                              const Divider(color: AppColors.divider, height: 24),
                              if (enrollments.isEmpty)
                                Text('No enrollments', style: AppTextStyles.caption)
                              else
                                ...enrollments.map((e) {
                                  final course = cp.getCourseById(e.courseId);
                                  if (course == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(children: [
                                      Container(
                                        width: 4, height: 36,
                                        decoration: BoxDecoration(
                                          color: e.status == EnrollmentStatus.enrolled ? AppColors.success : e.status == EnrollmentStatus.pending ? AppColors.warning : e.status == EnrollmentStatus.completed ? AppColors.secondary : AppColors.error,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('${course.courseCode} — ${course.title}', style: AppTextStyles.body.copyWith(fontSize: 13)),
                                        Text(Formatters.formatShortDate(e.enrollmentDate), style: AppTextStyles.caption.copyWith(fontSize: 11)),
                                      ])),
                                      StatusChip(status: e.status),
                                      if (e.status == EnrollmentStatus.enrolled) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () async {
                                            final confirmed = await showConfirmDialog(context, title: 'Mark as Completed?', message: 'Mark ${s.fullName}\'s enrollment in ${course.courseCode} as completed?');
                                            if (confirmed == true) {
                                              ep.markCompleted(e.id);
                                              if (context.mounted) showAppSnackbar(context, message: 'Marked as completed', type: SnackbarType.success);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                            child: const Icon(Icons.done_all, size: 16, color: AppColors.secondary),
                                          ),
                                        ),
                                      ],
                                      if (e.status == EnrollmentStatus.completed) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () async {
                                            final grade = await showGradeInputSheet(context, currentGrade: e.grade);
                                            if (grade != null) {
                                              ep.updateGrade(e.id, grade);
                                              if (context.mounted) showAppSnackbar(context, message: 'Grade updated to ${grade.toStringAsFixed(1)}', type: SnackbarType.success);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                            child: Text(e.grade != null ? Formatters.formatGrade(e.grade) : 'Grade', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ]),
                                  );
                                }),
                            ],
                          ]),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudent(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _showAddStudent(BuildContext context) {
    final programs = ['BS Computer Science', 'BS Information Technology', 'BS Mathematics'];
    final fn = TextEditingController(), ln = TextEditingController(), em = TextEditingController();
    String prog = programs[0]; int yr = 1;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Add New Student', style: AppTextStyles.headingSmall),
          const SizedBox(height: 20),
          TextField(controller: fn, decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: ln, decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: em, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: prog, items: programs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (v) => ss(() => prog = v!), decoration: const InputDecoration(labelText: 'Program', prefixIcon: Icon(Icons.school_outlined)), dropdownColor: AppColors.surface),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(value: yr, items: [1,2,3,4].map((y) => DropdownMenuItem(value: y, child: Text('Year $y'))).toList(), onChanged: (v) => ss(() => yr = v!), decoration: const InputDecoration(labelText: 'Year Level', prefixIcon: Icon(Icons.calendar_today_outlined)), dropdownColor: AppColors.surface),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: Container(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (fn.text.isNotEmpty && ln.text.isNotEmpty) {
                  final id = context.read<StudentProvider>().addStudent(firstName: fn.text.trim(), lastName: ln.text.trim(), email: em.text.trim().isNotEmpty ? em.text.trim() : '${fn.text.toLowerCase()}.${ln.text.toLowerCase()}@enrollhub.edu', program: prog, yearLevel: yr);
                  Navigator.pop(ctx);
                  showAppSnackbar(context, message: 'Student added (ID: $id)', type: SnackbarType.success);
                }
              },
              child: Text('Add Student', style: AppTextStyles.button),
            ),
          )),
        ]),
      )),
    );
  }
}
