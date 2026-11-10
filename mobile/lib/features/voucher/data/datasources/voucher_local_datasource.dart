import '../../../../core/database/app_database.dart';
import '../../domain/entities/voucher_entity.dart';
import '../models/voucher_model.dart';
import 'voucher_remote_datasource.dart';

abstract class VoucherLocalDataSource {
  Future<List<VoucherModel>> getVouchers();
}

class VoucherLocalDataSourceImpl
    implements VoucherLocalDataSource, VoucherRemoteDataSource {
  final AppDatabase appDatabase;

  VoucherLocalDataSourceImpl({AppDatabase? appDatabase})
      : appDatabase = appDatabase ?? AppDatabase.instance;

  VoucherType _parseType(String? typeStr) {
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

  @override
  Future<List<VoucherModel>> getVouchers() async {
    final db = await appDatabase.database;
    final results = await db.query(
      'vouchers',
      where: 'is_used = 0',
      orderBy: 'discount_value DESC',
    );

    return results.map((row) {
      return VoucherModel(
        id: row['id'] as String,
        code: row['code'] as String,
        title: row['title'] as String,
        description: row['description'] as String? ?? '',
        type: _parseType(row['type'] as String?),
        discountValue: (row['discount_value'] as num?)?.toDouble() ?? 0.0,
        minOrderValue: (row['min_order_value'] as num?)?.toDouble() ?? 0.0,
        maxDiscountAmount: (row['max_discount_amount'] as num?)?.toDouble(),
        startDate: DateTime.tryParse(row['start_date'].toString()) ?? DateTime.now(),
        endDate: DateTime.tryParse(row['end_date'].toString()) ??
            DateTime.now().add(const Duration(days: 30)),
        isUsed: (row['is_used'] as num?)?.toInt() == 1,
      );
    }).toList();
  }
}
