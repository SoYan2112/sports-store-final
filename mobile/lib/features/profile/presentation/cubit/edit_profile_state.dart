import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

/// ============================================================================
/// EDIT PROFILE STATE - CÁC TRẠNG THÁI GIAO DIỆN CHỈNH SỬA HỒ SƠ
/// ============================================================================
abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi mới mở màn hình chỉnh sửa
class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

/// Trạng thái đang thực hiện lưu thông tin xuống database/mạng (hiển thị loading trên nút)
class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

/// Trạng thái cập nhật thành công, mang theo thông tin hồ sơ mới và thông báo phản hồi
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

/// Trạng thái cập nhật thất bại, mang theo chuỗi thông điệp lỗi để hiển thị SnackBar
class EditProfileFailure extends EditProfileState {
  final String error;

  const EditProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}
