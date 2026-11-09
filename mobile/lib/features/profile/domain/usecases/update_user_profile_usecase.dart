import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<UserProfileEntity> call(UserProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}

