/// Represents a professor in the enrollment system.
class Professor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final String password; // Simple in-memory password

  Professor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    this.password = '',
  });

  /// Full name of the professor.
  String get fullName => '$firstName $lastName';

  /// Formal display name with title.
  String get formalName => 'Prof. $lastName';

  /// Initials for avatar display.
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  Professor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? department,
    String? password,
  }) {
    return Professor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      department: department ?? this.department,
      password: password ?? this.password,
    );
  }
}
