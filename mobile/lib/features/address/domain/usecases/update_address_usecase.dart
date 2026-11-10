import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

/// ============================================================================
/// UPDATE ADDRESS USECASE (DOMAIN LAYER - UC-30)
/// ============================================================================
/// Nghiệp vụ cập nhật thông tin địa chỉ giao hàng đã tồn tại.
class UpdateAddressUseCase {
  final AddressRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<AddressEntity> call(AddressEntity address) async {
    return await repository.updateAddress(address);
  }
}
