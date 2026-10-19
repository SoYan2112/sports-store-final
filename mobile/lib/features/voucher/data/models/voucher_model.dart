import '../../domain/entities/voucher_entity.dart';

class VoucherModel extends VoucherEntity {
  const VoucherModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.type,
    required super.discountValue,
    required super.minOrderValue,
    super.maxDiscountAmount,
    required super.startDate,
    required super.endDate,
    super.isUsed,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    VoucherType parseType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'percentage':
        case 'percent':
          return VoucherType.percentage;
        case 'fixedamount':
        case 'fixed_amount':
        case 'fixed':
          return VoucherType.fixedAmount;
        case 'freeshipping':
        case 'free_shipping':
        case 'shipping':
          return VoucherType.freeShipping;
        default:
          return VoucherType.fixedAmount;
      }
    }

    return VoucherModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: parseType(json['type']?.toString()),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      isUsed: json['isUsed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(VoucherType t) {
      switch (t) {
        case VoucherType.percentage:
          return 'percentage';
        case VoucherType.fixedAmount:
          return 'fixed_amount';
        case VoucherType.freeShipping:
          return 'free_shipping';
      }
    }

    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': typeToString(type),
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'maxDiscountAmount': maxDiscountAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isUsed': isUsed,
    };
  }
}

