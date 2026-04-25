/// Utility class for generating unique IDs.
class IdGenerator {
  static int _studentCounter = 10;
  static int _courseCounter = 10;
  static int _enrollmentCounter = 20;

  /// Generates a new unique student ID (e.g., "STU-011").
  static String newStudentId() {
    _studentCounter++;
    return 'STU-${_studentCounter.toString().padLeft(3, '0')}';
  }

  /// Generates a new unique course ID (e.g., "CRS-011").
  static String newCourseId() {
    _courseCounter++;
    return 'CRS-${_courseCounter.toString().padLeft(3, '0')}';
  }

  /// Generates a new unique enrollment ID (e.g., "ENR-021").
  static String newEnrollmentId() {
    _enrollmentCounter++;
    return 'ENR-${_enrollmentCounter.toString().padLeft(3, '0')}';
  }
}
