import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../widgets/vietnam_address_picker_bottom_sheet.dart';

/// ============================================================================
/// MÀN HÌNH THÊM ĐỊA CHỈ GIAO HÀNG MỚI (ADD ADDRESS SCREEN - UC-29)
/// ============================================================================
/// Màn hình này chịu trách nhiệm:
/// 1. Cung cấp form nhập thông tin người nhận hàng:
///    - Họ và tên người nhận, Số điện thoại liên hệ.
///    - Bộ chọn địa giới hành chính Việt Nam 3 cấp: Tỉnh/Thành phố -> Quận/Huyện -> Phường/Xã.
///    - Địa chỉ chi tiết (Số nhà, tên đường, tòa nhà).
///    - Phân loại địa chỉ: Nhà riêng / Văn phòng.
///    - Tùy chọn đặt làm địa chỉ mặc định.
/// 2. Xác thực (validation) dữ liệu:
///    - Tên người nhận >= 2 ký tự.
///    - SĐT chuẩn 10 số nhà mạng VN (+84, 03x, 05x, 07x, 08x, 09x).
///    - Bắt buộc chọn đầy đủ 3 cấp hành chính.
///    - Địa chỉ chi tiết >= 5 ký tự.
/// 3. Gửi thông tin qua [AddressCubit.addAddress], lưu vào SQLite / API và đóng màn hình.
class AddAddressScreen extends StatefulWidget {
  final AddressCubit? cubit;

  const AddAddressScreen({super.key, this.cubit});

  /// Phương thức static tạo Route điều hướng đến AddAddressScreen.
  /// Hỗ trợ tái sử dụng [AddressCubit] từ màn hình gọi nếu có.
  static Route<AddressEntity?> route({AddressCubit? cubit}) {
    return MaterialPageRoute<AddressEntity?>(
      builder: (_) {
        if (cubit != null) {
          return BlocProvider.value(
            value: cubit,
            child: const AddAddressScreen(),
          );
        }
        return const AddAddressScreen();
      },
    );
  }

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  /// Controller quản lý các trường nhập văn bản
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();

  /// Biến lưu địa giới hành chính 3 cấp Việt Nam
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  /// Nhãn địa chỉ (mặc định: Nhà riêng)
  AddressLabel _selectedLabel = AddressLabel.home;

  /// Trạng thái đặt làm địa chỉ mặc định
  bool _isDefault = false;

  /// Chuỗi thông báo lỗi validation cho từng trường
  String? _nameError;
  String? _phoneError;
  String? _areaError;
  String? _streetError;

  @override
  void dispose() {
    // Hủy các controller khi màn hình đóng để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  /// Kiểm tra tính hợp lệ của dữ liệu trước khi lưu
  bool _validateInputs() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();

    String? nameErr;
    String? phoneErr;
    String? areaErr;
    String? streetErr;

    // 1. Kiểm tra Họ và tên người nhận (không để trống, ít nhất 2 ký tự)
    if (name.isEmpty) {
      nameErr = 'Vui lòng nhập họ và tên người nhận';
    } else if (name.length < 2) {
      nameErr = 'Họ và tên phải có ít nhất 2 ký tự';
    }

    // 2. Kiểm tra Số điện thoại chuẩn Việt Nam (+84 hoặc 03x, 05x, 07x, 08x, 09x - 10 chữ số)
    final phoneRegex = RegExp(
      r'^(?:(?:\+84)|0)(3[2-9]|5[25689]|7[06-9]|8[1-9]|9[0-9])[0-9]{7}$',
    );
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) {
      phoneErr = 'Vui lòng nhập số điện thoại người nhận';
    } else if (!phoneRegex.hasMatch(cleanPhone)) {
      phoneErr = 'Số điện thoại không hợp lệ (ví dụ: 0901234567)';
    }

    // 3. Kiểm tra Khu vực 3 cấp (Bắt buộc chọn đủ Tỉnh, Huyện, Xã)
    if (_selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null) {
      areaErr = 'Vui lòng chọn Tỉnh/Thành phố, Quận/Huyện, Phường/Xã';
    }

    // 4. Kiểm tra Địa chỉ cụ thể (tối thiểu 5 ký tự)
    if (street.isEmpty) {
      streetErr = 'Vui lòng nhập số nhà, tên đường cụ thể';
    } else if (street.length < 5) {
      streetErr = 'Địa chỉ chi tiết cần cụ thể hơn (tối thiểu 5 ký tự)';
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
      _areaError = areaErr;
      _streetError = streetErr;
    });

    return nameErr == null &&
        phoneErr == null &&
        areaErr == null &&
        streetErr == null;
  }

  /// Mở BottomSheet chọn địa giới hành chính 3 cấp Việt Nam
  Future<void> _openAreaPicker() async {
    final result = await VietnamAddressPickerBottomSheet.show(
      context,
      initialProvince: _selectedProvince,
      initialDistrict: _selectedDistrict,
      initialWard: _selectedWard,
    );

    if (result != null) {
      setState(() {
        _selectedProvince = result.province;
        _selectedDistrict = result.district;
        _selectedWard = result.ward;
        _areaError = null;
      });
    }
  }

  /// Xử lý gửi form thêm địa chỉ
  void _submit() {
    if (!_validateInputs()) return;

    context.read<AddressCubit>().addAddress(
          recipientName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          province: _selectedProvince!,
          district: _selectedDistrict!,
          ward: _selectedWard!,
          streetAddress: _streetController.text.trim(),
          label: _selectedLabel,
          isDefault: _isDefault,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        // TRƯỜNG HỢP 1: Thêm thành công
        if (state is AddressAddSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm địa chỉ giao hàng thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Trả địa chỉ mới về màn hình trước
          Navigator.of(context).pop(state.newAddress);
        } 
        // TRƯỜNG HỢP 2: Thất bại
        else if (state is AddressError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AddressAddLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Địa chỉ mới',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PHẦN 1: LIÊN HỆ
                        _buildSectionHeader('Liên hệ'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Họ và tên người nhận
                              _buildTextField(
                                keyName: 'recipientNameField',
                                controller: _nameController,
                                label: 'Họ và tên người nhận',
                                hint: 'Ví dụ: Nguyễn Văn A',
                                icon: Icons.person_outline_rounded,
                                errorText: _nameError,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const Divider(height: 24, color: AppColors.divider),
                              // Số điện thoại người nhận
                              _buildTextField(
                                keyName: 'phoneNumberField',
                                controller: _phoneController,
                                label: 'Số điện thoại',
                                hint: 'Ví dụ: 0901234567',
                                icon: Icons.phone_outlined,
                                errorText: _phoneError,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // PHẦN 2: ĐỊA CHỈ NHẬN HÀNG
                        _buildSectionHeader('Địa chỉ nhận hàng'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Bộ chọn Tỉnh/Thành, Quận/Huyện, Phường/Xã
                              _buildAreaSelector(),
                              const Divider(height: 24, color: AppColors.divider),
                              // Tên đường, tòa nhà, số nhà
                              _buildTextField(
                                keyName: 'streetAddressField',
                                controller: _streetController,
                                label: 'Tên đường, Tòa nhà, Số nhà',
                                hint: 'Ví dụ: 123 Lê Duẩn, Tòa nhà Bitexco...',
                                icon: Icons.home_work_outlined,
                                errorText: _streetError,
                                maxLines: 2,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // PHẦN 3: CÀI ĐẶT (Loại địa chỉ & Mặc định)
                        _buildSectionHeader('Cài đặt'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Loại địa chỉ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Chọn Nhà riêng hoặc Văn phòng
                              Row(
                                children: [
                                  _buildTypeChip(
                                    label: AddressLabel.home.displayName,
                                    icon: Icons.home_outlined,
                                    isSelected:
                                        _selectedLabel == AddressLabel.home,
                                    onTap: () {
                                      setState(() {
                                        _selectedLabel = AddressLabel.home;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildTypeChip(
                                    label: AddressLabel.office.displayName,
                                    icon: Icons.business_outlined,
                                    isSelected:
                                        _selectedLabel == AddressLabel.office,
                                    onTap: () {
                                      setState(() {
                                        _selectedLabel = AddressLabel.office;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: AppColors.divider),

                              // Switch: Đặt làm địa chỉ mặc định
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Đặt làm địa chỉ mặc định',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Tự động chọn khi thanh toán đơn hàng',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isDefault,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _isDefault = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // NÚT HOÀN THÀNH LƯU ĐỊA CHỈ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('saveAddressButton'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                      ),
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'HOÀN THÀNH',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tiêu đề phân mục
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Khung nhập text tùy biến
  Widget _buildTextField({
    required String keyName,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          key: Key(keyName),
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// Khung lựa chọn Tỉnh/Thành, Quận/Huyện, Phường/Xã
  Widget _buildAreaSelector() {
    final hasSelected = _selectedProvince != null &&
        _selectedDistrict != null &&
        _selectedWard != null;

    final displayText = hasSelected
        ? '$_selectedWard, $_selectedDistrict, $_selectedProvince'
        : 'Chọn Tỉnh/Thành phố, Quận/Huyện, Phường/Xã';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'Tỉnh/Thành phố, Quận/Huyện, Phường/Xã',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          key: const Key('areaSelectorTile'),
          onTap: _openAreaPicker,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _areaError != null
                    ? Colors.red.shade400
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          hasSelected ? FontWeight.w600 : FontWeight.w400,
                      color: hasSelected
                          ? AppColors.textPrimary
                          : Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_areaError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _areaError!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  /// Chip lựa chọn loại địa chỉ (Nhà riêng / Văn phòng)
  Widget _buildTypeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
