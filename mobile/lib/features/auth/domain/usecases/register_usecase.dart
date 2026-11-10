import '../entities/user.dart';
import '../repositories/auth_repository_interface.dart';

/// ============================================================================
/// REGISTER PARAMS & USECASE (DOMAIN LAYER - UC-02)
/// ============================================================================

/// Tham số đầu vào cho nghiệp vụ đăng ký tài khoản
class RegisterParams {
  final String fullname;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterParams({
    required this.fullname,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}

/// UseCase nghiệp vụ Đăng ký tài khoản:
/// Đóng gói logic tạo người dùng mới độc lập với cơ sở dữ liệu và giao diện.
class RegisterUseCase {
  final AuthRepositoryInterface repository;

  RegisterUseCase(this.repository);

  /// Kích hoạt UseCase tạo tài khoản thông qua repository interface
  Future<User> call(RegisterParams params) {
    return repository.register(
      fullname: params.fullname,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}
