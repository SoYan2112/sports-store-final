import '../repositories/address_repository.dart';

/// ============================================================================
/// DELETE ADDRESS USECASE (DOMAIN LAYER - UC-31)
/// ============================================================================
/// Nghiệp vụ xóa một địa chỉ khỏi sổ địa chỉ giao hàng.
class DeleteAddressUseCase {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  Future<void> call(String addressId) async {
    await repository.deleteAddress(addressId);
  }
}
