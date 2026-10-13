import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/datasources/auth_service.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/screens/login_screen.dart';

class SportsStoreApp extends StatelessWidget {
  const SportsStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(authService: AuthService());

    return MaterialApp(
      title: 'Sports Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: LoginScreen(authRepository: authRepository),
    );
  }
}
