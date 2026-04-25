import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/enums.dart';
import '../data/dummy_data.dart';

/// Manages in-memory course data with CRUD operations.
class CourseProvider extends ChangeNotifier {
  final List<Course> _courses = List.from(DummyData.courses);

  /// All courses.
  List<Course> get courses => List.unmodifiable(_courses);

  /// Returns a course by ID, or null if not found.
  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns a course by its course code (e.g., "CS 101").
  Course? getCourseByCode(String code) {
    try {
      return _courses.firstWhere(
          (c) => c.courseCode.toLowerCase() == code.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Searches courses by code, title, or instructor.
  List<Course> search(String query) {
    if (query.isEmpty) return courses;
    final q = query.toLowerCase();
    return _courses
        .where((c) =>
            c.courseCode.toLowerCase().contains(q) ||
            c.title.toLowerCase().contains(q) ||
            c.instructor.toLowerCase().contains(q))
        .toList();
  }

  /// Filters courses by category.
  List<Course> filterByCategory(CourseCategory? category) {
    if (category == null) return courses;
    return _courses.where((c) => c.category == category).toList();
  }
}
