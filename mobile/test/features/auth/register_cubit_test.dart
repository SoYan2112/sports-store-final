import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:mobile/features/auth/presentation/cubit/register_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/register_state.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late RegisterCubit cubit;

  final tUser = User(
    id: 99,
    fullname: 'Trần Hoàng Nhật',
    email: 'hoangnhat@example.com',
    phoneNumber: '0901234567',
    password: 'password123',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    cubit = RegisterCubit(registerUseCase: mockRegisterUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('RegisterCubit', () {
    test('initial state should be RegisterInitial', () {
      expect(cubit.state, const RegisterInitial());
    });

    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterSuccess] when registration succeeds',
      build: () {
        when(() => mockRegisterUseCase(any())).thenAnswer((_) async => tUser);
        return cubit;
      },
      act: (c) => c.register(
        fullname: 'Trần Hoàng Nhật',
        email: 'hoangnhat@example.com',
        phoneNumber: '0901234567',
        password: 'password123',
      ),
      expect: () => [
        const RegisterLoading(),
        RegisterSuccess(tUser),
      ],
      verify: (_) {
        verify(() => mockRegisterUseCase(any())).called(1);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterFailure] when registration throws exception',
      build: () {
        when(() => mockRegisterUseCase(any()))
            .thenThrow(Exception('Email này đã được sử dụng'));
        return cubit;
      },
      act: (c) => c.register(
        fullname: 'Trần Hoàng Nhật',
        email: 'hoangnhat@example.com',
        phoneNumber: '0901234567',
        password: 'password123',
      ),
      expect: () => [
        const RegisterLoading(),
        const RegisterFailure('Email này đã được sử dụng'),
      ],
    );

    test('reset() emits RegisterInitial', () {
      cubit.reset();
      expect(cubit.state, const RegisterInitial());
    });
  });
}
