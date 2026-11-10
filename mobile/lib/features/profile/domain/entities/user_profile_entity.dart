import 'package:equatable/equatable.dart';

/// ============================================================================
/// USER PROFILE ENTITY - THỰC THỂ DỮ LIỆU HỒ SƠ NGƯỜI DÙNG (DOMAIN LAYER)
/// ============================================================================
/// Là đối tượng cốt lõi độc lập với cơ sở dữ liệu và thư viện bên ngoài.
/// Đại diện cho toàn bộ thông tin hồ sơ của khách hàng trong ứng dụng Sports Store.
class UserProfileEntity extends Equatable {
  /// Mã định danh duy nhất của người dùng trong hệ thống
  final String id;

  /// Họ và tên đầy đủ
  final String fullname;

  /// Địa chỉ email đăng ký tài khoản (định danh duy nhất, không thể chỉnh sửa)
  final String email;

  /// Số điện thoại liên hệ nhận hàng
  final String phoneNumber;

  /// Giới tính: 'Nam', 'Nữ', 'Khác'
  final String gender;

  /// Ngày tháng năm sinh
  final DateTime? dateOfBirth;

  /// Đường dẫn hoặc URL ảnh đại diện
  final String? avatarUrl;

  /// Ngày tạo tài khoản (ngày tham gia)
  final DateTime? createdAt;

  /// Trạng thái hoạt động của tài khoản (VD: 'ACTIVE')
  final String status;

  const UserProfileEntity({
    required this.id,
    required this.fullname,
    required this.email,
    this.phoneNumber = '',
    this.gender = 'Nam',
    this.dateOfBirth,
    this.avatarUrl,
    this.createdAt,
    this.status = 'ACTIVE',
  });

  /// Phương thức sao chép và ghi đè các thuộc tính khi cần tạo thực thể mới sau chỉnh sửa
  UserProfileEntity copyWith({
    String? id,
    String? fullname,
    String? email,
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? avatarUrl,
    DateTime? createdAt,
    String? status,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullname,
        email,
        phoneNumber,
        gender,
        dateOfBirth,
        avatarUrl,
        createdAt,
        status,
      ];
}
