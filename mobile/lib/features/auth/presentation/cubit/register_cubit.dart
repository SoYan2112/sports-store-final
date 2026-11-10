import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_state.dart';

/// ============================================================================
/// REGISTER CUBIT - QUẢN LÝ TRẠNG THÁI ĐĂNG KÝ TÀI KHOẢN (UC-02)
/// ============================================================================
/// Chịu trách nhiệm:
/// 1. Tiếp nhận dữ liệu người dùng gửi lên từ [RegisterScreen].
/// 2. Phát trạng thái đang xử lý [RegisterLoading].
/// 3. Kích hoạt [RegisterUseCase] để tạo tài khoản trong cơ sở dữ liệu.
/// 4. Phát [RegisterSuccess] kèm thực thể [User] khi thành công, hoặc [RegisterFailure] khi có lỗi.
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit({required this.registerUseCase})
      : super(const RegisterInitial());

  /// Xử lý đăng ký tài khoản mới:
  /// - [fullname]: Họ và tên người dùng.
  /// - [email]: Địa chỉ email.
  /// - [phoneNumber]: Số điện thoại liên hệ.
  /// - [password]: Mật khẩu bảo vệ tài khoản.
  Future<void> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    // 1. Phát trạng thái Loading
    emit(const RegisterLoading());
    try {
      // 2. Gọi UseCase thực thi kiểm tra trùng lặp và ghi dữ liệu
      final user = await registerUseCase(
        RegisterParams(
          fullname: fullname,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        ),
      );
      // 3. Phát trạng thái thành công
      emit(RegisterSuccess(user));
    } catch (e) {
      // 4. Nếu thất bại (trùng email, lỗi DB), phát trạng thái lỗi
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(RegisterFailure(message));
    }
  }

  /// Đặt lại trạng thái ban đầu của Cubit
  void reset() {
    emit(const RegisterInitial());
  }
}
