import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.password,
    required this.createdAt,
    this.phoneNumber,
  });

  final int id;
  final String fullname;
  final String email;
  final String password;
  final DateTime createdAt;
  final String? phoneNumber;

  @override
  List<Object?> get props => [id, fullname, email, password, createdAt, phoneNumber];
}
