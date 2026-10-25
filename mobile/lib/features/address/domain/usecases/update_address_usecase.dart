import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class UpdateAddressUseCase {
  final AddressRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<AddressEntity> call(AddressEntity address) async {
    return await repository.updateAddress(address);
  }
}
