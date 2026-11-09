import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_state.dart';

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}

void main() {
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
  late ProfileCubit profileCubit;

  final testProfile = UserProfileEntity(
    id: '1',
    fullname: 'Trần Hoàng Nhật',
    email: 'nhatth@gmail.com',
    phoneNumber: '0901234567',
    gender: 'Nam',
    createdAt: DateTime(2026, 1, 10),
    status: 'ACTIVE',
  );

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    profileCubit = ProfileCubit(getUserProfileUseCase: mockGetUserProfileUseCase);
  });

  tearDown(() {
    profileCubit.close();
  });

  group('ProfileCubit Tests', () {
    test('initial state should be ProfileInitial', () {
      expect(profileCubit.state, equals(const ProfileInitial()));
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when loadProfile succeeds',
      build: () {
        when(() => mockGetUserProfileUseCase()).thenAnswer((_) async => testProfile);
        return profileCubit;
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        ProfileLoaded(profile: testProfile),
      ],
      verify: (_) {
        verify(() => mockGetUserProfileUseCase()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when loadProfile throws exception',
      build: () {
        when(() => mockGetUserProfileUseCase()).thenThrow(Exception('Lỗi mạng kết nối'));
        return profileCubit;
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileError('Exception: Lỗi mạng kết nối'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoaded] when refreshProfile succeeds',
      build: () {
        when(() => mockGetUserProfileUseCase()).thenAnswer((_) async => testProfile);
        return profileCubit;
      },
      act: (cubit) => cubit.refreshProfile(),
      expect: () => [
        ProfileLoaded(profile: testProfile),
      ],
      verify: (_) {
        verify(() => mockGetUserProfileUseCase()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileError] when refreshProfile fails',
      build: () {
        when(() => mockGetUserProfileUseCase()).thenThrow(Exception('Timeout'));
        return profileCubit;
      },
      act: (cubit) => cubit.refreshProfile(),
      expect: () => [
        const ProfileError('Exception: Timeout'),
      ],
    );
  });
}

