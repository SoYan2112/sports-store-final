import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// ============================================================================
/// REGISTER STATE - CÁC TRẠNG THÁI GIAO DIỆN ĐĂNG KÝ TÀI KHOẢN
/// ============================================================================
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi người dùng mới mở màn hình Đăng ký
class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

/// Trạng thái đang gửi yêu cầu tạo tài khoản (hiển thị CircularProgressIndicator trên nút CTA)
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// Trạng thái đăng ký thành công, mang theo thông tin thực thể [User] vừa tạo
class RegisterSuccess extends RegisterState {
  final User user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Trạng thái đăng ký thất bại (VD: "Email này đã được sử dụng", "Số điện thoại này đã được sử dụng")
class RegisterFailure extends RegisterState {
  final String errorMessage;

  const RegisterFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
