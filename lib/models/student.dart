/// Represents a student in the enrollment system.
/// Student IDs follow the YYYY-CODE-LETTER format (e.g., "2023-2735-A").
class Student {
  final String id; // YYYY-CODE-LETTER format
  final String firstName;
  final String lastName;
  final String email;
  final String program;
  final int yearLevel;
  final DateTime dateEnrolled;
  final String password; // Simple in-memory password

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.program,
    required this.yearLevel,
    required this.dateEnrolled,
    this.password = '', // Defaults to student ID if empty
  });

  /// Full name of the student.
  String get fullName => '$firstName $lastName';

  /// Initials for avatar display (first letter of first and last name).
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  /// Creates a copy of this student with optional overrides.
  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? program,
    int? yearLevel,
    DateTime? dateEnrolled,
    String? password,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      program: program ?? this.program,
      yearLevel: yearLevel ?? this.yearLevel,
      dateEnrolled: dateEnrolled ?? this.dateEnrolled,
      password: password ?? this.password,
    );
  }
}
