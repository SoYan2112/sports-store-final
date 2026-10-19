import '../entities/voucher_entity.dart';

abstract class VoucherRepository {
  Future<List<VoucherEntity>> getVouchers();
}

