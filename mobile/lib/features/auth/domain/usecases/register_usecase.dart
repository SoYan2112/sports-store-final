import '../entities/user.dart';
import '../repositories/auth_repository_interface.dart';

class RegisterParams {
  final String fullname;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterParams({
    required this.fullname,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}

class RegisterUseCase {
  final AuthRepositoryInterface repository;

  RegisterUseCase(this.repository);

  Future<User> call(RegisterParams params) {
    return repository.register(
      fullname: params.fullname,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}
