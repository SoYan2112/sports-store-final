import 'package:equatable/equatable.dart';

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

class AddressEntity extends Equatable {
  final String id;
  final String recipientName;
  final String phoneNumber;
  final String province;
  final String district;
  final String ward;
  final String streetAddress;
  final AddressLabel label;
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

  /// Địa chỉ đầy đủ hiển thị cho người dùng
  String get fullAddress {
    final parts = [streetAddress, ward, district, province]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

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
