import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileEntity initialProfile;

  const EditProfileScreen({
    super.key,
    required this.initialProfile,
  });

  static Route<UserProfileEntity?> route({required UserProfileEntity profile}) {
    return MaterialPageRoute<UserProfileEntity?>(
      builder: (_) => BlocProvider<EditProfileCubit>(
        create: (_) => getIt<EditProfileCubit>(),
        child: EditProfileScreen(initialProfile: profile),
      ),
    );
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  late String _selectedGender;
  DateTime? _selectedDob;
  String? _selectedAvatar;

  String? _nameError;
  String? _phoneError;

  final _vietnamPhoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.fullname);
    _phoneController = TextEditingController(text: widget.initialProfile.phoneNumber);
    _selectedGender = widget.initialProfile.gender.isNotEmpty
        ? widget.initialProfile.gender
        : 'Nam';
    _selectedDob = widget.initialProfile.dateOfBirth;
    _selectedAvatar = widget.initialProfile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    String? nameErr;
    if (name.isEmpty) {
      nameErr = 'Vui lòng nhập họ và tên';
    } else if (name.length < 2) {
      nameErr = 'Họ và tên phải có ít nhất 2 ký tự';
    }

    String? phoneErr;
    if (phone.isEmpty) {
      phoneErr = 'Vui lòng nhập số điện thoại';
    } else if (!_vietnamPhoneRegex.hasMatch(phone)) {
      phoneErr = 'Số điện thoại không hợp lệ (ví dụ: 0901234567)';
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });

    return nameErr == null && phoneErr == null;
  }

  void _onSave() {
    if (!_validateInputs()) {
      return;
    }

    final updated = widget.initialProfile.copyWith(
      fullname: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob,
      avatarUrl: _selectedAvatar,
    );

    context.read<EditProfileCubit>().updateProfile(updated);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'CHỌN NGÀY SINH',
      confirmText: 'CHỌN',
      cancelText: 'HỦY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          // Đồng bộ tên mới lên AuthCubit toàn app
          try {
            context.read<AuthCubit>().updateUserInfo(
                  name: state.updatedProfile.fullname,
                  email: state.updatedProfile.email,
                );
          } catch (_) {}

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pop(state.updatedProfile);
        } else if (state is EditProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa hồ sơ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thẻ Avatar & chỉnh ảnh
                  _buildAvatarPicker(),
                  const SizedBox(height: 24),

                  // 2. Họ và tên
                  _buildSectionLabel('Họ và tên *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    keyName: 'nameField',
                    controller: _nameController,
                    hintText: 'Nhập họ và tên',
                    icon: Icons.person_outline_rounded,
                    errorText: _nameError,
                    keyboardType: TextInputType.name,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // 3. Email (Chỉ đọc)
                  _buildSectionLabel('Địa chỉ Email'),
                  const SizedBox(height: 8),
                  _buildReadOnlyEmailField(),
                  const SizedBox(height: 18),

                  // 4. Số điện thoại
                  _buildSectionLabel('Số điện thoại *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    keyName: 'phoneField',
                    controller: _phoneController,
                    hintText: 'Ví dụ: 0901234567',
                    icon: Icons.phone_outlined,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // 5. Giới tính
                  _buildSectionLabel('Giới tính'),
                  const SizedBox(height: 8),
                  _buildGenderSelector(),
                  const SizedBox(height: 18),

                  // 6. Ngày sinh
                  _buildSectionLabel('Ngày sinh'),
                  const SizedBox(height: 8),
                  _buildDobSelector(),
                  const SizedBox(height: 32),

                  // 7. Nút Lưu thay đổi
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    final initialLetter = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim().substring(0, 1).toUpperCase()
        : (widget.initialProfile.fullname.isNotEmpty
            ? widget.initialProfile.fullname.substring(0, 1).toUpperCase()
            : 'U');

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFFFE8D6),
            child: Text(
              initialLetter,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng chọn ảnh từ thư viện thiết bị'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required String keyName,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null ? Colors.redAccent : Colors.grey.shade300,
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            key: Key(keyName),
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReadOnlyEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialProfile.email.isNotEmpty
                      ? widget.initialProfile.email
                      : 'Chưa có email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Email không thể thay đổi để bảo vệ tài khoản',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['Nam', 'Nữ', 'Khác'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: genders.map((gender) {
          final isSelected = _selectedGender == gender;
          return ChoiceChip(
            label: Text(
              gender,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedGender = gender);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDobSelector() {
    final dobFormatted = _selectedDob != null
        ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
        : 'Chọn ngày sinh';

    return InkWell(
      onTap: _pickDateOfBirth,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dobFormatted,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selectedDob != null
                      ? AppColors.textPrimary
                      : Colors.grey.shade400,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        final isLoading = state is EditProfileLoading;

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('saveProfileButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: isLoading ? null : _onSave,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Lưu thay đổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

