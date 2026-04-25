import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../providers/student_provider.dart';
import '../providers/course_provider.dart';
import '../providers/enrollment_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/student_avatar.dart';
import '../widgets/capacity_bar.dart';
import '../widgets/app_snackbar.dart';

/// Multi-step enrollment dialog.
class EnrollmentDialog extends StatefulWidget {
  /// If provided, pre-selects the student.
  final String? preselectedStudentId;

  /// If provided, pre-selects the course.
  final String? preselectedCourseId;

  const EnrollmentDialog({
    super.key,
    this.preselectedStudentId,
    this.preselectedCourseId,
  });

  @override
  State<EnrollmentDialog> createState() => _EnrollmentDialogState();
}

class _EnrollmentDialogState extends State<EnrollmentDialog> {
  int _step =
      0; // 0 = select student, 1 = select course, 2 = confirm, 3 = success
  Student? _selectedStudent;
  Course? _selectedCourse;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedStudentId != null) {
      final studentProvider = context.read<StudentProvider>();
      _selectedStudent = studentProvider.getStudentById(
        widget.preselectedStudentId!,
      );
      if (_selectedStudent != null) _step = 1;
    }
    if (widget.preselectedCourseId != null) {
      final courseProvider = context.read<CourseProvider>();
      _selectedCourse = courseProvider.getCourseById(
        widget.preselectedCourseId!,
      );
      if (_selectedCourse != null && _selectedStudent != null) _step = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 20),
          // Content
          Flexible(child: _buildStepContent()),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Student', 'Course', 'Confirm'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= _step;
        final isCurrent = i == _step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  color: isActive ? null : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: i < _step
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  steps[i],
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    if (_step == 3) return _buildSuccess();
    switch (_step) {
      case 0:
        return _buildStudentSelection();
      case 1:
        return _buildCourseSelection();
      case 2:
        return _buildConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStudentSelection() {
    final students = context.watch<StudentProvider>().students;
    final filtered = _searchQuery.isEmpty
        ? students
        : students
              .where(
                (s) =>
                    s.fullName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    s.id.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Student', style: AppTextStyles.subheading),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search students...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final student = filtered[index];
              return ListTile(
                leading: StudentAvatar(
                  initials: student.initials,
                  colorIndex: students.indexOf(student),
                  size: 40,
                ),
                title: Text(
                  student.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${student.id} • ${student.program}',
                  style: AppTextStyles.caption,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  setState(() {
                    _selectedStudent = student;
                    _step = 1;
                    _searchQuery = '';
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelection() {
    final courses = context.watch<CourseProvider>().courses;
    final enrollmentProvider = context.watch<EnrollmentProvider>();
    final filtered = _searchQuery.isEmpty
        ? courses
        : courses
              .where(
                (c) =>
                    c.courseCode.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    c.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => setState(() {
                _step = 0;
                _searchQuery = '';
              }),
            ),
            Text('Select Course', style: AppTextStyles.subheading),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search courses...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final course = filtered[index];
              final enrolled = enrollmentProvider.getEnrolledCount(course.id);
              final isFull = enrolled >= course.capacity;
              final isAlreadyEnrolled =
                  _selectedStudent != null &&
                  enrollmentProvider.isStudentEnrolledInCourse(
                    _selectedStudent!.id,
                    course.id,
                  );

              // Check prerequisite
              bool hasPrereq = true;
              String? prereqWarning;
              if (course.prerequisiteCourseId != null &&
                  _selectedStudent != null) {
                hasPrereq = enrollmentProvider.hasStudentCompletedCourse(
                  _selectedStudent!.id,
                  course.prerequisiteCourseId!,
                );
                if (!hasPrereq) {
                  final prereqCourse = context
                      .read<CourseProvider>()
                      .getCourseById(course.prerequisiteCourseId!);
                  prereqWarning =
                      'Requires ${prereqCourse?.courseCode ?? 'prerequisite'}';
                }
              }

              final isDisabled = isFull || isAlreadyEnrolled || !hasPrereq;

              return Opacity(
                opacity: isDisabled ? 0.4 : 1.0,
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        course.courseCode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isFull) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FULL',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (isAlreadyEnrolled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ENROLLED',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      CapacityBar(
                        enrolled: enrolled,
                        capacity: course.capacity,
                        height: 4,
                        showLabel: false,
                      ),
                      if (prereqWarning != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          prereqWarning,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: isDisabled
                      ? null
                      : () {
                          setState(() {
                            _selectedCourse = course;
                            _step = 2;
                            _searchQuery = '';
                          });
                        },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => setState(() => _step = 1),
            ),
            Text('Confirm Enrollment', style: AppTextStyles.subheading),
          ],
        ),
        const SizedBox(height: 20),
        // Student info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              StudentAvatar(
                initials: _selectedStudent!.initials,
                colorIndex: 0,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStudent!.fullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_selectedStudent!.id} • ${_selectedStudent!.program}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Arrow
        const Center(
          child: Icon(
            Icons.arrow_downward_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        // Course info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCourse!.courseCode,
                style: AppTextStyles.subheading.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(_selectedCourse!.title, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(_selectedCourse!.schedule, style: AppTextStyles.caption),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.person,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCourse!.instructor,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _performEnrollment,
              child: Text('Confirm Enrollment', style: AppTextStyles.button),
            ),
          ),
        ),
      ],
    );
  }

  void _performEnrollment() {
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final result = enrollmentProvider.enrollStudent(
      studentId: _selectedStudent!.id,
      courseId: _selectedCourse!.id,
      courseCapacity: _selectedCourse!.capacity,
      prerequisiteCourseId: _selectedCourse!.prerequisiteCourseId,
    );

    if (result != null) {
      showAppSnackbar(context, message: result, type: SnackbarType.error);
    } else {
      setState(() => _step = 3);
    }
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Enrollment Successful!', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        Text(
          '${_selectedStudent!.fullName} has been enrolled in ${_selectedCourse!.courseCode}',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

/// Shows the enrollment dialog as a modal bottom sheet.
Future<void> showEnrollmentDialog(
  BuildContext context, {
  String? preselectedStudentId,
  String? preselectedCourseId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => EnrollmentDialog(
      preselectedStudentId: preselectedStudentId,
      preselectedCourseId: preselectedCourseId,
    ),
  );
}
