import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalStorageService storageService;
  final AuthRepository authRepository;

  AuthCubit({
    required this.storageService,
    required this.authRepository,
  }) : super(const AuthInitial());

  /// 1. Kiểm tra trạng thái đăng nhập khi mở app
  void checkAuthStatus() {
    final token = storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final user = storageService.getSavedUser();
      emit(AuthAuthenticated(
        token: token,
        userId: user?['id'] ?? '',
        userName: user?['name'] ?? 'Khách hàng',
        userEmail: user?['email'] ?? '',
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// 2. Bắn trạng thái khi đăng nhập thành công
  Future<void> loginSuccess({
    required String token,
    required String userId,
    required String name,
    required String email,
  }) async {
    await storageService.saveAuthSession(
      token: token,
      userId: userId,
      name: name,
      email: email,
    );

    emit(AuthAuthenticated(
      token: token,
      userId: userId,
      userName: name,
      userEmail: email,
    ));
  }

  /// 3. Cập nhật thông tin hiển thị sau khi chỉnh sửa hồ sơ
  void updateUserInfo({required String name, String? email}) {
    if (state is AuthAuthenticated) {
      final current = state as AuthAuthenticated;
      emit(AuthAuthenticated(
        token: current.token,
        userId: current.userId,
        userName: name,
        userEmail: email ?? current.userEmail,
      ));
    }
  }

  /// 4. Xử lý Đăng xuất
  // Xử lý nghiệp vụ đăng xuất: xóa sạch token lưu trữ và đưa ứng dụng về trạng thái Unauthenticated
  Future<void> logout() async {
    // 6. Xóa token và phiên đăng nhập của người dùng khỏi bộ nhớ máy (SharedPreferences)
    await storageService.clearAuthSession();
    // 7. Gọi AuthRepository thực hiện dọn dẹp phiên trên backend/hệ thống
    await authRepository.logout();
    // 8. Phát ra trạng thái AuthUnauthenticated để toàn bộ app cập nhật về trạng thái khách
    emit(const AuthUnauthenticated());
  }
}
