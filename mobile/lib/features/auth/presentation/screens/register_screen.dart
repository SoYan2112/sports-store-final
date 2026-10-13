import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../product/presentation/screens/product_list_screen.dart';
import '../../domain/entities/user.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';

class RegisterScreen extends StatefulWidget {
  final void Function(User user)? onRegisterSuccess;

  const RegisterScreen({super.key, this.onRegisterSuccess});

  static Route<void> route({void Function(User user)? onRegisterSuccess}) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => getIt<RegisterCubit>(),
        child: RegisterScreen(onRegisterSuccess: onRegisterSuccess),
      ),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;

  String? _fullnameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final fullname = _fullnameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? nameErr;
    String? emailErr;
    String? phoneErr;
    String? passErr;
    String? confirmErr;
    String? termsErr;

    // 1. Họ và tên
    if (fullname.isEmpty) {
      nameErr = 'Vui lòng nhập họ và tên';
    } else if (fullname.length < 2) {
      nameErr = 'Họ và tên phải có ít nhất 2 ký tự';
    }

    // 2. Email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      emailErr = 'Vui lòng nhập địa chỉ email';
    } else if (!emailRegex.hasMatch(email)) {
      emailErr = 'Email không hợp lệ (ví dụ: user@example.com)';
    }

    // 3. Số điện thoại chuẩn Việt Nam (+84 hoặc 03x, 05x, 07x, 08x, 09x - 10 chữ số)
    final phoneRegex = RegExp(r'^(?:(?:\+84)|0)(3[2-9]|5[25689]|7[06-9]|8[1-9]|9[0-9])[0-9]{7}$');
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) {
      phoneErr = 'Vui lòng nhập số điện thoại';
    } else if (!phoneRegex.hasMatch(cleanPhone)) {
      phoneErr = 'Số điện thoại không hợp lệ.';
    }

    // 4. Mật khẩu >= 6 ký tự
    if (password.isEmpty) {
      passErr = 'Vui lòng nhập mật khẩu';
    } else if (password.length < 6) {
      passErr = 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }

    // 5. Xác nhận mật khẩu
    if (confirmPassword.isEmpty) {
      confirmErr = 'Vui lòng xác nhận lại mật khẩu';
    } else if (confirmPassword != password) {
      confirmErr = 'Mật khẩu xác nhận không trùng khớp';
    }

    // 6. Điều khoản
    if (!_agreeTerms) {
      termsErr = 'Bạn cần đồng ý với Điều khoản dịch vụ để tiếp tục';
    }

    setState(() {
      _fullnameError = nameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
      _termsError = termsErr;
    });

    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        passErr == null &&
        confirmErr == null &&
        termsErr == null;
  }

  void _submit() {
    if (!_validateInputs()) {
      return;
    }

    context.read<RegisterCubit>().register(
          fullname: _fullnameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đăng ký thành công! Chào mừng ${state.user.fullname}',
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Sau đăng ký thành công: gọi callback nếu có, hoặc pop về Login, hoặc điều hướng vào ProductListScreen
          if (widget.onRegisterSuccess != null) {
            widget.onRegisterSuccess!(state.user);
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const ProductListScreen(),
              ),
            );
          }
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng ký thất bại: ${state.errorMessage}'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Icon thể thao
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.sports_basketball,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title phong cách Adidas
                        const Text(
                          'TẠO TÀI KHOẢN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gia nhập cộng đồng thể thao và tận hưởng ưu đãi đặc quyền',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Field 1: Họ và tên
                        _buildInputField(
                          keyName: 'fullnameField',
                          controller: _fullnameController,
                          label: 'Họ và tên',
                          hintText: 'VD: Trần Hoàng Nhật',
                          icon: Icons.person_outline,
                          errorText: _fullnameError,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Email
                        _buildInputField(
                          keyName: 'emailField',
                          controller: _emailController,
                          label: 'Địa chỉ Email',
                          hintText: 'VD: hoangnhat@example.com',
                          icon: Icons.email_outlined,
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Field 3: Số điện thoại
                        _buildInputField(
                          keyName: 'phoneField',
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          hintText: 'VD: 0901234567',
                          icon: Icons.phone_android_outlined,
                          errorText: _phoneError,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Field 4: Mật khẩu
                        _buildInputField(
                          keyName: 'passwordField',
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          hintText: 'Tối thiểu 6 ký tự',
                          icon: Icons.lock_outline,
                          errorText: _passwordError,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 5: Xác nhận mật khẩu
                        _buildInputField(
                          keyName: 'confirmPasswordField',
                          controller: _confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                          hintText: 'Nhập lại mật khẩu phía trên',
                          icon: Icons.lock_clock_outlined,
                          errorText: _confirmPasswordError,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Checkbox: Điều khoản
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                key: const Key('termsCheckbox'),
                                value: _agreeTerms,
                                activeColor: AppColors.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeTerms = value ?? false;
                                    if (_agreeTerms) {
                                      _termsError = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeTerms = !_agreeTerms;
                                    if (_agreeTerms) _termsError = null;
                                  });
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Tôi đồng ý với ',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade700,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Điều khoản dịch vụ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' & '),
                                      TextSpan(
                                        text: 'Chính sách bảo mật',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_termsError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 34),
                            child: Text(
                              _termsError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 26),

                        // Nút Đăng ký (Adidas style CTA)
                        ElevatedButton(
                          key: const Key('registerButton'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'ĐĂNG KÝ NGAY',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 22),

                        // Link chuyển sang Đăng nhập
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đã có tài khoản? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13.5,
                              ),
                            ),
                            GestureDetector(
                              key: const Key('goToLoginLink'),
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Đăng nhập ngay',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String keyName,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: Key(keyName),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
