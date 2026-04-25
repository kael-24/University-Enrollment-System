import 'enums.dart';

/// Represents a course offered in the enrollment system.
class Course {
  final String id;
  final String courseCode;
  final String title;
  final String description;
  final int capacity;
  final int units;
  final String schedule;
  final String instructor;
  final String? prerequisiteCourseId;
  final CourseCategory category;

  Course({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.description,
    required this.capacity,
    required this.units,
    required this.schedule,
    required this.instructor,
    this.prerequisiteCourseId,
    required this.category,
  });

  /// Creates a copy with optional overrides.
  Course copyWith({
    String? id,
    String? courseCode,
    String? title,
    String? description,
    int? capacity,
    int? units,
    String? schedule,
    String? instructor,
    String? prerequisiteCourseId,
    CourseCategory? category,
  }) {
    return Course(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      title: title ?? this.title,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      units: units ?? this.units,
      schedule: schedule ?? this.schedule,
      instructor: instructor ?? this.instructor,
      prerequisiteCourseId: prerequisiteCourseId ?? this.prerequisiteCourseId,
      category: category ?? this.category,
    );
  }
}
