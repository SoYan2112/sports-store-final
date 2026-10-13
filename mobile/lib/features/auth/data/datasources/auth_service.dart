import '../../domain/entities/user.dart';

class AuthService {
  static final List<User> users = [
    User(
      id: 1,
      fullname: 'Nguyễn Văn A',
      email: 'a@gmail.com',
      password: '123456',
      createdAt: DateTime(2026, 1, 10),
    ),
    User(
      id: 2,
      fullname: 'Nguyễn Văn B',
      email: 'b@gmail.com',
      password: '123456',
      createdAt: DateTime(2026, 2, 5),
    ),
  ];

  Future<User?> authenticate({
    required String email,
    required String password,
  }) async {
    for (final user in users) {
      if (user.email.toLowerCase() == email.trim().toLowerCase() &&
          user.password == password) {
        return user;
      }
    }

    return null;
  }
}
