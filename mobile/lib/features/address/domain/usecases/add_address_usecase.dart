import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class AddAddressUseCase {
  final AddressRepository repository;

  AddAddressUseCase(this.repository);

  Future<AddressEntity> call(AddressEntity address) async {
    return await repository.addAddress(address);
  }
}
