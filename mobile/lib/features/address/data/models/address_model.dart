import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.recipientName,
    required super.phoneNumber,
    required super.province,
    required super.district,
    required super.ward,
    required super.streetAddress,
    super.label = AddressLabel.home,
    super.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      recipientName: json['recipientName'] ?? json['recipient_name'] ?? json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? json['phone'] ?? '',
      province: json['province'] ?? json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? json['commune'] ?? '',
      streetAddress: json['streetAddress'] ?? json['street_address'] ?? json['street'] ?? '',
      label: AddressLabel.fromString(json['label']?.toString()),
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'province': province,
      'district': district,
      'ward': ward,
      'streetAddress': streetAddress,
      'label': label.name,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      recipientName: entity.recipientName,
      phoneNumber: entity.phoneNumber,
      province: entity.province,
      district: entity.district,
      ward: entity.ward,
      streetAddress: entity.streetAddress,
      label: entity.label,
      isDefault: entity.isDefault,
    );
  }
}
