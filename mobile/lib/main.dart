import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(const SportsStoreApp());
}

class SportsStoreApp extends StatelessWidget {
  const SportsStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Store Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocProvider(
        create: (context) => getIt<ProductBloc>(),
        child: const ProductListScreen(),
      ),
    );
  }
}
