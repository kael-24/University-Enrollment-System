import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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


/// Professor courses page — CRUD management for courses.
class ProfessorCoursesPage extends StatefulWidget {
  const ProfessorCoursesPage({super.key});
  @override
  State<ProfessorCoursesPage> createState() => _ProfessorCoursesPageState();
}

class _ProfessorCoursesPageState extends State<ProfessorCoursesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CourseCategory? _category;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    var list = _query.isNotEmpty ? cp.search(_query) : cp.courses;
    if (_category != null) list = list.where((c) => c.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Manage Courses', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text('${cp.courses.length} courses', style: AppTextStyles.caption),
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
                      itemBuilder: (ctx, i) {
                        final c = list[i];
                        final enrolled = ep.getEnrolledCount(c.id);
                        return GlassCard(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(c.courseCode, style: AppTextStyles.subheading.copyWith(color: AppColors.primary)),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary), onPressed: () => _showEditCourse(context, c, cp)),
                              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () => _deleteCourse(context, c, cp)),
                            ]),
                            Text(c.title, style: AppTextStyles.bodyLarge),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(child: Text(c.instructor, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 12),
                              const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(c.schedule, style: AppTextStyles.caption),
                            ]),
                            const SizedBox(height: 4),
                            Text('${c.units} units • ${c.category.shortLabel}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            CapacityBar(enrolled: enrolled, capacity: c.capacity),
                          ]),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourse(context, cp),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddCourse(BuildContext context, CourseProvider cp) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '40');
    final unitsCtrl = TextEditingController(text: '3');
    final schedCtrl = TextEditingController();
    final instrCtrl = TextEditingController();
    CourseCategory cat = CourseCategory.cs;

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Add New Course', style: AppTextStyles.headingSmall),
          const SizedBox(height: 20),
          TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Course Code', hintText: 'e.g., CS 401', prefixIcon: Icon(Icons.tag))),
          const SizedBox(height: 12),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title))),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)), maxLines: 2),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Capacity', prefixIcon: Icon(Icons.people_outline)), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: unitsCtrl, decoration: const InputDecoration(labelText: 'Units', prefixIcon: Icon(Icons.book_outlined)), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: schedCtrl, decoration: const InputDecoration(labelText: 'Schedule', hintText: 'e.g., MWF 9:00-10:00 AM', prefixIcon: Icon(Icons.schedule))),
          const SizedBox(height: 12),
          TextField(controller: instrCtrl, decoration: const InputDecoration(labelText: 'Instructor', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          DropdownButtonFormField<CourseCategory>(value: cat, items: CourseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(), onChanged: (v) => ss(() => cat = v!), decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)), dropdownColor: AppColors.surface),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: Container(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (codeCtrl.text.isNotEmpty && titleCtrl.text.isNotEmpty) {
                  cp.addCourse(courseCode: codeCtrl.text.trim(), title: titleCtrl.text.trim(), description: descCtrl.text.trim(), capacity: int.tryParse(capCtrl.text) ?? 40, units: int.tryParse(unitsCtrl.text) ?? 3, schedule: schedCtrl.text.trim(), instructor: instrCtrl.text.trim(), category: cat);
                  Navigator.pop(ctx);
                  showAppSnackbar(context, message: 'Course added successfully', type: SnackbarType.success);
                }
              },
              child: Text('Add Course', style: AppTextStyles.button),
            ),
          )),
        ])),
      )),
    );
  }

  void _showEditCourse(BuildContext context, dynamic course, CourseProvider cp) {
    final codeCtrl = TextEditingController(text: course.courseCode);
    final titleCtrl = TextEditingController(text: course.title);
    final descCtrl = TextEditingController(text: course.description);
    final capCtrl = TextEditingController(text: course.capacity.toString());
    final unitsCtrl = TextEditingController(text: course.units.toString());
    final schedCtrl = TextEditingController(text: course.schedule);
    final instrCtrl = TextEditingController(text: course.instructor);
    CourseCategory cat = course.category;

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Edit Course', style: AppTextStyles.headingSmall),
          const SizedBox(height: 20),
          TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Course Code', prefixIcon: Icon(Icons.tag))),
          const SizedBox(height: 12),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title))),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)), maxLines: 2),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: unitsCtrl, decoration: const InputDecoration(labelText: 'Units'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: schedCtrl, decoration: const InputDecoration(labelText: 'Schedule', prefixIcon: Icon(Icons.schedule))),
          const SizedBox(height: 12),
          TextField(controller: instrCtrl, decoration: const InputDecoration(labelText: 'Instructor', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          DropdownButtonFormField<CourseCategory>(value: cat, items: CourseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(), onChanged: (v) => ss(() => cat = v!), decoration: const InputDecoration(labelText: 'Category'), dropdownColor: AppColors.surface),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: Container(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                cp.updateCourse(course.id, courseCode: codeCtrl.text.trim(), title: titleCtrl.text.trim(), description: descCtrl.text.trim(), capacity: int.tryParse(capCtrl.text) ?? course.capacity, units: int.tryParse(unitsCtrl.text) ?? course.units, schedule: schedCtrl.text.trim(), instructor: instrCtrl.text.trim(), category: cat);
                Navigator.pop(ctx);
                showAppSnackbar(context, message: 'Course updated', type: SnackbarType.success);
              },
              child: Text('Save Changes', style: AppTextStyles.button),
            ),
          )),
        ])),
      )),
    );
  }

  void _deleteCourse(BuildContext context, dynamic course, CourseProvider cp) async {
    final confirmed = await showConfirmDialog(context, title: 'Delete ${course.courseCode}?', message: 'This will permanently remove "${course.title}". This action cannot be undone.');
    if (confirmed != true || !mounted) return;
    cp.removeCourse(course.id);
    if (mounted) showAppSnackbar(context, message: 'Course deleted', type: SnackbarType.warning);
  }

  Widget _catChip(String label, CourseCategory? cat) {
    final sel = _category == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: sel, onSelected: (_) => setState(() => _category = cat), selectedColor: AppColors.primary.withValues(alpha: 0.2), side: BorderSide(color: sel ? AppColors.primary : AppColors.divider), labelStyle: TextStyle(color: sel ? AppColors.primary : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
    );
  }
}
