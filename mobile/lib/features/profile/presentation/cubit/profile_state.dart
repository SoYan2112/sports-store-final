import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

/// ============================================================================
/// PROFILE STATE - CÁC TRẠNG THÁI GIAO DIỆN XEM HỒ SƠ
/// ============================================================================
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi Cubit mới được tạo và chưa có thao tác tải nào diễn ra
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Trạng thái đang tải dữ liệu hồ sơ cá nhân (hiển thị CircularProgressIndicator)
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Trạng thái đã tải dữ liệu hồ sơ thành công, mang theo dữ liệu [UserProfileEntity]
class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Trạng thái xảy ra lỗi khi tải hồ sơ (lỗi kết nối, không tìm thấy user, v.v.)
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
