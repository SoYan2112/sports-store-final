import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../datasources/auth_service.dart';

class AuthRepository implements AuthRepositoryInterface {
  const AuthRepository({required this.authService});

  final AuthService authService;

  @override
  Future<User?> login({required String email, required String password}) {
    return authService.authenticate(email: email, password: password);
  }

  @override
  Future<User> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return authService.register(
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
