import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

/// ============================================================================
/// GET ADDRESSES USECASE (DOMAIN LAYER - UC-28)
/// ============================================================================
/// Nghiệp vụ lấy danh sách địa chỉ giao hàng của người dùng hiện tại.
class GetAddressesUseCase {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  Future<List<AddressEntity>> call() async {
    return await repository.getAddresses();
  }
}
