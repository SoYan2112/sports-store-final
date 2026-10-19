import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/datasources/auth_service.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthService authService;
    late AuthRepository authRepository;

    setUp(() {
      authService = AuthService();
      authRepository = AuthRepository(authService: authService);
    });

    test('login with valid credentials returns correct User', () async {
      final user = await authRepository.login(
        email: 'a@gmail.com',
        password: '123456',
      );

      expect(user, isNotNull);
      expect(user?.email, 'a@gmail.com');
      expect(user?.fullname, 'Nguyễn Văn A');
    });

    test('login with invalid credentials returns null', () async {
      final user = await authRepository.login(
        email: 'wrong@gmail.com',
        password: 'wrong_password',
      );

      expect(user, isNull);
    });

    test('logout completes successfully without errors', () async {
      expect(authRepository.logout(), completes);
    });
  });
}

