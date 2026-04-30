import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/student.dart';
import '../models/professor.dart';
import '../data/dummy_data.dart';

/// Manages authentication state — tracks logged-in user and their role.
class AuthProvider extends ChangeNotifier {
  UserRole? _currentRole;
  String? _currentUserId;

  /// Currently logged-in role (null if not logged in).
  UserRole? get currentRole => _currentRole;

  /// ID of the currently logged-in user.
  String? get currentUserId => _currentUserId;

  /// Whether any user is logged in.
  bool get isLoggedIn => _currentRole != null && _currentUserId != null;

  /// Whether the logged-in user is a student.
  bool get isStudent => _currentRole == UserRole.student;

  /// Whether the logged-in user is a professor.
  bool get isProfessor => _currentRole == UserRole.professor;

  /// Attempt to log in as a student.
  /// Returns null on success, error message on failure.
  String? loginAsStudent(String studentId, String password) {
    final students = DummyData.students;
    Student? found;
    try {
      found = students.firstWhere((s) => s.id == studentId);
    } catch (_) {
      found = null;
    }

    if (found == null) {
      return 'Student ID not found. Please check your ID.';
    }

    if (found.password.isNotEmpty && found.password != password) {
      return 'Incorrect password.';
    }

    _currentRole = UserRole.student;
    _currentUserId = found.id;
    notifyListeners();
    return null;
  }

  /// Attempt to log in as a professor.
  /// Returns null on success, error message on failure.
  String? loginAsProfessor(String professorId, String password) {
    final professors = DummyData.professors;
    Professor? found;
    try {
      found = professors.firstWhere((p) => p.id == professorId);
    } catch (_) {
      found = null;
    }

    if (found == null) {
      return 'Professor ID not found.';
    }

    if (found.password.isNotEmpty && found.password != password) {
      return 'Incorrect password.';
    }

    _currentRole = UserRole.professor;
    _currentUserId = found.id;
    notifyListeners();
    return null;
  }

  /// Logs out the current user.
  void logout() {
    _currentRole = null;
    _currentUserId = null;
    notifyListeners();
  }
}
