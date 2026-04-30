import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../data/dummy_data.dart';
import '../utils/id_generator.dart';

/// Manages in-memory student data with CRUD operations.
class StudentProvider extends ChangeNotifier {
  final List<Student> _students = List.from(DummyData.students);

  /// All students.
  List<Student> get students => List.unmodifiable(_students);

  /// Returns a student by ID, or null if not found.
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Updates a student's login ID and/or password.
  bool updateCredentials(String currentId, {String? newId, String? password}) {
    final index = _students.indexWhere((s) => s.id == currentId);
    if (index == -1) return false;

    final targetId = (newId == null || newId.trim().isEmpty)
        ? currentId
        : newId.trim();
    final duplicate = _students.any(
      (s) => s.id == targetId && s.id != currentId,
    );
    if (duplicate) return false;

    _students[index] = _students[index].copyWith(
      id: targetId,
      password: password?.trim().isNotEmpty == true
          ? password!.trim()
          : _students[index].password,
    );
    notifyListeners();
    return true;
  }

  /// Adds a new student and returns the generated ID.
  String addStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String program,
    required int yearLevel,
  }) {
    final id = IdGenerator.newStudentId();
    _students.add(
      Student(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        program: program,
        yearLevel: yearLevel,
        dateEnrolled: DateTime.now(),
        password: id, // Default password is the student ID
      ),
    );
    notifyListeners();
    return id;
  }

  /// Searches students by name, ID, or program.
  List<Student> search(String query) {
    if (query.isEmpty) return students;
    final q = query.toLowerCase();
    return _students
        .where(
          (s) =>
              s.fullName.toLowerCase().contains(q) ||
              s.id.toLowerCase().contains(q) ||
              s.program.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Filters students by program and/or year level.
  List<Student> filter({String? program, int? yearLevel}) {
    return _students.where((s) {
      if (program != null && s.program != program) return false;
      if (yearLevel != null && s.yearLevel != yearLevel) return false;
      return true;
    }).toList();
  }
}
