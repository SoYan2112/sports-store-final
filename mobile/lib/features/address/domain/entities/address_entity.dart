import 'package:equatable/equatable.dart';

/// ============================================================================
/// ADDRESS LABEL & ENTITY (DOMAIN LAYER)
/// ============================================================================

/// Phân loại địa chỉ giao hàng: Nhà riêng hoặc Văn phòng
enum AddressLabel {
  home('Nhà riêng'),
  office('Văn phòng');

  final String displayName;
  const AddressLabel(this.displayName);

  static AddressLabel fromString(String? value) {
    if (value == null) return AddressLabel.home;
    final lower = value.toLowerCase().trim();
    if (lower == 'office' || lower == 'văn phòng' || lower == 'van phong') {
      return AddressLabel.office;
    }
    return AddressLabel.home;
  }
}

/// Thực thể địa chỉ giao nhận hàng của khách hàng
class AddressEntity extends Equatable {
  /// Mã định danh duy nhất của địa chỉ
  final String id;

  /// Họ và tên người nhận hàng
  final String recipientName;

  /// Số điện thoại người nhận hàng
  final String phoneNumber;

  /// Tỉnh / Thành phố
  final String province;

  /// Quận / Huyện / Thị xã
  final String district;

  /// Phường / Xã / Thị trấn
  final String ward;

  /// Tên đường, tòa nhà, số nhà cụ thể
  final String streetAddress;

  /// Loại địa chỉ: Nhà riêng / Văn phòng
  final AddressLabel label;

  /// Có phải là địa chỉ mặc định được ưu tiên chọn khi Checkout không
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.province,
    required this.district,
    required this.ward,
    required this.streetAddress,
    this.label = AddressLabel.home,
    this.isDefault = false,
  });

  /// Chuỗi địa chỉ đầy đủ ghép từ các cấp hành chính để hiển thị UI
  String get fullAddress {
    final parts = [streetAddress, ward, district, province]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  /// Tạo bản sao có sửa đổi thuộc tính
  AddressEntity copyWith({
    String? id,
    String? recipientName,
    String? phoneNumber,
    String? province,
    String? district,
    String? ward,
    String? streetAddress,
    AddressLabel? label,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      streetAddress: streetAddress ?? this.streetAddress,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipientName,
        phoneNumber,
        province,
        district,
        ward,
        streetAddress,
        label,
        isDefault,
      ];
}
