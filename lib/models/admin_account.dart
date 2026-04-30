/// In-memory administrator account for demo login and credential changes.
class AdminAccount {
  final String username;
  final String password;

  const AdminAccount({required this.username, required this.password});

  AdminAccount copyWith({String? username, String? password}) {
    return AdminAccount(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
