import 'package:intl/intl.dart';

/// Date and grade formatting helpers.
class Formatters {
  Formatters._();

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MM/dd/yy');

  /// Formats a DateTime to "Jan 15, 2026" style.
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formats a DateTime to "01/15/26" style.
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Converts a numeric grade (1.0-5.0) to a display string.
  static String formatGrade(double? grade) {
    if (grade == null) return 'N/A';
    return grade.toStringAsFixed(1);
  }

  /// Returns a descriptive label for a numeric grade.
  static String gradeLabel(double grade) {
    if (grade <= 1.25) return 'Excellent';
    if (grade <= 1.75) return 'Very Good';
    if (grade <= 2.25) return 'Good';
    if (grade <= 2.75) return 'Satisfactory';
    if (grade <= 3.0) return 'Passing';
    return 'Failing';
  }
}
