import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo khi vừa mở app
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Trạng thái Khách vãng lai (Chưa đăng nhập) - xem hàng tự do
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Trạng thái Đã đăng nhập
class AuthAuthenticated extends AuthState {
  final String token;
  final String userId;
  final String userName;
  final String userEmail;

  const AuthAuthenticated({
    required this.token,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [token, userId, userName, userEmail];
}
