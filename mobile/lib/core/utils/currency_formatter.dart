import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,###', 'vi_VN');

  /// Định dạng tiền tệ chuẩn Việt Nam: ví dụ 1950000 -> "1.950.000 ₫"
  static String formatVnd(num amount) {
    final formatted = _vndFormat.format(amount).replaceAll(',', '.');
    return '$formatted ₫';
  }
}
