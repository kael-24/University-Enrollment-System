import 'dart:math';

/// Utility class for generating unique IDs.
class IdGenerator {
  static int _studentCounter = 10;
  static int _courseCounter = 10;
  static int _enrollmentCounter = 21;
  static final _random = Random();

  /// Generates a new unique student ID in YYYY-CODE-LETTER format.
  /// Example: "2025-1234-A"
  static String newStudentId() {
    _studentCounter++;
    final year = DateTime.now().year;
    final code = (_random.nextInt(9000) + 1000); // 4-digit code
    final letter = String.fromCharCode(65 + (_studentCounter % 26)); // A-Z
    return '$year-$code-$letter';
  }

  /// Generates a new unique course ID (e.g., "CRS-011").
  static String newCourseId() {
    _courseCounter++;
    return 'CRS-${_courseCounter.toString().padLeft(3, '0')}';
  }

  /// Generates a new unique enrollment ID (e.g., "ENR-022").
  static String newEnrollmentId() {
    _enrollmentCounter++;
    return 'ENR-${_enrollmentCounter.toString().padLeft(3, '0')}';
  }
}
