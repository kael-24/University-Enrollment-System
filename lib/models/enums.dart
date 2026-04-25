/// Enrollment status for tracking student-course relationships.
enum EnrollmentStatus {
  enrolled,
  dropped,
  completed;

  /// Display-friendly label.
  String get label {
    switch (this) {
      case EnrollmentStatus.enrolled:
        return 'Enrolled';
      case EnrollmentStatus.dropped:
        return 'Dropped';
      case EnrollmentStatus.completed:
        return 'Completed';
    }
  }
}

/// Course category classification.
enum CourseCategory {
  cs,
  it,
  math,
  genEd,
  science;

  /// Display-friendly label.
  String get label {
    switch (this) {
      case CourseCategory.cs:
        return 'Computer Science';
      case CourseCategory.it:
        return 'Information Technology';
      case CourseCategory.math:
        return 'Mathematics';
      case CourseCategory.genEd:
        return 'General Education';
      case CourseCategory.science:
        return 'Science';
    }
  }

  /// Short label for chips and tabs.
  String get shortLabel {
    switch (this) {
      case CourseCategory.cs:
        return 'CS';
      case CourseCategory.it:
        return 'IT';
      case CourseCategory.math:
        return 'Math';
      case CourseCategory.genEd:
        return 'Gen Ed';
      case CourseCategory.science:
        return 'Science';
    }
  }
}
