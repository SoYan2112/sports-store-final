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

  /// 3. Xử lý Đăng xuất
  Future<void> logout() async {
    await storageService.clearAuthSession();
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
