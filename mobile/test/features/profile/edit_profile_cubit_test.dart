import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_state.dart';

class MockUpdateUserProfileUseCase extends Mock implements UpdateUserProfileUseCase {}

void main() {
  late MockUpdateUserProfileUseCase mockUpdateUserProfileUseCase;
  late EditProfileCubit editProfileCubit;

  final initialProfile = UserProfileEntity(
    id: '1',
    fullname: 'Trần Hoàng Nhật',
    email: 'nhatth@gmail.com',
    phoneNumber: '0901234567',
    gender: 'Nam',
    createdAt: DateTime(2026, 1, 10),
    status: 'ACTIVE',
  );

  final updatedProfile = initialProfile.copyWith(
    fullname: 'Trần Hoàng Nhật Mới',
    phoneNumber: '0987654321',
    gender: 'Nam',
  );

  setUp(() {
    mockUpdateUserProfileUseCase = MockUpdateUserProfileUseCase();
    editProfileCubit = EditProfileCubit(
      updateUserProfileUseCase: mockUpdateUserProfileUseCase,
    );
  });

  tearDown(() {
    editProfileCubit.close();
  });

  group('EditProfileCubit Tests', () {
    test('initial state should be EditProfileInitial', () {
      expect(editProfileCubit.state, equals(const EditProfileInitial()));
    });

    blocTest<EditProfileCubit, EditProfileState>(
      'emits [EditProfileLoading, EditProfileSuccess] when updateProfile succeeds',
      build: () {
        when(() => mockUpdateUserProfileUseCase(updatedProfile))
            .thenAnswer((_) async => updatedProfile);
        return editProfileCubit;
      },
      act: (cubit) => cubit.updateProfile(updatedProfile),
      expect: () => [
        const EditProfileLoading(),
        EditProfileSuccess(
          updatedProfile: updatedProfile,
          message: 'Cập nhật hồ sơ thành công!',
        ),
      ],
      verify: (_) {
        verify(() => mockUpdateUserProfileUseCase(updatedProfile)).called(1);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'emits [EditProfileLoading, EditProfileFailure] when updateProfile throws',
      build: () {
        when(() => mockUpdateUserProfileUseCase(updatedProfile))
            .thenThrow(Exception('Lỗi máy chủ cập nhật'));
        return editProfileCubit;
      },
      act: (cubit) => cubit.updateProfile(updatedProfile),
      expect: () => [
        const EditProfileLoading(),
        const EditProfileFailure('Lỗi máy chủ cập nhật'),
      ],
    );
  });
}

