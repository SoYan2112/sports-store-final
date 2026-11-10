import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'profile_state.dart';

/// ============================================================================
/// PROFILE CUBIT - QUẢN LÝ TRẠNG THÁI MÀN HÌNH XEM HỒ SƠ (UC-26)
/// ============================================================================
/// Chịu trách nhiệm:
/// 1. Tải dữ liệu hồ sơ cá nhân khi màn hình khởi chạy (`loadProfile`).
/// 2. Hỗ trợ làm mới dữ liệu khi người dùng kéo màn hình (`refreshProfile`).
/// 3. Cập nhật trực tiếp dữ liệu hiển thị (`updateLoadedProfile`) khi nhận được
///    thông tin mới từ màn hình Chỉnh sửa hồ sơ (UC-27) mà không cần truy vấn lại DB.
class ProfileCubit extends Cubit<ProfileState> {
  /// UseCase nghiệp vụ lấy thông tin hồ sơ người dùng
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileCubit({
    required this.getUserProfileUseCase,
  }) : super(const ProfileInitial());

  /// 1. Tải thông tin hồ sơ người dùng:
  /// - Phát [ProfileLoading] để hiển thị vòng quay tiến trình.
  /// - Gọi [GetUserProfileUseCase] lấy dữ liệu từ SQLite/API.
  /// - Nếu thành công: phát [ProfileLoaded] kèm thông tin [UserProfileEntity].
  /// - Nếu có lỗi: phát [ProfileError] kèm thông điệp lỗi.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// 2. Làm mới hồ sơ (Pull-to-refresh):
  /// - Tải lại thông tin mới nhất mà không phát trạng thái toàn màn hình loading
  ///   để giữ trải nghiệm mượt mà cho RefreshIndicator.
  Future<void> refreshProfile() async {
    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// 3. Cập nhật nhanh hồ sơ đang hiển thị:
  /// - Nhận đối tượng [UserProfileEntity] đã được cập nhật thành công từ màn hình Sửa.
  /// - Phát trực tiếp [ProfileLoaded] mới giúp UI đổi tức thì mà không cần load lại từ DB.
  void updateLoadedProfile(UserProfileEntity profile) {
    emit(ProfileLoaded(profile: profile));
  }
}
