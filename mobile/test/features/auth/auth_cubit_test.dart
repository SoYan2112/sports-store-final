import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/storage/local_storage_service.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_state.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLocalStorageService mockStorageService;
  late MockAuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  setUp(() {
    mockStorageService = MockLocalStorageService();
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(
      storageService: mockStorageService,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit - Lazy Login', () {
    test('initial state should be AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when no token in local storage',
      build: () {
        when(() => mockStorageService.getAccessToken()).thenReturn(null);
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthAuthenticated] when valid token exists in local storage',
      build: () {
        when(() => mockStorageService.getAccessToken()).thenReturn('token_123');
        when(() => mockStorageService.getSavedUser()).thenReturn({
          'id': '1',
          'name': 'Thái San Yo',
          'email': 'sanyo@example.com',
        });
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthAuthenticated(
          token: 'token_123',
          userId: '1',
          userName: 'Thái San Yo',
          userEmail: 'sanyo@example.com',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthAuthenticated] when loginSuccess is called',
      build: () {
        when(() => mockStorageService.saveAuthSession(
              token: any(named: 'token'),
              userId: any(named: 'userId'),
              name: any(named: 'name'),
              email: any(named: 'email'),
            )).thenAnswer((_) async => true);
        return authCubit;
      },
      act: (cubit) => cubit.loginSuccess(
        token: 'token_999',
        userId: '2',
        name: 'Nguyễn Văn A',
        email: 'vana@example.com',
      ),
      expect: () => [
        const AuthAuthenticated(
          token: 'token_999',
          userId: '2',
          userName: 'Nguyễn Văn A',
          userEmail: 'vana@example.com',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when logout is called',
      build: () {
        when(() => mockStorageService.clearAuthSession()).thenAnswer((_) async {});
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );
  });
}
