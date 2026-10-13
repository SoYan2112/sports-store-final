import 'package:flutter/material.dart';

import '../../../product/presentation/screens/product_list_screen.dart';
import '../../data/repositories/auth_repository.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(authRepository: widget.authRepository)
      ..addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_refresh)
      ..dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = _validateEmail(email);
      _passwordError = password.isEmpty ? 'Vui lòng nhập mật khẩu' : null;
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    await _viewModel.login(email: email, password: password);

    if (!mounted) {
      return;
    }

    final user = _viewModel.authenticatedUser;
    if (user == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng nhập thành công! Xin chào ${user.fullname}'),
        backgroundColor: Colors.green,
      ),
    );

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ProductListScreen()),
    );
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!email.contains('@')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.sports_basketball,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đăng nhập',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: _passwordError,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('loginButton'),
                    onPressed: _viewModel.isLoading ? null : _submit,
                    child: _viewModel.isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng nhập'),
                  ),
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
