import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileSuccess extends EditProfileState {
  final UserProfileEntity updatedProfile;
  final String message;

  const EditProfileSuccess({
    required this.updatedProfile,
    this.message = 'Cập nhật hồ sơ thành công!',
  });

  @override
  List<Object?> get props => [updatedProfile, message];
}

class EditProfileFailure extends EditProfileState {
  final String error;

  const EditProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

