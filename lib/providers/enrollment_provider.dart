import 'package:flutter/foundation.dart';
import '../models/enrollment.dart';
import '../models/enums.dart';
import '../data/dummy_data.dart';
import '../utils/id_generator.dart';

/// Manages enrollment data with business logic validations.
/// Supports the pending → enrolled workflow for professor approval.
class EnrollmentProvider extends ChangeNotifier {
  final List<Enrollment> _enrollments = List.from(DummyData.enrollments);

  /// All enrollments.
  List<Enrollment> get enrollments => List.unmodifiable(_enrollments);

  /// Active enrollments only (status == enrolled).
  List<Enrollment> get activeEnrollments =>
      _enrollments.where((e) => e.status == EnrollmentStatus.enrolled).toList();

  /// Pending enrollments awaiting professor approval.
  List<Enrollment> get pendingEnrollments =>
      _enrollments.where((e) => e.status == EnrollmentStatus.pending).toList();

  /// Dropped enrollments.
  List<Enrollment> get droppedEnrollments =>
      _enrollments.where((e) => e.status == EnrollmentStatus.dropped).toList();

  /// Completed enrollments.
  List<Enrollment> get completedEnrollments =>
      _enrollments
          .where((e) => e.status == EnrollmentStatus.completed)
          .toList();

  /// Returns all enrollments for a specific student.
  List<Enrollment> getEnrollmentsForStudent(String studentId) {
    return _enrollments.where((e) => e.studentId == studentId).toList();
  }

  /// Returns active enrollments for a specific student.
  List<Enrollment> getActiveEnrollmentsForStudent(String studentId) {
    return _enrollments
        .where((e) =>
            e.studentId == studentId && e.status == EnrollmentStatus.enrolled)
        .toList();
  }

  /// Returns pending enrollments for a specific student.
  List<Enrollment> getPendingEnrollmentsForStudent(String studentId) {
    return _enrollments
        .where((e) =>
            e.studentId == studentId && e.status == EnrollmentStatus.pending)
        .toList();
  }

  /// Returns completed enrollments for a specific student.
  List<Enrollment> getCompletedEnrollmentsForStudent(String studentId) {
    return _enrollments
        .where((e) =>
            e.studentId == studentId && e.status == EnrollmentStatus.completed)
        .toList();
  }

  /// Returns non-active enrollments for a specific student (dropped + completed).
  List<Enrollment> getHistoryForStudent(String studentId) {
    return _enrollments
        .where((e) =>
            e.studentId == studentId &&
            (e.status == EnrollmentStatus.dropped ||
                e.status == EnrollmentStatus.completed))
        .toList();
  }

  /// Returns all enrollments for a specific course.
  List<Enrollment> getEnrollmentsForCourse(String courseId) {
    return _enrollments.where((e) => e.courseId == courseId).toList();
  }

  /// Returns active enrollments for a specific course.
  List<Enrollment> getActiveEnrollmentsForCourse(String courseId) {
    return _enrollments
        .where((e) =>
            e.courseId == courseId && e.status == EnrollmentStatus.enrolled)
        .toList();
  }

  /// Counts currently enrolled students in a course (only confirmed enrollments).
  int getEnrolledCount(String courseId) {
    return _enrollments
        .where((e) =>
            e.courseId == courseId && e.status == EnrollmentStatus.enrolled)
        .length;
  }

  /// Checks if a student is currently enrolled in a course.
  bool isStudentEnrolledInCourse(String studentId, String courseId) {
    return _enrollments.any((e) =>
        e.studentId == studentId &&
        e.courseId == courseId &&
        e.status == EnrollmentStatus.enrolled);
  }

  /// Checks if a student has a pending enrollment for a course.
  bool isStudentPendingInCourse(String studentId, String courseId) {
    return _enrollments.any((e) =>
        e.studentId == studentId &&
        e.courseId == courseId &&
        e.status == EnrollmentStatus.pending);
  }

  /// Checks if a student has completed a course.
  bool hasStudentCompletedCourse(String studentId, String courseId) {
    return _enrollments.any((e) =>
        e.studentId == studentId &&
        e.courseId == courseId &&
        e.status == EnrollmentStatus.completed);
  }

  /// Student requests enrollment in a course (creates PENDING enrollment).
  /// Returns a result message (null on success, error string on failure).
  String? requestEnrollment({
    required String studentId,
    required String courseId,
    required int courseCapacity,
    String? prerequisiteCourseId,
  }) {
    // Check duplicate enrollment
    if (isStudentEnrolledInCourse(studentId, courseId)) {
      return 'You are already enrolled in this course.';
    }

    // Check pending
    if (isStudentPendingInCourse(studentId, courseId)) {
      return 'You already have a pending enrollment for this course.';
    }

    // Check capacity
    final enrolled = getEnrolledCount(courseId);
    if (enrolled >= courseCapacity) {
      return 'This course is already at full capacity.';
    }

    // Check prerequisite
    if (prerequisiteCourseId != null && prerequisiteCourseId.isNotEmpty) {
      if (!hasStudentCompletedCourse(studentId, prerequisiteCourseId)) {
        return 'Prerequisite course has not been completed.';
      }
    }

    // Create pending enrollment
    _enrollments.add(Enrollment(
      id: IdGenerator.newEnrollmentId(),
      studentId: studentId,
      courseId: courseId,
      enrollmentDate: DateTime.now(),
      status: EnrollmentStatus.pending,
    ));
    notifyListeners();
    return null; // Success
  }

  /// Professor approves a pending enrollment.
  bool approveEnrollment(String enrollmentId) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index == -1) return false;
    if (_enrollments[index].status != EnrollmentStatus.pending) return false;

    _enrollments[index].status = EnrollmentStatus.enrolled;
    notifyListeners();
    return true;
  }

  /// Professor rejects a pending enrollment (removes it so student can re-apply).
  bool rejectEnrollment(String enrollmentId) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index == -1) return false;
    if (_enrollments[index].status != EnrollmentStatus.pending) return false;

    _enrollments.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Drops a student from a course.
  bool dropEnrollment(String enrollmentId) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index == -1) return false;

    _enrollments[index].status = EnrollmentStatus.dropped;
    notifyListeners();
    return true;
  }

  /// Marks an enrollment as completed (professor action).
  bool markCompleted(String enrollmentId) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index == -1) return false;
    if (_enrollments[index].status != EnrollmentStatus.enrolled) return false;

    _enrollments[index].status = EnrollmentStatus.completed;
    notifyListeners();
    return true;
  }

  /// Updates the grade for a completed enrollment.
  bool updateGrade(String enrollmentId, double grade) {
    final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
    if (index == -1) return false;
    if (_enrollments[index].status != EnrollmentStatus.completed) return false;

    _enrollments[index].grade = grade;
    notifyListeners();
    return true;
  }

  /// Returns the most recent enrollments, sorted by date descending.
  List<Enrollment> getRecentEnrollments({int limit = 5}) {
    final sorted = List<Enrollment>.from(_enrollments)
      ..sort((a, b) => b.enrollmentDate.compareTo(a.enrollmentDate));
    return sorted.take(limit).toList();
  }

  /// Searches enrollments (requires student/course names to be passed externally).
  List<Enrollment> filterByStatus(EnrollmentStatus? status) {
    if (status == null) return enrollments;
    return _enrollments.where((e) => e.status == status).toList();
  }
}
