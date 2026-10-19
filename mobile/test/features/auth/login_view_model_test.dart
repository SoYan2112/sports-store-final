import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/view_models/login_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginViewModel', () {
    late MockAuthRepository mockAuthRepository;
    late LoginViewModel viewModel;

    final tUser = User(
      id: 1,
      fullname: 'Nguyễn Văn A',
      email: 'a@gmail.com',
      password: '123456',
      createdAt: DateTime(2026, 1, 10),
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      viewModel = LoginViewModel(authRepository: mockAuthRepository);
    });

    test('initial values should be default', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.authenticatedUser, isNull);
    });

    test('login success updates authenticatedUser and notifies listeners', () async {
      when(
        () => mockAuthRepository.login(
          email: 'a@gmail.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => tUser);

      int listenerCount = 0;
      viewModel.addListener(() {
        listenerCount++;
      });

      await viewModel.login(email: 'a@gmail.com', password: '123456');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.authenticatedUser, equals(tUser));
      expect(listenerCount, greaterThan(0));
      verify(
        () => mockAuthRepository.login(
          email: 'a@gmail.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('login failure sets errorMessage and clears authenticatedUser', () async {
      when(
        () => mockAuthRepository.login(
          email: 'wrong@gmail.com',
          password: 'wrong_password',
        ),
      ).thenAnswer((_) async => null);

      await viewModel.login(
        email: 'wrong@gmail.com',
        password: 'wrong_password',
      );

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, equals('Email hoặc mật khẩu không đúng'));
      expect(viewModel.authenticatedUser, isNull);
    });

    test('logout calls authRepository.logout and resets state', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      when(
        () => mockAuthRepository.login(
          email: 'a@gmail.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => tUser);

      // Đăng nhập trước
      await viewModel.login(email: 'a@gmail.com', password: '123456');
      expect(viewModel.authenticatedUser, isNotNull);

      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      // Thực hiện logout
      await viewModel.logout();

      expect(viewModel.authenticatedUser, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(notifyCount, 1);
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}

