import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final User user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  final String errorMessage;

  const RegisterFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
