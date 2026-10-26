import 'package:equatable/equatable.dart';
import '../../../../core/utils/currency_formatter.dart';

enum VoucherType {
  percentage,
  fixedAmount,
  freeShipping,
}

class VoucherEntity extends Equatable {
  final String id;
  final String code;
  final String title;
  final String description;
  final VoucherType type;
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isUsed;

  const VoucherEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    this.isUsed = false,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isValid => !isUsed && !isExpired && DateTime.now().isAfter(startDate);

  String get formattedDiscount {
    switch (type) {
      case VoucherType.percentage:
        return 'Giảm ${discountValue.toInt()}%';
      case VoucherType.fixedAmount:
        return 'Giảm ${CurrencyFormatter.formatVnd(discountValue)}';
      case VoucherType.freeShipping:
        return 'Freeship Extra';
    }
  }

  String get formattedMinOrder {
    if (minOrderValue <= 0) return 'Đơn từ 0 ₫';
    return 'Đơn tối thiểu ${CurrencyFormatter.formatVnd(minOrderValue)}';
  }

  String get formattedExpiry {
    final day = endDate.day.toString().padLeft(2, '0');
    final month = endDate.month.toString().padLeft(2, '0');
    final year = endDate.year;
    return 'HSD: $day/$month/$year';
  }

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        type,
        discountValue,
        minOrderValue,
        maxDiscountAmount,
        startDate,
        endDate,
        isUsed,
      ];
}

