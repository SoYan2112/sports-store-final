import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit({required this.registerUseCase})
      : super(const RegisterInitial());

  Future<void> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(const RegisterLoading());
    try {
      final user = await registerUseCase(
        RegisterParams(
          fullname: fullname,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        ),
      );
      emit(RegisterSuccess(user));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(RegisterFailure(message));
    }
  }

  void reset() {
    emit(const RegisterInitial());
  }
}
