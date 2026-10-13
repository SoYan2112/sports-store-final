class User {
  const User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  final int id;
  final String fullname;
  final String email;
  final String password;
  final DateTime createdAt;
}
