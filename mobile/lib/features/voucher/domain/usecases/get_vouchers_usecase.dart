import '../entities/voucher_entity.dart';
import '../repositories/voucher_repository.dart';

class GetVouchersUseCase {
  final VoucherRepository repository;

  const GetVouchersUseCase(this.repository);

  Future<List<VoucherEntity>> call() async {
    return await repository.getVouchers();
  }
}

