import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import '../models/address_model.dart';

/// ============================================================================
/// ADDRESS REPOSITORY IMPLEMENTATION (DATA LAYER)
/// ============================================================================
/// Triển khai [AddressRepository], làm cầu nối giữa UseCase và DataSource.
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  /// Lấy danh sách địa chỉ nhận hàng
  @override
  Future<List<AddressEntity>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  /// Thêm địa chỉ mới
  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    return await remoteDataSource.addAddress(model);
  }

  /// Cập nhật địa chỉ
  @override
  Future<AddressEntity> updateAddress(AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    return await remoteDataSource.updateAddress(model);
  }

  /// Xóa địa chỉ theo ID
  @override
  Future<void> deleteAddress(String addressId) async {
    await remoteDataSource.deleteAddress(addressId);
  }

  /// Đặt làm địa chỉ mặc định
  @override
  Future<void> setDefaultAddress(String addressId) async {
    await remoteDataSource.setDefaultAddress(addressId);
  }
}
