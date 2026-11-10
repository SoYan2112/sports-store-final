import '../entities/user_profile_entity.dart';

/// ============================================================================
/// PROFILE REPOSITORY INTERFACE (DOMAIN LAYER)
/// ============================================================================
/// Hợp đồng giao tiếp (Contract) định nghĩa các thao tác dữ liệu hồ sơ cá nhân.
/// Giúp tách biệt hoàn toàn nghiệp vụ khỏi chi tiết triển khai cụ thể (SQLite, Dio, Cache).
abstract class ProfileRepository {
  /// Lấy thông tin chi tiết hồ sơ người dùng hiện tại
  Future<UserProfileEntity> getUserProfile();

  /// Cập nhật thông tin hồ sơ người dùng và trả về hồ sơ sau khi cập nhật
  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile);
}
