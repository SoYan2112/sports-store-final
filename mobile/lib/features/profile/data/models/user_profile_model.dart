import '../../domain/entities/user_profile_entity.dart';

/// ============================================================================
/// USER PROFILE MODEL - MÔ HÌNH DỮ LIỆU HỒ SƠ (DATA LAYER)
/// ============================================================================
/// Kế thừa từ [UserProfileEntity] và bổ sung các hàm phân tích JSON / ánh xạ database:
/// - [fromJson]: Phân tích Map trả về từ SQLite hoặc API Backend thành Model.
/// - [toJson]: Đóng gói Model thành Map JSON để gửi qua HTTP PUT/POST hoặc lưu trữ.
/// - [fromEntity]: Chuyển đổi từ Domain Entity sang Data Model.
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.fullname,
    required super.email,
    super.phoneNumber = '',
    super.gender = 'Nam',
    super.dateOfBirth,
    super.avatarUrl,
    super.createdAt,
    super.status = 'ACTIVE',
  });

  /// Factory chuyển đổi dữ liệu từ Map (JSON hoặc SQLite row) sang [UserProfileModel]
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý id (linh hoạt hỗ trợ cả id dạng int hoặc string và các biến thể key)
    final rawId = json['id'] ?? json['userId'] ?? json['user_id'] ?? '';
    final id = rawId.toString();

    // 2. Xử lý họ và tên (hỗ trợ nhiều định dạng key từ các API khác nhau)
    final fullname = (json['fullname'] ??
            json['fullName'] ??
            json['full_name'] ??
            json['name'] ??
            '')
        .toString();

    final email = (json['email'] ?? '').toString();

    // 3. Xử lý số điện thoại
    final phoneNumber = (json['phoneNumber'] ??
            json['phone_number'] ??
            json['phone'] ??
            '')
        .toString();

    // 4. Xử lý giới tính: hỗ trợ boolean (true = Nam, false = Nữ) hoặc String
    String genderStr = 'Nam';
    if (json['gender'] is bool) {
      genderStr = (json['gender'] as bool) ? 'Nam' : 'Nữ';
    } else if (json['gender'] != null) {
      genderStr = json['gender'].toString();
    }

    // 5. Xử lý ngày tạo tài khoản: epoch milliseconds (int) hoặc ISO 8601 String
    DateTime? createdAt;
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    // 6. Xử lý ngày sinh: epoch milliseconds (int) hoặc ISO 8601 String
    DateTime? dob;
    final rawDob = json['dateOfBirth'] ?? json['date_of_birth'] ?? json['dob'];
    if (rawDob is int) {
      dob = DateTime.fromMillisecondsSinceEpoch(rawDob);
    } else if (rawDob is String && rawDob.isNotEmpty) {
      dob = DateTime.tryParse(rawDob);
    }

    final avatar = (json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'])?.toString();
    final status = (json['status'] ?? 'ACTIVE').toString();

    return UserProfileModel(
      id: id,
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      gender: genderStr,
      dateOfBirth: dob,
      avatarUrl: avatar,
      createdAt: createdAt,
      status: status,
    );
  }

  /// Chuyển đổi sang Map JSON để lưu SQLite hoặc gửi HTTP Request lên server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
      'status': status,
    };
  }

  /// Tạo Data Model từ Domain Entity
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      fullname: entity.fullname,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }
}
