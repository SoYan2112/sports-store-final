import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

/// ============================================================================
/// PROFILE REPOSITORY IMPLEMENTATION (DATA LAYER)
/// ============================================================================
/// Cầu nối giữa Domain Layer (UseCase) và Data Layer (DataSource).
/// Chịu trách nhiệm:
/// 1. Nhận yêu cầu từ UseCase.
/// 2. Chuyển đổi qua lại giữa [UserProfileEntity] và [UserProfileModel].
/// 3. Gọi DataSource để truy vấn SQLite hoặc gọi API mạng.
/// 4. Bắt Exception và chuyển thành Failure phù hợp cho tầng BLoC.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  /// Lấy thông tin hồ sơ người dùng
  @override
  Future<UserProfileEntity> getUserProfile() async {
    try {
      final model = await remoteDataSource.getUserProfile();
      return model;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Không thể tải thông tin cá nhân: ${e.toString()}');
    }
  }

  /// Cập nhật thông tin hồ sơ người dùng
  @override
  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile) async {
    try {
      // Chuyển Entity sang Model để DataSource dễ dàng phân tích và lưu trữ
      final model = UserProfileModel.fromEntity(profile);
      final updated = await remoteDataSource.updateUserProfile(model);
      return updated;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Không thể cập nhật hồ sơ: ${e.toString()}');
    }
  }
}
