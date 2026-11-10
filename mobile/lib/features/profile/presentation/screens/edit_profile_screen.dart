import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

/// ============================================================================
/// MÀN HÌNH CHỈNH SỬA HỒ SƠ CÁ NHÂN (EDIT USER PROFILE SCREEN - UC-27)
/// ============================================================================
/// Màn hình này chịu trách nhiệm:
/// 1. Nhận thông tin hồ sơ hiện tại (`initialProfile`) và điền trước (pre-fill) vào form.
/// 2. Cho phép người dùng chỉnh sửa: Họ tên, Số điện thoại, Giới tính, Ngày sinh, Ảnh đại diện.
/// 3. Khóa trường Email (Read-only) nhằm đảm bảo bảo mật và tính toàn vẹn định danh tài khoản.
/// 4. Thực hiện validation dữ liệu: Họ tên tối thiểu 2 ký tự, SĐT đúng đầu số nhà mạng Việt Nam.
/// 5. Gửi thông tin cập nhật qua [EditProfileCubit], lưu vào SQLite / API, đồng bộ lại [AuthCubit]
///    và trả kết quả [UserProfileEntity] mới về cho màn hình xem hồ sơ.
class EditProfileScreen extends StatefulWidget {
  /// Hồ sơ ban đầu trước khi sửa, dùng để đổ dữ liệu vào các ô nhập
  final UserProfileEntity initialProfile;

  const EditProfileScreen({
    super.key,
    required this.initialProfile,
  });

  /// Phương thức static tạo Route điều hướng đến EditProfileScreen.
  /// Bọc màn hình trong [BlocProvider<EditProfileCubit>] được lấy từ GetIt dependency injection.
  /// Trả về đối tượng `UserProfileEntity?` mới khi người dùng lưu thành công và đóng màn hình.
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
  /// Khóa quản lý form kiểm tra tính hợp lệ
  final _formKey = GlobalKey<FormState>();

  /// Bộ điều khiển text cho ô Họ và tên
  late final TextEditingController _nameController;

  /// Bộ điều khiển text cho ô Số điện thoại
  late final TextEditingController _phoneController;

  /// Biến lưu giới tính đang chọn ('Nam', 'Nữ', 'Khác')
  late String _selectedGender;

  /// Biến lưu ngày sinh đang chọn (dạng DateTime)
  DateTime? _selectedDob;

  /// Biến lưu đường dẫn ảnh đại diện nếu có
  String? _selectedAvatar;

  /// Biến lưu chuỗi thông báo lỗi validation cho Họ và tên
  String? _nameError;

  /// Biến lưu chuỗi thông báo lỗi validation cho Số điện thoại
  String? _phoneError;

  /// Biểu thức chính quy (Regex) kiểm tra số điện thoại chuẩn Việt Nam:
  /// - Bắt đầu bằng 0 hoặc +84
  /// - Tiếp theo là các đầu số hợp lệ của nhà mạng Việt Nam: 3, 5, 7, 8, 9
  /// - Theo sau là 8 chữ số ngẫu nhiên (tổng cộng 10 số)
  final _vietnamPhoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller và điền trước (pre-fill) dữ liệu từ hồ sơ hiện tại
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
    // Hủy các controller khi màn hình đóng để tránh memory leak
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Hàm kiểm tra tính hợp lệ của dữ liệu trước khi gửi lưu:
  /// - Họ tên: Không được rỗng, độ dài tối thiểu 2 ký tự.
  /// - Số điện thoại: Không được rỗng, phải đúng chuẩn số điện thoại Việt Nam.
  /// Trả về `true` nếu tất cả hợp lệ, ngược lại `false`.
  bool _validateInputs() {
    final name = _nameController.text.trim();
    // Loại bỏ mọi khoảng trắng thừa trong chuỗi số điện thoại
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    // 1. Kiểm tra trường Họ và tên
    String? nameErr;
    if (name.isEmpty) {
      nameErr = 'Vui lòng nhập họ và tên';
    } else if (name.length < 2) {
      nameErr = 'Họ và tên phải có ít nhất 2 ký tự';
    }

    // 2. Kiểm tra trường Số điện thoại
    String? phoneErr;
    if (phone.isEmpty) {
      phoneErr = 'Vui lòng nhập số điện thoại';
    } else if (!_vietnamPhoneRegex.hasMatch(phone)) {
      phoneErr = 'Số điện thoại không hợp lệ (ví dụ: 0901234567)';
    }

    // Cập nhật thông báo lỗi lên giao diện
    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });

    return nameErr == null && phoneErr == null;
  }

  /// Hàm xử lý khi người dùng nhấn nút "Lưu thay đổi"
  void _onSave() {
    // Nếu kiểm tra validation thất bại, dừng lại không gửi dữ liệu
    if (!_validateInputs()) {
      return;
    }

    // Đóng gói thông tin mới vào thực thể UserProfileEntity bằng copyWith
    final updated = widget.initialProfile.copyWith(
      fullname: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob,
      avatarUrl: _selectedAvatar,
    );

    // Gửi lệnh cập nhật xuống EditProfileCubit để lưu vào SQLite / API
    context.read<EditProfileCubit>().updateProfile(updated);
  }

  /// Hàm mở DatePicker chọn ngày sinh
  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    // Mặc định ngày mở picker: lấy ngày sinh hiện tại hoặc 01/01/2000
    final initial = _selectedDob ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940), // Năm sinh tối thiểu cho phép
      lastDate: now,            // Không cho phép chọn ngày sinh ở tương lai
      helpText: 'CHỌN NGÀY SINH',
      confirmText: 'CHỌN',
      cancelText: 'HỦY',
      builder: (context, child) {
        // Tùy biến bảng màu date picker đồng bộ thương hiệu AppColors
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

    // Khi người dùng bấm CHỌN, cập nhật lại biến ngày sinh
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener lắng nghe các phản hồi trạng thái từ EditProfileCubit
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        // TRƯỜNG HỢP 1: Lưu thành công
        if (state is EditProfileSuccess) {
          // Bước 1: Đồng bộ tên hiển thị mới lên AuthCubit toàn ứng dụng (thanh Profile ngoài tab)
          try {
            context.read<AuthCubit>().updateUserInfo(
                  name: state.updatedProfile.fullname,
                  email: state.updatedProfile.email,
                );
          } catch (_) {}

          // Bước 2: Hiển thị SnackBar thông báo thành công màu xanh lá
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Bước 3: Đóng màn hình chỉnh sửa và trả thực thể updatedProfile về cho UserProfileScreen
          Navigator.of(context).pop(state.updatedProfile);
        } 
        // TRƯỜNG HỢP 2: Lưu thất bại
        else if (state is EditProfileFailure) {
          // Hiển thị SnackBar màu đỏ báo lỗi cho người dùng
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
        // Thanh tiêu đề AppBar
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
            onPressed: () => Navigator.of(context).pop(), // Nút quay lại
          ),
        ),
        // Thân trang cuộn chứa form thông tin
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thẻ Avatar & nút đổi ảnh đại diện
                  _buildAvatarPicker(),
                  const SizedBox(height: 24),

                  // 2. Ô nhập Họ và tên (Bắt buộc)
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
                      // Xóa thông báo lỗi ngay khi người dùng gõ phím sửa
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // 3. Ô Địa chỉ Email (Chỉ đọc - Khóa không cho sửa)
                  _buildSectionLabel('Địa chỉ Email'),
                  const SizedBox(height: 8),
                  _buildReadOnlyEmailField(),
                  const SizedBox(height: 18),

                  // 4. Ô nhập Số điện thoại (Bắt buộc)
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
                      // Xóa thông báo lỗi ngay khi người dùng gõ phím sửa
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // 5. Khung lựa chọn Giới tính (Choice Chips)
                  _buildSectionLabel('Giới tính'),
                  const SizedBox(height: 8),
                  _buildGenderSelector(),
                  const SizedBox(height: 18),

                  // 6. Khung lựa chọn Ngày sinh (Date Picker)
                  _buildSectionLabel('Ngày sinh'),
                  const SizedBox(height: 8),
                  _buildDobSelector(),
                  const SizedBox(height: 32),

                  // 7. Nút bấm "Lưu thay đổi"
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

  /// Khung hiển thị Avatar tròn và nút bấm icon máy ảnh để đổi ảnh
  Widget _buildAvatarPicker() {
    // Tự động cập nhật chữ cái đầu theo Họ tên đang gõ trong ô nhập
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
          // Nút đổi ảnh tròn nhỏ màu đen góc dưới avatar
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                // Hiển thị thông báo hướng dẫn chọn ảnh
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

  /// Nhãn tiêu đề cho từng trường nhập liệu
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

  /// Widget tùy biến khung nhập văn bản TextField với icon, bo tròn và hiển thị lỗi validation
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
        // Nếu có lỗi validation, hiển thị dòng thông báo đỏ bên dưới ô nhập
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

  /// Widget hiển thị trường Email ở chế độ chỉ đọc (Read-only) với icon khóa bảo vệ
  Widget _buildReadOnlyEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Nền xám báo hiệu không cho gõ sửa
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
                // Dòng giải thích lý do không thể chỉnh sửa email
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

  /// Widget lựa chọn giới tính dạng 3 ChoiceChip: Nam, Nữ, Khác
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

  /// Widget chọn ngày sinh có định dạng dd/MM/yyyy
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

  /// Nút bấm "Lưu thay đổi" - Có trạng thái xoay loading khi đang cập nhật
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
            // Nếu đang loading thì vô hiệu hóa nút bấm (null) để tránh spam click
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
