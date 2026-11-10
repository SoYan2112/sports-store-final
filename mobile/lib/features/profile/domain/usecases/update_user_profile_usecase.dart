import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// ============================================================================
/// UPDATE USER PROFILE USECASE (DOMAIN LAYER - UC-27)
/// ============================================================================
/// Thực thi nghiệp vụ cập nhật thông tin hồ sơ của người dùng (Họ tên, SĐT, Giới tính, v.v.).
class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  /// Kích hoạt UseCase cập nhật hồ sơ
  Future<UserProfileEntity> call(UserProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}
