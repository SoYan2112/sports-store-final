import '../../domain/entities/user.dart';

class AuthService {
  static final List<User> users = [
    User(
      id: 1,
      fullname: 'Nguyễn Văn A',
      email: 'a@gmail.com',
      password: '123456',
      createdAt: DateTime(2026, 1, 10),
      phoneNumber: '0901234567',
    ),
    User(
      id: 2,
      fullname: 'Nguyễn Văn B',
      email: 'b@gmail.com',
      password: '123456',
      createdAt: DateTime(2026, 2, 5),
      phoneNumber: '0912345678',
    ),
  ];

  Future<User?> authenticate({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    for (final user in users) {
      if (user.email.toLowerCase() == email.trim().toLowerCase() &&
          user.password == password) {
        return user;
      }
    }

    return null;
  }

  Future<User> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    // Mô phỏng độ trễ mạng cho Sprint 1 (chưa có backend)
    await Future.delayed(const Duration(milliseconds: 500));

    // Kiểm tra trùng Email
    final isEmailExist = users.any(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (isEmailExist) {
      throw Exception('Email này đã được sử dụng');
    }

    // Kiểm tra trùng Số điện thoại
    final isPhoneExist = users.any(
      (u) => u.phoneNumber == phoneNumber.trim(),
    );
    if (isPhoneExist) {
      throw Exception('Số điện thoại này đã được sử dụng');
    }

    final newUser = User(
      id: users.length + 1,
      fullname: fullname.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      password: password,
      createdAt: DateTime.now(),
    );
    users.add(newUser);
    return newUser;
  }
}
