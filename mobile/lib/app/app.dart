import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/product/presentation/bloc/product_bloc.dart';

class SportsStoreApp extends StatelessWidget {
  const SportsStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => getIt<ProductBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Sports Store Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: LoginScreen(authRepository: getIt<AuthRepository>()),
      ),
    );
  }
}
