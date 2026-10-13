import '../entities/user.dart';

abstract class AuthRepositoryInterface {
  Future<User?> login({required String email, required String password});

  Future<User> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  });
}
