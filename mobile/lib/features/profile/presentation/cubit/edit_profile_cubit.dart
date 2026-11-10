import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'edit_profile_state.dart';

/// ============================================================================
/// EDIT PROFILE CUBIT - QUẢN LÝ TRẠNG THÁI LƯU THAY ĐỔI HỒ SƠ (UC-27)
/// ============================================================================
/// Chịu trách nhiệm:
/// 1. Nhận thông tin mới từ màn hình EditProfileScreen.
/// 2. Phát trạng thái đang lưu [EditProfileLoading] để hiển thị spinner trên nút bấm.
/// 3. Gọi [UpdateUserProfileUseCase] cập nhật vào SQLite / SharedPreferences / API.
/// 4. Phát [EditProfileSuccess] khi thành công hoặc [EditProfileFailure] khi lỗi.
class EditProfileCubit extends Cubit<EditProfileState> {
  /// UseCase nghiệp vụ cập nhật hồ sơ người dùng
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  EditProfileCubit({
    required this.updateUserProfileUseCase,
  }) : super(const EditProfileInitial());

  /// Xử lý cập nhật thông tin hồ sơ:
  /// - [profile]: Thực thể [UserProfileEntity] mang dữ liệu mới do người dùng nhập.
  Future<void> updateProfile(UserProfileEntity profile) async {
    // 1. Phát trạng thái Loading
    emit(const EditProfileLoading());
    try {
      // 2. Gọi UseCase lưu dữ liệu xuống tầng Repository & DataSource
      final updated = await updateUserProfileUseCase(profile);

      // 3. Phát trạng thái Thành công kèm dữ liệu đã lưu
      emit(EditProfileSuccess(
        updatedProfile: updated,
        message: 'Cập nhật hồ sơ thành công!',
      ));
    } catch (e) {
      // 4. Nếu có lỗi, lọc bỏ tiền tố "Exception: " để thông báo thân thiện hơn
      emit(EditProfileFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
