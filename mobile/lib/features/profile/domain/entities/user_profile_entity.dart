import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String fullname;
  final String email;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final DateTime? createdAt;
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

