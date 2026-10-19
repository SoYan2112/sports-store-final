import '../../domain/entities/voucher_entity.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/voucher_remote_datasource.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;

  VoucherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VoucherEntity>> getVouchers() async {
    return await remoteDataSource.getVouchers();
  }
}

