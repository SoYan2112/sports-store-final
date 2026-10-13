import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this.authRepository});

  final AuthRepository authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  User? _authenticatedUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get authenticatedUser => _authenticatedUser;

  Future<void> login({required String email, required String password}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _authenticatedUser = null;
    notifyListeners();

    final user = await authRepository.login(email: email, password: password);

    _isLoading = false;
    _authenticatedUser = user;
    _errorMessage = user == null ? 'Email hoặc mật khẩu không đúng' : null;
    notifyListeners();
  }

  Future<void> logout() async {
    await authRepository.logout();
    _authenticatedUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
