import '../../domain/entities/user.dart';
import '../datasources/auth_service.dart';

class AuthRepository {
  const AuthRepository({required this._authService});

  final AuthService _authService;

  Future<User?> login({required String email, required String password}) {
    return _authService.authenticate(email: email, password: password);
  }

  Future<void> logout() async {
    // Mock: chuẩn bị sẵn cho việc xóa local token / storage khi nối backend
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
