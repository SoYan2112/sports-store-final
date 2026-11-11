import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../datasources/auth_service.dart';

/// ============================================================================
/// AUTH REPOSITORY IMPLEMENTATION (DATA LAYER)
/// ============================================================================
/// Triển khai [AuthRepositoryInterface], làm cầu nối giữa UseCase và [AuthService].
class AuthRepository implements AuthRepositoryInterface {
  const AuthRepository({required this.authService});

  final AuthService authService;

  /// Đăng nhập tài khoản
  @override
  Future<User?> login({required String email, required String password}) {
    return authService.authenticate(email: email, password: password);
  }

  /// Đăng ký tài khoản người dùng mới (UC-02)
  @override
  Future<User> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return authService.register(
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  /// Xử lý đăng xuất
  // Thu hồi phiên xác thực người dùng ở tầng dữ liệu
  Future<void> logout() async {
    // 9. Repository dọn dẹp phiên kết nối và dữ liệu xác thực
    // Mock: chuẩn bị sẵn cho việc xóa local token / storage khi nối backend
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
