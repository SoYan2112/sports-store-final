import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  EditProfileCubit({
    required this.updateUserProfileUseCase,
  }) : super(const EditProfileInitial());

  Future<void> updateProfile(UserProfileEntity profile) async {
    emit(const EditProfileLoading());
    try {
      final updated = await updateUserProfileUseCase(profile);
      emit(EditProfileSuccess(
        updatedProfile: updated,
        message: 'Cập nhật hồ sơ thành công!',
      ));
    } catch (e) {
      emit(EditProfileFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

