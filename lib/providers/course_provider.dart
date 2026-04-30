import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/enums.dart';
import '../data/dummy_data.dart';
import '../utils/id_generator.dart';

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
        (c) => c.courseCode.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Adds a new course and returns the generated ID.
  String addCourse({
    required String courseCode,
    required String title,
    required String description,
    required int capacity,
    required int units,
    required String schedule,
    required String instructor,
    String? professorId,
    String? prerequisiteCourseId,
    required CourseCategory category,
  }) {
    final id = IdGenerator.newCourseId();
    _courses.add(
      Course(
        id: id,
        courseCode: courseCode,
        title: title,
        description: description,
        capacity: capacity,
        units: units,
        schedule: schedule,
        instructor: instructor,
        professorId: professorId,
        prerequisiteCourseId: prerequisiteCourseId,
        category: category,
      ),
    );
    notifyListeners();
    return id;
  }

  /// Updates an existing course.
  bool updateCourse(
    String id, {
    String? courseCode,
    String? title,
    String? description,
    int? capacity,
    int? units,
    String? schedule,
    String? instructor,
    String? professorId,
    String? prerequisiteCourseId,
    CourseCategory? category,
  }) {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    _courses[index] = _courses[index].copyWith(
      courseCode: courseCode,
      title: title,
      description: description,
      capacity: capacity,
      units: units,
      schedule: schedule,
      instructor: instructor,
      professorId: professorId,
      prerequisiteCourseId: prerequisiteCourseId,
      category: category,
    );
    notifyListeners();
    return true;
  }

  /// Removes a course by ID.
  bool removeCourse(String id) {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    _courses.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Searches courses by code, title, or instructor.
  List<Course> search(String query) {
    if (query.isEmpty) return courses;
    final q = query.toLowerCase();
    return _courses
        .where(
          (c) =>
              c.courseCode.toLowerCase().contains(q) ||
              c.title.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Filters courses by category.
  List<Course> filterByCategory(CourseCategory? category) {
    if (category == null) return courses;
    return _courses.where((c) => c.category == category).toList();
  }

  List<Course> getCoursesForProfessor(String professorId) {
    return _courses.where((c) => c.professorId == professorId).toList();
  }

  void reassignProfessorId(String oldId, String newId) {
    for (var i = 0; i < _courses.length; i++) {
      if (_courses[i].professorId == oldId) {
        _courses[i] = _courses[i].copyWith(professorId: newId);
      }
    }
    notifyListeners();
  }
}
