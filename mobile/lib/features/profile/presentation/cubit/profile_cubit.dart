import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileCubit({
    required this.getUserProfileUseCase,
  }) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}

