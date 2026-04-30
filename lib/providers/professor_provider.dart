import 'package:flutter/foundation.dart';
import '../data/dummy_data.dart';
import '../models/professor.dart';

/// Manages in-memory professor records and credentials.
class ProfessorProvider extends ChangeNotifier {
  final List<Professor> _professors = List.from(DummyData.professors);

  List<Professor> get professors => List.unmodifiable(_professors);

  Professor? getProfessorById(String id) {
    try {
      return _professors.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool updateCredentials(String currentId, {String? newId, String? password}) {
    final index = _professors.indexWhere((p) => p.id == currentId);
    if (index == -1) return false;

    final targetId = (newId == null || newId.trim().isEmpty)
        ? currentId
        : newId.trim();
    final duplicate = _professors.any(
      (p) => p.id == targetId && p.id != currentId,
    );
    if (duplicate) return false;

    _professors[index] = _professors[index].copyWith(
      id: targetId,
      password: password?.trim().isNotEmpty == true
          ? password!.trim()
          : _professors[index].password,
    );
    notifyListeners();
    return true;
  }
}
