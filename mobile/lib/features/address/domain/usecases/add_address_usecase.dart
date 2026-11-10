import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

/// ============================================================================
/// ADD ADDRESS USECASE (DOMAIN LAYER - UC-29)
/// ============================================================================
/// Nghiệp vụ thêm một địa chỉ giao hàng mới vào sổ địa chỉ.
class AddAddressUseCase {
  final AddressRepository repository;

  AddAddressUseCase(this.repository);

  Future<AddressEntity> call(AddressEntity address) async {
    return await repository.addAddress(address);
  }
}
