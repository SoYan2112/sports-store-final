import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// ============================================================================
/// GET USER PROFILE USECASE (DOMAIN LAYER - UC-26)
/// ============================================================================
/// Thực thi nghiệp vụ lấy thông tin hồ sơ của người dùng hiện tại đang đăng nhập.
class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  /// Kích hoạt UseCase
  Future<UserProfileEntity> call() async {
    return await repository.getUserProfile();
  }
}
