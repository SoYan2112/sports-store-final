import '../../domain/entities/user.dart';
import '../datasources/auth_service.dart';

class AuthRepository {
  const AuthRepository({required this._authService});

  final AuthService _authService;

  Future<User?> login({required String email, required String password}) {
    return _authService.authenticate(email: email, password: password);
  }
}
