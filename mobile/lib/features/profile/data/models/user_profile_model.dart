import '../../domain/entities/user_profile_entity.dart';

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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Xử lý id dạng int hoặc string
    final rawId = json['id'] ?? json['userId'] ?? json['user_id'] ?? '';
    final id = rawId.toString();

    final fullname = (json['fullname'] ??
            json['fullName'] ??
            json['full_name'] ??
            json['name'] ??
            '')
        .toString();

    final email = (json['email'] ?? '').toString();

    final phoneNumber = (json['phoneNumber'] ??
            json['phone_number'] ??
            json['phone'] ??
            '')
        .toString();

    // Xử lý gender: có thể là boolean (true = Nam, false = Nữ) hoặc String
    String genderStr = 'Nam';
    if (json['gender'] is bool) {
      genderStr = (json['gender'] as bool) ? 'Nam' : 'Nữ';
    } else if (json['gender'] != null) {
      genderStr = json['gender'].toString();
    }

    // Xử lý createdAt: epoch milliseconds (int) hoặc ISO String
    DateTime? createdAt;
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    // Xử lý dateOfBirth
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

