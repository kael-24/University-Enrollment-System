import 'enums.dart';

/// Links a student to a course with status tracking and optional grade.
class Enrollment {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime enrollmentDate;
  EnrollmentStatus status;
  double? grade;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    this.status = EnrollmentStatus.enrolled,
    this.grade,
  });

  /// Creates a copy with optional overrides.
  Enrollment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    DateTime? enrollmentDate,
    EnrollmentStatus? status,
    double? grade,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      status: status ?? this.status,
      grade: grade ?? this.grade,
    );
  }
}
